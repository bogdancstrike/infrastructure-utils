Pentru a configura mTLS la o aplicatie, se creeaza in vault rolul, politica si auth ul:

# din cli dashboard
vault write pki_int_mtls/roles/redis_mtls allowed_domains="cluster.local,redis,redis.redis,redis.redis.svc,redis.svc.cluster.local,redis-headless,redis-headless.redis,redis-headless.redis.svc,redis-headless.redis.svc.cluster.local" allow_subdomains=true allow_bare_domains=true


### from vault pod: kubectl -n vault exec -it vault-0 -- sh
vault policy write redis_mtls - <<EOF
path "pki_int_mtls*"                        { capabilities = ["read", "list"] }
path "pki_int_mtls/sign/redis_mtls"    { capabilities = ["create", "update"] }
path "pki_int_mtls/issue/redis_mtls"   { capabilities = ["create"] }
EOF

# din cli dashboard
### Role for mtls vault pods - k8s auth
vault write auth/kubernetes/role/redis_mtls_issuer \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=redis \
    policies=redis_mtls \
    ttl=24h

in helm chart urile aplicatiei in templates/extra/certs.yaml:

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: redis
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: redis-mtls-issuer
  namespace: redis
spec:
  vault:
    server: https://vault.vault:8200
    path: pki_int_mtls/sign/redis_mtls
    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLekNDQWhPZ0F3SUJBZ0lVSDZNYzk3SUljaG9QeGwxU1pneVdVc3lnelFVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0VqRVFNQTRHQTFVRUF4TUhhR1Z5WVM1eWJ6QWdGdzB5TkRBMk1UUXdOak16TlRSYUdBOHlNRFUwTURZdwpOekEyTXpReU5Gb3dFakVRTUE0R0ExVUVBeE1IYUdWeVlTNXliekNDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFECmdnRVBBRENDQVFvQ2dnRUJBTm91TDlHaHNSR0QvMlUwNEV1cFhVVnJSckIzaWpnVktJaXVDVnVXbGZmNDFKUVkKWFpSdUJlbTZLS1VTYk9NQWxheEYxaFN0bkNJOUtuT09iRURsNGJtNHU4aHVkNlRiVkpLOTJESE4rV0NDTHBubAo0ckVFQ29Kd1Q2VVErYWV3UWlZT0ljVS9HUnl4ejMyMUdobnU3NGxJcmExZS9mZTdwaGZya2owMUhoeTF1ang0Cld4bnpSQWlxZlMyczlvMk40TFJuMVl3anNTbzhlb3NBUjdJSDEvcHBJUVRRTnpNNUpTL0M2dEk5eXdkVFBMOVUKZHdvZng0VmpkUTZ2M3ppS0p1UjgvMm9ueS9IcmhLZVRZbUNLWi9uTVlBbUZNRU5PL1h1eFIzMUxocFNEb2R5MQpkdEFMNXVLcnJBZ1J0VGltV2szMVRyc01UaWU4OGh0YlpLQTFkMDBDQXdFQUFhTjNNSFV3RGdZRFZSMFBBUUgvCkJBUURBZ0VHTUE4R0ExVWRFd0VCL3dRRk1BTUJBZjh3SFFZRFZSME9CQllFRkpYV1VmQmwrdHkwN3JBYmhVV1AKNTVVN3BLbk5NQjhHQTFVZEl3UVlNQmFBRkpYV1VmQmwrdHkwN3JBYmhVV1A1NVU3cEtuTk1CSUdBMVVkRVFRTApNQW1DQjJobGNtRXVjbTh3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUtqeDdnRm8xbWs5aUY0Z1h0Zm05NHZsClkyOEMvTVRXWDZ2SGtzL0MrdmtJVG9VOEFGU1QzQUQ5dUU3NzRyMG9VZTAzc1h0SFFNd0kzVm5HMGluZUh1MVIKdW9seWU5cXM0YzRvL2VFUFhHdkVjMHc2KzNvbnY5NVdnbFhHcGZQbVlDRjJYWmEwbEhWQlFFWHJRaVZFQkpwVwo1UW5ncHY5UGdwSGVRbjlrRWltbm85OTkvVkpsMy9LK1Q3U3FKcC9EMllYQncvWFp5S09LOTZkOFg5c0dJVWwwCjlsYWZrQ014cTZoM29vdWk1ZjVJV25KcGFQSEJLQlBWNDZobXhQNnlsbE1aeDhJL0dwU3ZHYUJYTEM5SVBPUS8Kem9kajYxSDBhMUQ2NlA1T3JGSDl3QUNBRll2MzF2Z3FjSkcwVXVhUFIxNDRlYVoxZFY3cWNUS0QxRWZnSGF3PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    auth:
      kubernetes:
        role: redis_mtls_issuer
        mountPath: /v1/auth/kubernetes
        serviceAccountRef:
          name: vault-auth
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: redis-mtls-certs
  namespace: redis
