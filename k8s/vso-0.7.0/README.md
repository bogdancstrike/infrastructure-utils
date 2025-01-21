# Vault Configuration


### Vault Kubernetes Auth
```console
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" 
```


### Vault policy and role
```console
vault policy write read-secrets - <<EOF
path "external-secrets/*" {
   capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/vso \
      bound_service_account_names=default \
      bound_service_account_namespaces=* \
      policies=read-secrets \
      audience=vault \
      ttl=1h
```
