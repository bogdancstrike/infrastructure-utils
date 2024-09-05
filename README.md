# Docker Compose Utilities for Rapid Deployment

This repository contains Docker Compose files and configuration setups for fast and convenient deployment of various development, monitoring, and infrastructure tools. Each folder includes a `docker-compose.yml` file with optimized configurations to help you quickly spin up instances of the tools with minimal setup.

## Tools Included

The following tools are supported with their respective configurations in the repository:

- **Gitea**: A lightweight Git server.
- **GitLab**: Git repository management and CI/CD pipeline automation.
- **Grafana & Prometheus**: Monitoring and alerting setup.
- **InfluxDB & Grafana**: Time series database with Grafana visualization.
- **Jaeger & OpenTelemetry**: Distributed tracing system with telemetry support.
- **Kafka**: Distributed streaming platform. Includes Kafka-UI
- **Keycloak**: Identity and access management (IAM) solution.
- **Kibana, Elasticsearch, & Logstash**: ELK stack for logging and search analytics.
- **MailDev**: Simple email service for development.
- **MariaDB & Adminer**: MariaDB database with Adminer for web-based administration.
- **Minio**: High-performance object storage system with UI.
- **MongoDB**: NoSQL database with Mongo Express UI.
- **MySQL**: Relational database management system.
- **Nginx & Proxy Manager**: Web server and reverse proxy management.
- **Nginx-eID MTLS**: Mutual TLS with electronic identification.
- **Postfix**: Mail transfer agent (MTA).
- **Postgres**: PostgreSQL relational database. Includes pg-admin UI
- **Redis**: In-memory key-value data store. Includes redis-commander UI
- **Redpanda**: Modern streaming data platform, compatible with Kafka API.
  - **redpanda-cloud**
  - **redpanda-single TLS**
  - **redpanda-single**
- **Nexus**: Repository manager.
- **Traefik**: Edge router and load balancer with UI.

## Usage

Each tool has its own folder containing the necessary `docker-compose.yml` file and any associated configuration files. The steps to deploy any of the tools are as follows:

1. Clone the repository:

```bash
git https://github.com/bogdancstrike/infrastructure-utils
cd infrastructure-utils
```

2. Choose project to deploy

```bash
cd gitea
```

3. Run docker compose

```code
docker compose up
```

## Contributions

We welcome contributions to this repository. You can contribute in the following ways:

- **Adding New Tools**: If there's a tool you believe should be included, feel free to add a new folder with the `docker-compose.yml` and related configurations.
- **Improving Configurations**: If you find any configurations that could be optimized or improved, submit a pull request with your changes.
- **Reporting Issues**: If you encounter any problems, feel free to open an issue describing the problem in detail. This will help us maintain the repository.
- **Documentation Updates**: If any part of the documentation (including this README) could be improved, please propose the changes.


Thank you for using and contributing to this repository! Hope it helps make your tool deployments faster and more efficient.