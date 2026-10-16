# Kubernetes utilities

The maintained entry points are `helmfile.yaml`, `values/`, `apps/`, and `seaweedfs/`. Chart archives are fetched from upstream and pinned by version and SHA-256 in `catalog.lock.json`. Version-named directories preserve the original vendored charts and local environment overrides as historical references.

## Pinned Helm catalog

Select one release with `helmfile -f k8s/helmfile.yaml --selector name=<release> template` from the repository root. Install it only when wanted with the same selector and `sync`. The catalog itself does not start workloads; a sync without a selector requests the entire catalog.

| Release | Namespace | Chart | Version | Values |
| --- | --- | --- | --- | --- |
| `cilium` | `kube-system` | `cilium/cilium` | `1.20.3` | [cilium](values/cilium.yaml) |
| `cert-manager` | `cert-manager` | `jetstack/cert-manager` | `v1.21.2` | [cert-manager](values/cert-manager.yaml) |
| `monitoring` | `monitoring` | `prometheus-community/kube-prometheus-stack` | `92.10.0` | [monitoring](values/monitoring.yaml) |
| `alloy` | `monitoring` | `grafana/alloy` | `1.13.1` | [alloy](values/alloy.yaml) |
| `loki` | `monitoring` | `grafana/loki` | `7.3.0` | [loki](values/loki.yaml) |
| `metallb` | `metallb-system` | `metallb/metallb` | `0.16.1` | [metallb](values/metallb.yaml) |
| `metrics-server` | `kube-system` | `metrics-server/metrics-server` | `3.14.0` | [metrics-server](values/metrics-server.yaml) |
| `traefik` | `traefik` | `traefik/traefik` | `42.0.0` | [traefik](values/traefik.yaml) |
| `gitea` | `infrastructure` | `gitea/gitea` | `12.7.0` | [gitea](values/gitea.yaml) |
| `nextcloud` | `infrastructure` | `nextcloud/nextcloud` | `9.4.0` | [nextcloud](values/nextcloud.yaml) |
| `vault` | `infrastructure` | `hashicorp/vault` | `0.34.1` | [vault](values/vault.yaml) |
| `vault-secrets-operator` | `infrastructure` | `hashicorp/vault-secrets-operator` | `1.6.0` | [vault-secrets-operator](values/vault-secrets-operator.yaml) |
| `trivy-operator` | `infrastructure` | `aqua/trivy-operator` | `0.37.0` | [trivy-operator](values/trivy-operator.yaml) |
| `ceph-csi-rbd` | `infrastructure` | `ceph-csi/ceph-csi-rbd` | `3.18.1` | [ceph-csi-rbd](values/ceph-csi-rbd.yaml) |
| `ceph-csi-cephfs` | `infrastructure` | `ceph-csi/ceph-csi-cephfs` | `3.18.1` | [ceph-csi-cephfs](values/ceph-csi-cephfs.yaml) |
| `seaweedfs` | `infrastructure` | `seaweedfs/seaweedfs` | `4.48.0` | [seaweedfs](values/seaweedfs.yaml) |
| `sonarqube` | `infrastructure` | `sonarqube/sonarqube` | `2026.5.1002` | [sonarqube](values/sonarqube.yaml) |
| `strimzi` | `infrastructure` | `strimzi/strimzi-kafka-operator` | `1.3.0` | [strimzi](values/strimzi.yaml) |
| `cloudnative-pg` | `cnpg-system` | `cloudnative-pg/cloudnative-pg` | `0.29.1` | [cloudnative-pg](values/cloudnative-pg.yaml) |
| `kafka-ui` | `infrastructure` | `kafbat/kafka-ui` | `1.6.5` | [kafka-ui](values/kafka-ui.yaml) |
| `valkey` | `infrastructure` | `valkey/valkey` | `0.12.0` | [valkey](values/valkey.yaml) |

All examples use cluster-local service names and default storage provisioning. Configure ingress hostnames, TLS, StorageClasses, external databases, credentials, and resources for your environment. The original private addresses and domains are not inherited automatically.

## Render and install one service

From the repository root:

Mailpit is a standalone Kustomize example; render it with:

```bash
kubectl kustomize k8s/apps/mailpit
```

For a chart in the catalog, such as Loki:

```bash
helmfile -f k8s/helmfile.yaml --selector name=loki template
# When ready:
helmfile -f k8s/helmfile.yaml --selector name=loki sync
```

