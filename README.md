# Infrastructure utilities

Docker Compose stacks and Kubernetes examples for development, testing, and self-hosted infrastructure. Choose individual services as needed; there is no startup step that launches the entire repository.

The maintained configurations were refreshed on **2026-10-16**. Images and Helm charts use explicit release tags. See [verified versions and sources](docs/versions.md), the [Kubernetes catalog](k8s/README.md), and [upgrade notes](docs/upgrading.md).

## New services

| Service | Purpose | Docker | Kubernetes | Local endpoint |
| --- | --- | --- | --- | --- |
| **SeaweedFS** | Persistent S3-compatible storage; MinIO alternative | [Compose and S3 guide](docker/seaweedfs) | [Kustomize / Helm guide](k8s/seaweedfs) | S3 `8333`, filer `8888`, master `9333` |
| **Valkey** | Redis-compatible cache with AOF persistence | [Compose](docker/valkey/docker-compose.yml) | [Kustomize](k8s/apps/valkey), [Helm values](k8s/values/valkey.yaml) | Redis protocol `6379` |
| **RabbitMQ** | AMQP message broker and management UI | [Compose](docker/rabbitmq/docker-compose.yml) | [Kustomize](k8s/apps/rabbitmq) | AMQP `5672`, UI `15672` |
| **Mailpit** | SMTP capture, mail preview, and testing API | [Compose](docker/mailpit/docker-compose.yml) | [Kustomize](k8s/apps/mailpit) | SMTP `1025`, UI `8025` |
| **Uptime Kuma** | HTTP, TCP, DNS, and service uptime monitoring | [Compose](docker/uptime-kuma/docker-compose.yml) | [Kustomize](k8s/apps/uptime-kuma) | UI `3001` |

New Compose examples bind published ports to `127.0.0.1`. Kubernetes Services are `ClusterIP`; use port forwarding for local access. These are independent development examples with sample credentials and single-node storage. Edit credentials before sharing access. Persistent examples require a Kubernetes default StorageClass or a storage override.

## Existing services

| Category | Docker examples | Maintained Kubernetes examples |
| --- | --- | --- |
| Git and CI | [Gitea](docker/gitea), [GitLab and Runner](docker/gitlab) | Gitea Helm release |
| Metrics and dashboards | [Prometheus and Grafana](docker/grafana_prometheus), [InfluxDB and Grafana](docker/influx-grafana) | kube-prometheus-stack, metrics-server |
| Tracing | [Jaeger v2 and OpenTelemetry Collector](docker/jaeger-opentelemetry), [Postgres / Jaeger / Grafana](docker/postgres/postgres-jaeger-grafana) | [Jaeger v2](k8s/apps/jaeger) |
| Streaming | [Apache Kafka and Kafbat UI](docker/kafka), [Redpanda single-node](docker/redpanda-single), [three-node](docker/redpanda-cloud), [mutual TLS](<docker/redpanda-single TLS>) | Strimzi operator, [Kafka](k8s/apps/kafka), Kafbat UI |
| Identity | [Keycloak](docker/keycloak) | [Keycloak](k8s/apps/keycloak) |
| Search and logs | [Elasticsearch, Kibana, Logstash, Filebeat, KurrentDB](docker/kibana-elasticsearh-logstash) | Loki and Alloy |
| Relational databases | [PostgreSQL](docker/postgres), [simple PostgreSQL](docker/postgres/simple), [MySQL](docker/mysql), [MariaDB / Adminer](docker/mariadb_adminer) | [PostgreSQL](k8s/apps/postgres), CloudNativePG operator |
| Other databases | [MongoDB / Mongo Express](docker/mongodb), [Redis / RedisInsight](docker/redis) | Valkey |
| Object storage | [SeaweedFS](docker/seaweedfs), [legacy MinIO source build](docker/minio) | SeaweedFS |
| Routing | [Traefik](docker/traefik), [Nginx Proxy Manager](docker/nginxproxymanager), [Nginx mutual TLS](docker/nginx-eid-mtls) | Traefik, Cilium, MetalLB, cert-manager |
| Mail | [Mailpit](docker/mailpit), [MailDev](docker/maildev), [Docker Mailserver](docker/mailserver), [PostfixAdmin](docker/postfix) | Mailpit |
| Other tools | [Nexus](docker/nexus), [Gammu modem CLI](docker/sms-gamu), [Hera variants](docker/hera) | Nextcloud, SonarQube Community, Vault, Vault Secrets Operator, Trivy Operator, Ceph CSI |

