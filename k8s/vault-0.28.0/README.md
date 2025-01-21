# Configure vault for mTLS
```console
https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine
### ROOT CA ###

vault secrets enable pki
vault secrets tune -max-lease-ttl=262800h pki

cd /tmp

vault write -field=certificate pki/root/generate/internal \
     common_name="hera.ro" \
     issuer_name="hera" \
     ttl=262800h > root_ca.crt


vault write pki/roles/hera_ca allowed_domains=hera.ro allow_subdomanins=true
vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"


### INT CA MTLS PODS ###

vault secrets enable -path=pki_int_mtls pki
vault secrets tune -max-lease-ttl=219000h pki_int_mtls

vault write -format=json pki_int_mtls/intermediate/generate/internal \
     common_name="cluster.local" issuer_name="Hera mTLS"  | ./jq -r '.data.csr' > pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="hera" \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="219000h" | ./jq -r '.data.certificate' > intermediate.cert.pem
    
vault write pki_int_mtls/intermediate/set-signed certificate=@intermediate.cert.pem

############################# Create a role for every mtls solution
vault write pki_int_mtls/roles/vault_mtls allowed_domains=cluster.local,vault-hera,vault-hera.vault-hera,vault-hera.vault-hera.svc,vault-hera-internal,vault-hera-internal.vault-hera,vault-hera-internal.vault-hera.svc,vault-hera-internal.vault-hera.svc.cluster.local,vault-hera-0.vault-hera-internal,vault-hera-1.vault-hera-internal,vault-hera-2.vault-hera-internal \
allow_subdomains=true allow_bare_domains=true

vault write pki_int_mtls/config/urls issuing_certificates="$VAULT_ADDR/v1/pki_int_mtls/ca" crl_distribution_points="$VAULT_ADDR/v1/pki_int_mtls/crl"


### INT CA TLS INGRESS ###

vault secrets enable -path=pki_int_tls pki
vault secrets tune -max-lease-ttl=219000h pki_int_tls

vault write -format=json pki_int_tls/intermediate/generate/internal \
     common_name="hera.ro" issuer_name="Hera TLS"  | ./jq -r '.data.csr' > pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
     issuer_ref="hera" \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="219000h" | ./jq -r '.data.certificate' > intermediate.cert.pem
    
vault write pki_int_tls/intermediate/set-signed certificate=@intermediate.cert.pem
vault write pki_int_tls/roles/hera_tls allowed_domains=hera.ro allow_subdomains=true
vault write pki_int_tls/config/urls issuing_certificates="$VAULT_ADDR/v1/pki_int_tls/ca" crl_distribution_points="$VAULT_ADDR/v1/pki_int_tls/crl"




### Enable Kubernetes Auth

vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"


######################################################### Repeat the process for every mtls solution
### Policy for mtls
vault policy write vault_mtls - <<EOF
path "pki_int_mtls*"                        { capabilities = ["read", "list"] }
path "pki_int_mtls/sign/vault_mtls"    { capabilities = ["create", "update"] }
path "pki_int_mtls/issue/vault_mtls"   { capabilities = ["create"] }
EOF

### Role for mtls vault pods - k8s auth
vault write auth/kubernetes/role/vault_mtls_issuer \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=vault-hera \
    policies=vault_mtls \
    ttl=24h


#### K8s SA for auth to Vault
k create sa vault-auth -n vault-hera

### Issuer for mtls
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-mtls-issuer
  namespace: vault-hera
spec:
  vault:
    server: http://vault-hera.vault-hera:8200
    path: pki_int_mtls/sign/vault_mtls
    auth:
      kubernetes:
        role: vault_mtls_issuer
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-auth
EOF

#########################################################


### Policy for tls
vault policy write hera_tls - <<EOF
path "pki_int_tls*"                        { capabilities = ["read", "list"] }
path "pki_int_tls/sign/hera_tls"    { capabilities = ["create", "update"] }
path "pki_int_tls/issue/hera_tls"   { capabilities = ["create"] }
EOF


### Role for tls - k8s auth
vault write auth/kubernetes/role/tls_issuer \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=* \
    policies=hera_tls \
    ttl=24h


#### K8s SA for auth to Vault and roles for create tokens (SA needs this cluster role to create token an every namespace)
k create sa vault-auth -n cert-manager

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vault-auth
rules:
- apiGroups:
  - ""
  resourceNames:
  - vault-auth
  resources:
  - serviceaccounts/token
  verbs:
  - create
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-auth
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vault-auth
subjects:
- kind: ServiceAccount
  name: cert-manager
  namespace: cert-manager
EOF

### ClusterIssuer for tls

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-tls-clusterissuer
spec:
  vault:
    server: http://vault-hera.vault-hera:8200
    path: pki_int_tls/sign/hera_tls
    auth:
      kubernetes:
        role: tls_issuer
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-auth
EOF


### Generate cert for tls vault communication


kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: vault-cert
  namespace: vault-hera
spec:
  secretName: vault-tls
  issuerRef:
    name: vault-mtls-issuer
    kind: Issuer
  commonName: cluster.local
  ipAddresses:
    - 127.0.0.1
  dnsNames:
    - vault-hera
    - vault-hera.vault-hera
    - vault-hera.vault-hera.svc
    - vault-hera.vault-hera.svc.cluster.local
    - vault-hera-internal
    - vault-hera-internal.vault-hera
    - vault-hera-internal.vault-hera.svc
    - vault-hera-internal.vault-hera.svc.cluster.local
    - vault-hera-0.vault-hera-internal
    - vault-hera-1.vault-hera-internal
    - vault-hera-2.vault-hera-internal
  isCA: false
  duration: 8760h0m0s
  renewBefore: 8640h0m0s
  subject:
    countries:
      - RO
    organizations:
      - Hera-mTLS
  usages:
    - digital signature
    - key encipherment
    - server auth
    - client auth
    - key agreement
EOF





###!!!! After you add mTLS 
### Modify Cert-Manager ClusterIssuer and Issuers to use Root CA Bundle 

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-tls-clusterissuer
spec:
  vault:
    server: https://vault-hera.vault-hera:8200
    path: pki_int_tls/sign/hera_tls
    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLekNDQWhPZ0F3SUJBZ0lVSDZNYzk3SUljaG9QeGwxU1pneVdVc3lnelFVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0VqRVFNQTRHQTFVRUF4TUhhR1Z5WVM1eWJ6QWdGdzB5TkRBMk1UUXdOak16TlRSYUdBOHlNRFUwTURZdwpOekEyTXpReU5Gb3dFakVRTUE0R0ExVUVBeE1IYUdWeVlTNXliekNDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFECmdnRVBBRENDQVFvQ2dnRUJBTm91TDlHaHNSR0QvMlUwNEV1cFhVVnJSckIzaWpnVktJaXVDVnVXbGZmNDFKUVkKWFpSdUJlbTZLS1VTYk9NQWxheEYxaFN0bkNJOUtuT09iRURsNGJtNHU4aHVkNlRiVkpLOTJESE4rV0NDTHBubAo0ckVFQ29Kd1Q2VVErYWV3UWlZT0ljVS9HUnl4ejMyMUdobnU3NGxJcmExZS9mZTdwaGZya2owMUhoeTF1ang0Cld4bnpSQWlxZlMyczlvMk40TFJuMVl3anNTbzhlb3NBUjdJSDEvcHBJUVRRTnpNNUpTL0M2dEk5eXdkVFBMOVUKZHdvZng0VmpkUTZ2M3ppS0p1UjgvMm9ueS9IcmhLZVRZbUNLWi9uTVlBbUZNRU5PL1h1eFIzMUxocFNEb2R5MQpkdEFMNXVLcnJBZ1J0VGltV2szMVRyc01UaWU4OGh0YlpLQTFkMDBDQXdFQUFhTjNNSFV3RGdZRFZSMFBBUUgvCkJBUURBZ0VHTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME9CQllFRkpYV1VmQmwrdHkwN3JBYmhVV1AKNTVVN3BLbk5NQjhHQTFVZEl3UVlNQmFBRkpYV1VmQmwrdHkwN3JBYmhVV1A1NVU3cEtuTk1CSUdBMVVkRVFRTApNQW1DQjJobGNtRXVjbTh3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUtqeDdnRm8xbWs5aUY0Z1h0Zm05NHZsClkyOEMvTVRXWDZ2SGtzL0MrdmtJVG9VOEFGU1QzQUQ5dUU3NzRyMG9VZTAzc1h0SFFNd0kzVm5HMGluZUh1MVIKdW9seWU5cXM0YzRvL2VFUFhHdkVjMHc2KzNvbnY5NVdnbFhHcGZQbVlDRjJYWmEwbEhWQlFFWHJRaVZFQkpwVwo1UW5ncHY5UGdwSGVRbjlrRWltbm85OTkvVkpsMy9LK1Q3U3FKcC9EMllYQncvWFp5S09LOTZkOFg5c0dJVWwwCjlsYWZrQ014cTZoM29vdWk1ZjVJV25KcGFQSEJLQlBWNDZobXhQNnlsbE1aeDhJL0dwU3ZHYUJYTEM5SVBPUS8Kem9kajYxSDBhMUQ2NlA1T3JGSDl3QUNBRll2MzF2Z3FjSkcwVXVhUFIxNDRlYVoxZFY3cWNUS0QxRWZnSGF3PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    auth:
      kubernetes:
        role: tls_issuer
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-auth
EOF


####
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-mtls-issuer
  namespace: vault-hera
spec:
  vault:
    server: https://vault-hera.vault-hera:8200
    path: pki_int_mtls/sign/vault_mtls
    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLekNDQWhPZ0F3SUJBZ0lVSDZNYzk3SUljaG9QeGwxU1pneVdVc3lnelFVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0VqRVFNQTRHQTFVRUF4TUhhR1Z5WVM1eWJ6QWdGdzB5TkRBMk1UUXdOak16TlRSYUdBOHlNRFUwTURZdwpOekEyTXpReU5Gb3dFakVRTUE0R0ExVUVBeE1IYUdWeVlTNXliekNDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFECmdnRVBBRENDQVFvQ2dnRUJBTm91TDlHaHNSR0QvMlUwNEV1cFhVVnJSckIzaWpnVktJaXVDVnVXbGZmNDFKUVkKWFpSdUJlbTZLS1VTYk9NQWxheEYxaFN0bkNJOUtuT09iRURsNGJtNHU4aHVkNlRiVkpLOTJESE4rV0NDTHBubAo0ckVFQ29Kd1Q2VVErYWV3UWlZT0ljVS9HUnl4ejMyMUdobnU3NGxJcmExZS9mZTdwaGZya2owMUhoeTF1ang0Cld4bnpSQWlxZlMyczlvMk40TFJuMVl3anNTbzhlb3NBUjdJSDEvcHBJUVRRTnpNNUpTL0M2dEk5eXdkVFBMOVUKZHdvZng0VmpkUTZ2M3ppS0p1UjgvMm9ueS9IcmhLZVRZbUNLWi9uTVlBbUZNRU5PL1h1eFIzMUxocFNEb2R5MQpkdEFMNXVLcnJBZ1J0VGltV2szMVRyc01UaWU4OGh0YlpLQTFkMDBDQXdFQUFhTjNNSFV3RGdZRFZSMFBBUUgvCkJBUURBZ0VHTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME9CQllFRkpYV1VmQmwrdHkwN3JBYmhVV1AKNTVVN3BLbk5NQjhHQTFVZEl3UVlNQmFBRkpYV1VmQmwrdHkwN3JBYmhVV1A1NVU3cEtuTk1CSUdBMVVkRVFRTApNQW1DQjJobGNtRXVjbTh3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUtqeDdnRm8xbWs5aUY0Z1h0Zm05NHZsClkyOEMvTVRXWDZ2SGtzL0MrdmtJVG9VOEFGU1QzQUQ5dUU3NzRyMG9VZTAzc1h0SFFNd0kzVm5HMGluZUh1MVIKdW9seWU5cXM0YzRvL2VFUFhHdkVjMHc2KzNvbnY5NVdnbFhHcGZQbVlDRjJYWmEwbEhWQlFFWHJRaVZFQkpwVwo1UW5ncHY5UGdwSGVRbjlrRWltbm85OTkvVkpsMy9LK1Q3U3FKcC9EMllYQncvWFp5S09LOTZkOFg5c0dJVWwwCjlsYWZrQ014cTZoM29vdWk1ZjVJV25KcGFQSEJLQlBWNDZobXhQNnlsbE1aeDhJL0dwU3ZHYUJYTEM5SVBPUS8Kem9kajYxSDBhMUQ2NlA1T3JGSDl3QUNBRll2MzF2Z3FjSkcwVXVhUFIxNDRlYVoxZFY3cWNUS0QxRWZnSGF3PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    auth:
      kubernetes:
        role: vault_mtls_issuer
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-auth
EOF
```


