# Three-node Redpanda with mutual TLS

Each broker has its own configuration and data volume. Place CA, server certificate/key and client certificate/key files in `tls/` using the filenames in the broker YAML files and console environment. The server certificate SANs must cover `redpanda-1`, `redpanda-2`, `redpanda-3` and `localhost`. Kafka listeners enforce client authentication. Administrative HTTP endpoints remain for local development. Replace advertised localhost addresses and certificates together for remote clients.

Existing bind volume directories under `/opt/docker` are preserved; create them before starting. The old `redpanda.yaml` is retained as a reference and is no longer mounted. Validate with `docker compose config --quiet`; no services are started by validation.