spec:
  secretName: redis-mtls
  issuerRef:
    name: redis-mtls-issuer
    kind: Issuer
  commonName: cluster.local
  ipAddresses:
    - 127.0.0.1
  dnsNames:
    - redis
    - redis.redis
    - redis.redis.svc
    - redis.redis.svc.cluster.local
    - redis-headless
    - redis-headless.redis
    - redis-headless.redis.svc
    - redis-headless.redis.svc.cluster.local
  isCA: false
  privateKey:
    algorithm: RSA 
    encoding: PKCS8
    size: 2048
  additionalOutputFormats:
  - type: DER
  duration: 2160h0m0s
  renewBefore: 2100h0m0s
  subject:
    countries:
      - RO
    organizations:
      - Hera-mTLS
  usages:
    - digital signature
    - key encipherment
    - server auth
    - key agreement





#######################################
###pt a testa am creat un alt certificat

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: redis-mtls-certs-test
  namespace: redis
spec:
  secretName: redis-mtls-test
  issuerRef:
    name: redis-mtls-issuer
    kind: Issuer
  commonName: cluster.local
  ipAddresses:
    - 127.0.0.1
  dnsNames:
    - redis
    - redis.redis
    - redis.redis.svc
    - redis.redis.svc.cluster.local
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS8
    size: 2048
  additionalOutputFormats:
  - type: DER
  duration: 2160h0m0s
  renewBefore: 2100h0m0s
  subject:
    countries:
      - RO
    organizations:
      - Hera-mTLS
  usages:
    - digital signature
    - key encipherment
    - server auth
    - key agreement




kubectl apply -f test-cert.yaml

root@k8s-01:/opt/hera-thirdparty/redis-20.1.5/templates/extra# kubectl get issuers.cert-manager.io -n redis
NAME                READY   AGE
redis-mtls-issuer   True    47m
root@k8s-01:/opt/hera-thirdparty/redis-20.1.5/templates/extra# kubectl get certificate.cert-manager.io -n redis
NAME                    READY   SECRET            AGE
redis-mtls-certs        True    redis-mtls        4m11s
redis-mtls-certs-test   True    redis-mtls-test   <invalid>
root@k8s-01:/opt/hera-thirdparty/redis-20.1.5/templates/extra# kubectl get secrets -n redis 
NAME                  TYPE                DATA   AGE
redis-mtls            kubernetes.io/tls   4      64m
redis-mtls-test       kubernetes.io/tls   4      69s
redis-tls-passwords   Opaque              2      48m
root@k8s-01:/opt/hera-thirdparty/redis-20.1.5/templates/extra# kubectl -n redis get secrets redis-mtls-test -o json

echo "==" | base64 -d > ca.crt
echo "=" | base64 -d > tls.crt
echo "" | base64 -d > tls.key


redis-cli -h 10.10.20.105 -p 30197 --tls --cert tls.crt --key tls.key --cacert ca.crt --askpass
