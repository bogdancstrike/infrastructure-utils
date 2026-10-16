# Verified versions

Release and registry metadata checked on **2026-10-16**. Versions are explicit to make changes reviewable. Supported major lines are selected deliberately: MySQL 8.4 LTS, MariaDB 11.8 LTS, MongoDB 8.0, and InfluxDB 2.x for Flux. A release tag can be newer than a chart's default application version; image overrides are recorded in `k8s/values`.

Docker manifest inspection verified most publisher images directly. Docker Hub rate limiting prevented some manifest requests; their exact tags were checked through Docker Hub's tag API. No image layers were pulled and no images were built. The optional MinIO image is a local source build, not a published registry image.

## Docker images

| Image | Selected tag | Release / registry source |
| --- | --- | --- |
| `adminer` | `6.1.2` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/adminer/tags/6.1.2) |
| `apache/kafka` | `4.3.1` | [Publisher metadata](https://hub.docker.com/v2/repositories/apache/kafka/tags/4.3.1) |
| `axllent/mailpit` | `v1.31.6` | [Publisher metadata](https://github.com/axllent/mailpit/releases/tag/v1.31.6) |
| `chrislusf/seaweedfs` | `4.48` | [Publisher metadata](https://github.com/seaweedfs/seaweedfs/releases/tag/4.48) |
| `curlimages/curl` | `8.23.0` | [Publisher metadata](https://github.com/curl/curl/releases/tag/curl-8_23_0) |
| `docker.elastic.co/beats/filebeat` | `9.5.5` | [Publisher metadata](https://github.com/elastic/elasticsearch/releases/tag/v9.5.5) |
| `docker.elastic.co/elasticsearch/elasticsearch` | `9.5.5` | [Publisher metadata](https://github.com/elastic/elasticsearch/releases/tag/v9.5.5) |
| `docker.elastic.co/kibana/kibana` | `9.5.5` | [Publisher metadata](https://github.com/elastic/elasticsearch/releases/tag/v9.5.5) |
| `docker.elastic.co/logstash/logstash` | `9.5.5` | [Publisher metadata](https://github.com/elastic/elasticsearch/releases/tag/v9.5.5) |
| `docker.io/mailserver/docker-mailserver` | `16.0.1` | [Publisher metadata](https://github.com/docker-mailserver/docker-mailserver/releases/tag/v16.0.1) |
| `docker.redpanda.com/redpandadata/console` | `v3.12.0` | [Publisher metadata](https://github.com/redpanda-data/console/releases/tag/v3.12.0) |
| `docker.redpanda.com/redpandadata/redpanda` | `v26.2.2` | [Publisher metadata](https://github.com/redpanda-data/redpanda/releases/tag/v26.2.2) |
| `dpage/pgadmin4` | `9.18` | [Publisher metadata](https://hub.docker.com/v2/repositories/dpage/pgadmin4/tags/9.18) |
| `ghcr.io/kafbat/kafka-ui` | `v1.5.0` | [Publisher metadata](https://github.com/kafbat/kafka-ui/releases/tag/v1.5.0) |
| `gitea/gitea` | `28.1.0` | [Publisher metadata](https://github.com/go-gitea/gitea/releases/tag/v28.1.0) |
| `gitlab/gitlab-ce` | `19.4.2-ce.0` | [Publisher metadata](https://hub.docker.com/v2/repositories/gitlab/gitlab-ce/tags/19.4.2-ce.0) |
| `gitlab/gitlab-runner` | `alpine-v19.4.1` | [Publisher metadata](https://hub.docker.com/v2/repositories/gitlab/gitlab-runner/tags/alpine-v19.4.1) |
| `grafana/grafana` | `13.2.4` | [Publisher metadata](https://github.com/grafana/grafana/releases/tag/v13.2.4) |
| `influxdb` | `2.9.1` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/influxdb/tags/2.9.1) |
| `infrastructure-utils/minio` | `RELEASE.2025-10-15T17-29-55Z` | [Publisher metadata](https://github.com/minio/minio/releases/tag/RELEASE.2025-10-15T17-29-55Z) |
| `jaegertracing/jaeger` | `2.22.0` | [Publisher metadata](https://github.com/jaegertracing/jaeger/releases/tag/v2.22.0) |
| `jc21/nginx-proxy-manager` | `2.16.0` | [Publisher metadata](https://github.com/NginxProxyManager/nginx-proxy-manager/releases/tag/v2.16.0) |
| `kurrentplatform/kurrentdb` | `26.2.2` | [Publisher metadata](https://github.com/kurrent-io/KurrentDB/releases/tag/v26.2.2) |
| `louislam/uptime-kuma` | `2.5.6` | [Publisher metadata](https://github.com/louislam/uptime-kuma/releases/tag/2.5.6) |
| `maildev/maildev` | `3.0.0` | [Publisher metadata](https://github.com/maildev/maildev/releases/tag/maildev%403.0.0) |
| `mariadb` | `11.8.9` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/mariadb/tags/11.8.9) |
| `mongo-express` | `1.0.2` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/mongo-express/tags/1.0.2) |
| `mongo` | `8.0.34` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/mongo/tags/8.0.34) |
| `mysql` | `8.4.11` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/mysql/tags/8.4.11) |
| `nginx` | `1.30.6-alpine` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/nginx/tags/1.30.6-alpine) |
| `otel/opentelemetry-collector-contrib` | `0.162.0` | [Publisher metadata](https://github.com/open-telemetry/opentelemetry-collector-releases/releases/tag/v0.162.0) |
| `phpmyadmin` | `5.2.3` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/phpmyadmin/tags/5.2.3) |
| `postfixadmin` | `4.0.5-apache` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/postfixadmin/tags/4.0.5-apache) |
| `postgres` | `18.6` | [Publisher metadata](https://hub.docker.com/v2/repositories/library/postgres/tags/18.6) |
| `prom/prometheus` | `v3.15.0` | [Publisher metadata](https://github.com/prometheus/prometheus/releases/tag/v3.15.0) |
| `quay.io/keycloak/keycloak` | `26.8.1` | [Publisher metadata](https://github.com/keycloak/keycloak/releases/tag/26.8.1) |
| `rabbitmq` | `4.3.6-management-alpine` | [Publisher metadata](https://github.com/rabbitmq/rabbitmq-server/releases/tag/v4.3.6) |
| `redis/redisinsight` | `3.8.0` | [Publisher metadata](https://github.com/redis/RedisInsight/releases/tag/3.8.0) |
| `redis` | `8.10.2` | [Publisher metadata](https://github.com/redis/redis/releases/tag/8.10.2) |
| `sonatype/nexus3` | `3.97.0` | [Publisher metadata](https://github.com/sonatype/nexus-public/releases/tag/release-3.97.0-13) |
| `traefik` | `v3.7.15` | [Publisher metadata](https://github.com/traefik/traefik/releases/tag/v3.7.15) |
| `valkey/valkey` | `9.1.2-alpine` | [Publisher metadata](https://github.com/valkey-io/valkey/releases/tag/9.1.2) |

The MinIO source build uses Go `1.27.2-alpine` and Alpine `3.24.2`; its source tag remains frozen. The Gammu Dockerfile uses Debian `13.7-slim` and installs the distribution's Gammu packages.

## Helm charts

`k8s/catalog.lock.json` records each archive URL, chart version, app version and SHA-256 digest. Archive contents are verified against upstream Helm index checksums. The selected chart versions are:

| Release | Chart version | Chart app version | Upstream |
| --- | --- | --- | --- |
| `cilium` | `1.20.3` | `1.20.3` | [Chart repository](https://helm.cilium.io) |
| `cert-manager` | `v1.21.2` | `v1.21.2` | [Chart repository](https://charts.jetstack.io) |
| `monitoring` | `92.10.0` | `v0.94.1` | [Chart repository](https://prometheus-community.github.io/helm-charts) |
| `alloy` | `1.13.1` | `v1.20.1` | [Chart repository](https://grafana.github.io/helm-charts) |
| `loki` | `7.3.0` | `3.6.12` | [Chart repository](https://grafana.github.io/helm-charts) |
| `metallb` | `0.16.1` | `v0.16.1` | [Chart repository](https://metallb.github.io/metallb) |
| `metrics-server` | `3.14.0` | `0.9.0` | [Chart repository](https://kubernetes-sigs.github.io/metrics-server) |
| `traefik` | `42.0.0` | `v3.7.14` | [Chart repository](https://traefik.github.io/charts) |
| `gitea` | `12.7.0` | `1.27.0` | [Chart repository](https://dl.gitea.com/charts) |
| `nextcloud` | `9.4.0` | `35.0.1` | [Chart repository](https://nextcloud.github.io/helm) |
| `vault` | `0.34.1` | `2.0.4` | [Chart repository](https://helm.releases.hashicorp.com) |
| `vault-secrets-operator` | `1.6.0` | `1.6.0` | [Chart repository](https://helm.releases.hashicorp.com) |
| `trivy-operator` | `0.37.0` | `0.35.0` | [Chart repository](https://aquasecurity.github.io/helm-charts) |
| `ceph-csi-rbd` | `3.18.1` | `3.18.1` | [Chart repository](https://ceph.github.io/csi-charts) |
| `ceph-csi-cephfs` | `3.18.1` | `3.18.1` | [Chart repository](https://ceph.github.io/csi-charts) |
| `seaweedfs` | `4.48.0` | `4.48` | [Chart repository](https://seaweedfs.github.io/seaweedfs/helm) |
| `sonarqube` | `2026.5.1002` | `2026.5.2` | [Chart repository](https://SonarSource.github.io/helm-chart-sonarqube) |
| `strimzi` | `1.3.0` | `1.3.0` | [Chart repository](https://strimzi.io/charts) |
| `cloudnative-pg` | `0.29.1` | `1.30.1` | [Chart repository](https://cloudnative-pg.github.io/charts) |
| `kafka-ui` | `1.6.5` | `v1.5.0` | [Chart repository](https://kafbat.github.io/helm-charts) |
| `valkey` | `0.12.0` | `9.1.2` | [Chart repository](https://valkey.io/valkey-helm) |

The Gitea, Grafana, Loki, Alloy, Traefik, SeaweedFS, Nextcloud, Kafka UI and Valkey values explicitly select their verified image releases. Other upstream chart images follow the pinned chart defaults. Chart application versions are upstream metadata, not a promise that all optional sidecars have that version.

## Validation tools

The CI workflow pins Helm `4.3.1`, Kustomize `5.8.3`, kubeconform `0.8.0` and Python `3.13`, with the Python validation dependencies in `requirements-dev.txt`. Kubernetes resources are rendered and schema-checked for Kubernetes `1.35.0`.

## Keeping versions current

Renovate tracks maintained Compose files, Dockerfiles, portable Kubernetes workloads, Helmfile and values files, Python requirements, and GitHub Actions. Existing vendored chart trees are historical references and excluded from those updates. Chart updates require refreshing `k8s/catalog.lock.json` with `python scripts/update-chart-lock.py`; the validator intentionally rejects a stale lock.

Review [upgrade notes](upgrading.md) before changing database majors or applying chart updates to existing installations. Release checks and schema validation do not exercise service startup or migrate stored data.