For a standalone example:

```bash
kubectl kustomize k8s/apps/rabbitmq
# When ready:
kubectl apply -k k8s/apps/rabbitmq
kubectl -n infrastructure port-forward service/rabbitmq 15672:15672
```

The standalone examples create the shared `infrastructure` namespace and generate Secrets/ConfigMaps with Kustomize. Replace sample secret literals before deployment. Do not delete the shared namespace while other examples use it. All persistent workloads use a single replica and `Recreate` updates so a ReadWriteOnce volume is detached before replacement.

| Standalone example | Service ports | Storage / behavior |
| --- | --- | --- |
| [SeaweedFS](seaweedfs) | S3 8333, master 9333, filer 8888 | 20 Gi PVC; persistent objects and filer metadata; authenticated S3 |
| [Valkey](apps/valkey) | 6379 | 5 Gi PVC; password authentication and append-only persistence |
| [RabbitMQ](apps/rabbitmq) | AMQP 5672, management 15672 | 5 Gi PVC; `development` / `development-password` |
| [Mailpit](apps/mailpit) | SMTP 1025, HTTP 8025 | 5 Gi PVC; SMTP capture accepts development credentials |
| [Uptime Kuma](apps/uptime-kuma) | HTTP 3001 | 5 Gi PVC; create administrator on first use |
| [Keycloak](apps/keycloak) | HTTP 8080, management 9000 | 5 Gi PVC; development mode; `admin` / `development-password` |
| [Jaeger v2](apps/jaeger) | UI 16686, OTLP 4317/4318 | In-memory traces; explicit config and health probes |
| [PostgreSQL](apps/postgres) | 5432 | 10 Gi PVC; database/user `development`, password `development-password` |
| [Kafka](apps/kafka) | Internal Kafka listener 9092 | 10 Gi retained broker PVC; requires Strimzi first |

## Dependencies and environment setup

- **SeaweedFS / Valkey:** Helm and Kustomize are alternative installations. Follow the [SeaweedFS guide](seaweedfs/README.md) for the Helm Secret and S3 endpoints.
- **Kafka:** Install the `strimzi` release in `infrastructure`, wait for its operator and CRDs, then apply `apps/kafka`. Install `kafka-ui` afterwards. The sample uses one KRaft controller/broker; replication factors are set to one. The current Strimzi CRDs use `kafka.strimzi.io/v1`.
- **PostgreSQL:** `apps/postgres` is a standalone development database. `cloudnative-pg` installs the alternative operator, which requires a separate Cluster resource. Existing Crunchy PGO clusters require an explicit database migration; their CRDs are not interchangeable.
- **SonarQube:** Uses the standalone PostgreSQL example's `development` database and credentials. Install that database first, or replace `jdbcOverwrite` with your external database details. Initialize the database for this application alone when using the example. Configure node `vm.max_map_count` according to SonarQube requirements before production use.
- **Gitea / Nextcloud:** Single-replica examples use persistent SQLite to avoid old Bitnami dependencies. Use a supported external PostgreSQL database and Valkey for larger or production deployments. Nextcloud trusts `nextcloud.localhost`; send that Host header or configure your domain before accessing it through a local port forward.
- **Loki / Alloy:** Install Loki before Alloy. Loki uses filesystem storage and a retained PVC; Alloy discovers pods on its own node and sends their logs through the Loki gateway. The monitoring chart provisions a Loki datasource in Grafana. Loki authentication is disabled for this internal development setup.
- **Vault:** Persistent standalone server; initialization and unseal are manual. Its example listener uses internal HTTP. Configure TLS and a supported unseal mechanism for shared environments. Install Vault before Vault Secrets Operator and configure authentication resources separately.
- **cert-manager:** Includes CRDs. Define issuers separately with your ACME or private CA configuration.
- **Cilium:** A cluster networking component. Carry over the API server endpoint, IPAM, routing and kube-proxy settings appropriate to your cluster. Upgrade through supported minor releases.
- **Traefik / MetalLB:** Traefik requests a LoadBalancer Service and does not claim the default IngressClass. On bare metal, configure MetalLB IPAddressPool/L2Advertisement resources for your network. Migrate existing nginx-specific annotations and classes explicitly.
- **Ceph CSI:** Charts intentionally create no cluster connection, credentials or StorageClass. Fill in Ceph monitor addresses, cluster ID, pool/filesystem, and Secrets before installation; do not use the old `canary` chart defaults.
- **metrics-server:** Uses certificate validation. Add cluster-specific arguments only if required by your kubelet certificates.

