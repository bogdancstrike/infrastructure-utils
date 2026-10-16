# Infrastructure Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Refresh the Docker and Kubernetes utility catalog and add SeaweedFS and optional development services without starting workloads.

**Architecture:** Preserve existing local edits and site-specific references. Pin verified upstream releases, migrate incompatible configuration, and introduce a maintained Kubernetes Helm catalog with separate values and portable Kustomize examples. Existing version-named charts remain historical migration references.

**Tech Stack:** Docker Compose, Helm, Helmfile, Kubernetes, Kustomize, Python 3.

---

### Task 1: Inventory and verify releases

**Files:** Existing `docker/**/docker-compose*.yml`, `k8s/*/Chart.yaml`, and override files.

- [x] Inspect current changes and repository instructions; preserve runtime data and certificates.
- [x] Query upstream release APIs, image tags, and Helm indexes; verify downloaded chart digests.
- [x] Record selected versions and sources in `docs/versions.md` and `k8s/catalog.lock.json`.

### Task 2: Refresh Docker configurations

**Files:** `docker/**/docker-compose*.yml`, Keycloak, Kafka, Jaeger, PostgreSQL, ELK, InfluxDB and persistence configuration.

- [x] Remove obsolete Compose version declarations and pin release tags, including Hera variants.
- [x] Migrate Kafka to the Apache image, Kafka UI to Kafbat, Jaeger to v2, Keycloak bootstrap variables, MySQL authentication, and InfluxDB initialization.
- [x] Repair data mounts, readiness checks, missing ELK pipelines, and incorrectly named Compose examples.
- [x] Run `docker compose -f <file> config --quiet` for every Compose file; this must not contact the daemon or start services.

### Task 3: Add optional services

**Files:** `docker/{seaweedfs,valkey,rabbitmq,mailpit,uptime-kuma}/`, matching `k8s/apps/` directories, `k8s/seaweedfs/`.

- [x] Add persistent SeaweedFS storage and authenticated S3 configuration for Docker and Kubernetes.
- [x] Add Valkey, RabbitMQ, Mailpit, and Uptime Kuma with explicit versions, persistent storage where needed, and readiness checks.
- [x] Document local endpoints, credentials, S3 smoke commands, and independent deployment commands.
- [x] Render all Kustomize examples and validate resource schemas without applying resources.

### Task 4: Introduce the maintained Kubernetes catalog

**Files:** `k8s/helmfile.yaml`, `k8s/values/*.yaml`, `k8s/catalog.lock.json`, `k8s/README.md`.

- [x] Pin supported upstream charts and separate portable configuration from the old site-specific values.
- [x] Add replacements for retired ingress-nginx and Promtail; avoid dependencies on unavailable Bitnami images.
- [x] Provide migration guidance for each old chart and retain appliance-specific examples as references.
- [x] Run `helm lint` and `helm template` for each catalog release, including chart dependencies.

### Task 5: Documentation and repeatable validation

**Files:** `README.md`, `docs/versions.md`, `scripts/validate.py`, `.github/workflows/validate.yml`, `renovate.json`.

- [x] Document selection, rendering, storage migration, and configuration requirements.
- [x] Add repeatable offline validation and automated dependency update configuration.
- [x] Run configuration, schema, shell syntax, and whitespace checks; inspect the final diff and confirm that no workloads were started.

Execution proceeds inline because the user requested implementation in this session. Checkpoints are validation results, not deployment approval gates. No commits, container starts, image pulls, Helm installs, or Kubernetes applies are part of this task.