# Vault OIDC with Keycloak
```console
### Keyclock Steps

1. Create client

Select/create a Realm and Client. Select a Client and visit Settings.
Client Protocol: openid-connect
Access Type: confidential
Standard Flow Enabled: On
Configure Root URL such as http://vault.example.com
Configure Valid Redirect URIs such as
http://vault.hera.ro/ui/vault/auth/oidc/oidc/callback
http://vault.hera.ro/oidc/oidc/callback
Root URL https://vault.hera.ro/ui/vault/auth/oidc/oidc/callback
Web origins https://vault.hera.ro
*Service accounts roles - Yes
*Direct access grants - No
Save.
Visit Credentials. Select Client ID and Secret and note the generated secret.

2. Client scopes   (details https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/)
- creating a new Client Scope called groups
- In the Tab "Mappers", click on "Configure a new mapper" and choose Group Membership. Make sure to set the Name as well as the Token Claim Name to groups. Also disable the "Full group path".
- Go back to the client we've created earlier and go to the Tab "Client Scopes". Click on "Add client scope", choose the groups scope and add it either to the Default or to the Optional Client Scope. 

3. Create Groups and Users as you wish





### Vault (https://medium.com/@sauravkumarsct/integrate-keycloak-as-oidc-jwt-provider-with-hashicorp-vault-ae9ebcf8e335)

vault auth enable oidc

vault write auth/oidc/config \
    oidc_discovery_url="https://keycloak.hera.ro/realms/hera3rd" \
    oidc_client_id="vault" \
    oidc_client_secret="p5RLN3dI6YeEqxTK4Ug4HfGp56LDzq8m" \
    oidc_discovery_ca_pem=@hera.pem \
    default_role="viewer"


vault policy write admin - <<EOF
path "/*"    { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }
EOF

vault policy write viewer - <<EOF
path "/*"    { capabilities = ["read", "list"] }
EOF


vault write auth/oidc/role/viewer \
    bound_audiences="vault" \
    allowed_redirect_uris="https://vault.hera.ro/oidc/oidc/callback" \
    allowed_redirect_uris="https://vault.hera.ro/ui/vault/auth/oidc/oidc/callback" \
    user_claim="sub" \
    token_type="service" \
    groups_claim="groups" \
    token_no_default_policy="true" \
    role_type="oidc" \
    token_ttl="10m" \
    policies=viewer



vault write auth/oidc/role/admin \
    bound_audiences="vault" \
    allowed_redirect_uris="https://vault.hera.ro/oidc/oidc/callback" \
    allowed_redirect_uris="https://vault.hera.ro/ui/vault/auth/oidc/oidc/callback" \
    user_claim="sub" \
    token_type="service" \
    groups_claim="groups" \
    token_no_default_policy="true" \
    role_type="oidc" \
    token_ttl="10m" \
    policies=admin



* group and alias name must be the same as names from Keycloak Groups

vault write identity/group name="VaultAdmins" type="external" policies="admin"   (generates an id, use it for the next command (canonical_id))
vault write identity/group-alias name="VaultAdmins" mount_accessor=auth_oidc_b93a8953 canonical_id=263322e8-9868-b120-a645-275cdb21b8f6 (mount_accessor parameter is from OIDC config)

vault write identity/group name="VaultViewers" type="external" policies="viewer"  (generates an id, use it for the next command (canonical_id))
vault write identity/group-alias name="VaultViewers" mount_accessor=auth_oidc_b93a8953 canonical_id=27dbc874-bf16-0d3a-d67f-a141fff3ff17
```