## Original chart migration map

| Original directory | Maintained entry point / migration |
| --- | --- |
| `ceph-csi-cephfs`, `ceph-csi-rbd` | Stable upstream Ceph CSI releases; copy monitor, pool and Secret settings into the new values |
| `cert-manager-v1.15.1` | `cert-manager` release; review CRD upgrade notes and issuer compatibility |
| `cilium-1.16.0` | `cilium` release; upgrade minor by minor and retain cluster-specific networking settings |
| `ingress-nginx-4.11.0`, `ingress-nginx-private-4.11.0` | Traefik; ingress-nginx retired in March 2026; migrate classes, annotations, TLS and public/private routing explicitly |
| `jaeger-1.64.0` | `apps/jaeger`; explicit Jaeger v2 configuration, no old storage subcharts |
| `kafka-28.0.4` | Strimzi and `apps/kafka`; transfer topics/data rather than reusing Bitnami data directories |
| `kafka-ui-1.4.0` | Maintained Kafbat `kafka-ui` release |
| `keycloak-24.0.5` | `apps/keycloak`; upstream image and current bootstrap settings |
| `kube-prometheus-stack-61.8.0` | `monitoring` release; follow upstream CRD and Prometheus migration instructions |
| `loki-3.1.1`, `loki-stack` | `loki` and `alloy`; preserve existing Loki schema history and storage settings during migration |
| `promtail-3.0.0` | Alloy; Promtail reached end of life on 2026-03-02 |
| `metallb-0.14.7` | `metallb` release; preserve address pools and advertisements |
| `metrics-server-3.12.1` | `metrics-server` release |
| `gitea-10.3.0` | `gitea` release; migrate old PostgreSQL/Redis dependencies explicitly; SQLite example is for a new instance |
| `nextcloud-30.0.0`, `nextcloud-30.0.1` | `nextcloud` release; upgrade Nextcloud one supported major at a time; do not skip directly from 30 to 35 on existing data |
| `nginx-18.3.2` | Traefik for routing, or the upstream Nginx image for an application server; the retired Bitnami image is not replaced in-place |
| `pgo-5.5.2`, `pg-perso` | Existing PGO manifests remain reference-only; use `apps/postgres` or CloudNativePG for new setups and migrate databases explicitly |
| `redis-20.1.5`, `redis-cluster-11.1.0` | Valkey; transfer data explicitly; the new single-instance example does not replace Sentinel/Cluster topology automatically |
| `sonarqube-10.7.0` | `sonarqube` release; follow the supported database/application upgrade sequence |
| `trivy-operator-0.24.1` | `trivy-operator` release |
| `vault-0.28.0`, `vso-0.7.0` | `vault` and `vault-secrets-operator` releases; preserve seal, authentication and storage settings |
| `common` | Old chart dependency library; new application examples avoid the original Bitnami dependencies |
| `ejbca-community-1.0.3`, `localkms-3.11.7`, `luna-client-proxy` | Appliance / PKI integration references; require vendor-specific licensing, hardware, certificates and migration procedures |
| `redmine-5.1.3`, `taiga-0.0.11` | Original application references; no verified maintained chart replacement selected |

The original charts are not included in current validation or automatic dependency updates. Their historical files and credentials remain untouched as migration inputs. No existing cluster resources are updated by changing this repository.

## Validation and maintenance

From the repository root, run `python scripts/validate.py --helm --kustomize --schema` after installing `requirements-dev.txt` and the Helm, Kustomize and kubeconform tools. This verifies locked archive digests, lints/templates all releases, checks portable workload references and validates schemas. CRDs from the pinned operator charts validate the Kafka and other operator resources that kubeconform cannot validate with standard Kubernetes schemas.

After editing chart versions in `helmfile.yaml`, run `python scripts/update-chart-lock.py` to refresh verified download URLs and SHA-256 digests. Keep image overrides and portable apps in sync where a service is offered through both approaches. Review migration notes for every major update.

References: [ingress-nginx retirement](https://kubernetes.io/blog/2026/01/29/ingress-nginx-statement/), [Promtail to Alloy](https://grafana.com/docs/alloy/latest/set-up/migrate/from-promtail/), [Bitnami catalog changes](https://github.com/bitnami/charts/issues/35164).
