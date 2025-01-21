# Certificate generate secret with keystore and truststore
```console
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kafka-ui-mtls-certs
  namespace: kafka-ui
spec:
  keystores:
    jks:
      create: true
      passwordSecretRef:
        key: KAFKA_CLUSTERS_0_PROPERTIES_SSL_KEYSTORE_PASSWORD
        name: ssl-secret
  secretName: kafka-ui-tls
  issuerRef:
    name: kafka-clients-mtls
    kind: Issuer
  commonName: kafka.kafka
  dnsNames:
    - kafka.kafka
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
    - client auth
    - key agreement
EOF
```

# Secret for keystore and truststore password
```console
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
 name: ssl-secret
 namespace: kafka-ui
type: Opaque
data:
 KAFKA_CLUSTERS_0_PROPERTIES_SSL_TRUSTSTORE_PASSWORD: ##Base 64 encoded secret
 KAFKA_CLUSTERS_0_PROPERTIES_SSL_KEYSTORE_PASSWORD: ##Base 64 encoded secret
EOF
```

# ConfigMap for config
```console
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafbat-ui-helm-values
  namespace: kafka-ui
data:
  KAFKA_CLUSTERS_0_NAME: "kafka-cluster"
  KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: "kafka.kafka:9092"
  AUTH_TYPE: "DISABLED"
  MANAGEMENT_HEALTH_LDAP_ENABLED: "FALSE"
  KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL: SSL
    #  LOGGING_LEVEL_IO_KAFBAT: debug
    #  LOGGING_LEVEL_ROOT: debug
    #  KAFKA_CLUSTERS_0_PROPERTIES_SSL_TRUSTSTORE_LOCATION: "/ssl/kafka.truststore.jks"
    #  KAFKA_CLUSTERS_0_PROPERTIES_SSL_TRUSTSTORE_PASSWORD:
    #  KAFKA_CLUSTERS_0_PROPERTIES_SSL_KEYSTORE_LOCATION: "/ssl/kafka.keystore.jks"
    #  KAFKA_CLUSTERS_0_PROPERTIES_SSL_KEYSTORE_PASSWORD:
EOF
```