# Vault Helm Chart

> :warning: **Please note**: We take Vault's security and our users' trust very seriously. If 
you believe you have found a security issue in Vault Helm, _please responsibly disclose_ 
by contacting us at [security@hashicorp.com](mailto:security@hashicorp.com).

This repository contains the official HashiCorp Helm chart for installing
and configuring Vault on Kubernetes. This chart supports multiple use
cases of Vault on Kubernetes depending on the values provided.

For full documentation on this Helm chart along with all the ways you can
use Vault with Kubernetes, please see the
[Vault and Kubernetes documentation](https://developer.hashicorp.com/vault/docs/platform/k8s).

## Prerequisites

To use the charts here, [Helm](https://helm.sh/) must be configured for your
Kubernetes cluster. Setting up Kubernetes and Helm is outside the scope of
this README. Please refer to the Kubernetes and Helm documentation.

The versions required are:

  * **Helm 3.6+**
  * **Kubernetes 1.22+** - This is the earliest version of Kubernetes tested.
    It is possible that this chart works with earlier versions but it is
    untested.

## Usage

To install the latest version of this chart, add the Hashicorp helm repository
and run `helm install`:

```console
$ helm repo add hashicorp https://helm.releases.hashicorp.com
"hashicorp" has been added to your repositories

$ helm install vault hashicorp/vault
```

Please see the many options supported in the `values.yaml` file. These are also
fully documented directly on the [Vault
website](https://developer.hashicorp.com/vault/docs/platform/k8s/helm) along with more
detailed installation instructions.
