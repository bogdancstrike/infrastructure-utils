# Redpanda with mutual TLS

The broker now configures TLS through `redpanda.yaml`. Both Kafka listeners require a client certificate; the console uses the mounted certificate as its client identity. Replace the example files in `connect-certs` with a trusted CA, a server certificate/key, and client certificates before use. The server certificate must include the broker service name and `localhost` in its SANs and allow both server and client authentication if reused by the console. For external clients, replace the advertised `localhost` address and regenerate certificates for the chosen hostname.

Kafka listens on port 19092; the console uses port 8080. The admin endpoint on port 19644 is plain HTTP for local development. Schema Registry and HTTP Proxy are not enabled in this TLS example. Validate with `docker compose config --quiet`; start only when wanted with `docker compose up -d`.