The version-named Kubernetes folders contain the original vendored charts and site-specific settings. They are retained as migration references; use `k8s/helmfile.yaml`, `k8s/values/`, and `k8s/apps/` for current examples. The [migration map](k8s/README.md#original-chart-migration-map) explains replacements and appliance-specific exceptions.

## Docker usage

Requires Docker Engine with the Compose v2+ plugin. To inspect an example without starting it:

```bash
git clone https://github.com/bogdancstrike/infrastructure-utils.git
cd infrastructure-utils
docker compose -f docker/seaweedfs/docker-compose.yml config --quiet
```

When you want to run that service:

```bash
cd docker/seaweedfs
docker compose up -d
docker compose logs -f
```

`docker compose down` stops a stack and retains named volumes. `down --volumes` removes its stored data. Several examples use the same host ports, so choose one stack or override its port mappings. Existing Hera examples retain their custom networks, host data paths, and TLS requirements.

The new stacks support these environment overrides in a local `.env` file:

| Stack | Variables | Example defaults |
| --- | --- | --- |
| SeaweedFS | `SEAWEEDFS_S3_PORT`, `SEAWEEDFS_MASTER_PORT`, `SEAWEEDFS_FILER_PORT` | `8333`, `9333`, `8888`; credentials in `s3.json` |
| Valkey | `VALKEY_PORT`, `VALKEY_PASSWORD` | `6379`, `development-password` |
| RabbitMQ | `RABBITMQ_PORT`, `RABBITMQ_UI_PORT`, `RABBITMQ_USER`, `RABBITMQ_PASSWORD` | `5672`, `15672`, `development`, `development-password` |
| Mailpit | `MAILPIT_SMTP_PORT`, `MAILPIT_UI_PORT` | `1025`, `8025` |
| Uptime Kuma | `UPTIME_KUMA_PORT` | `3001`; create the administrator on first use |

See the [SeaweedFS guide](docker/seaweedfs/README.md) for AWS CLI smoke commands, S3 SDK settings, and MinIO migration.

## Kubernetes usage

Requires Helm, Helmfile, and kubectl for deployment. Rendering with Helm or Kustomize does not need a running cluster.

```bash
# Render one pinned upstream chart without installing it.
helmfile -f k8s/helmfile.yaml --selector name=seaweedfs template

# Render the standalone example without applying it.
kubectl kustomize k8s/seaweedfs
kubectl kustomize k8s/apps/rabbitmq
```

Choose either Helm or Kustomize for SeaweedFS and Valkey; they are alternative installations. When ready to deploy a standalone example:

```bash
kubectl apply -k k8s/seaweedfs
kubectl -n infrastructure port-forward service/seaweedfs 8333:8333
```

For Helm installation, credentials, operator ordering, storage, and ingress settings, follow the [Kubernetes guide](k8s/README.md). Install individual catalog releases with a Helmfile selector.

## Validation and updates

Validation does not start containers, build images, install Helm releases, or apply Kubernetes resources.

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt

# Offline Compose parsing and catalog consistency checks.
python scripts/validate.py

# Also render charts/manifests and validate Kubernetes schemas.
# Requires helm, kustomize, and kubeconform on PATH; downloads pinned charts/schemas.
python scripts/validate.py --helm --kustomize --schema
```

The full check verifies chart archive SHA-256 digests, lints and renders all 21 catalog releases, renders nine Kustomize examples, checks workload references, and validates standard resources and operator custom resources. It targets Kubernetes 1.35 schemas; review your cluster's compatibility before installing cluster-level components. Original vendored charts are outside the maintained validation scope.

[GitHub Actions](.github/workflows/validate.yml) runs the same checks. [Renovate](renovate.json) proposes dependency updates when enabled for this repository. After changing a Helm chart version, refresh its lock metadata and rerun validation:

```bash
python scripts/update-chart-lock.py
python scripts/validate.py --helm --kustomize --schema
```

Major database upgrades require data migration. Read [upgrading existing installations](docs/upgrading.md) before using updated images with existing volumes. The version refresh itself does not migrate or start existing services.
