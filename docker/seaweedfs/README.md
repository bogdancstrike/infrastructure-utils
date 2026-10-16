# SeaweedFS

SeaweedFS provides an S3-compatible alternative to MinIO. This development example runs the master, volume server, filer and S3 gateway in one container. A named volume persists both objects and filer metadata. It is a single-node setup without replication.

From this directory, `docker compose config --quiet` validates the configuration. When wanted, start it with `docker compose up -d`. Edit `s3.json` to replace the example credentials before sharing the endpoint. The JSON file is mounted as a Compose secret; environment variables inside it are not expanded.

| Endpoint | URL |
| --- | --- |
| S3 API | http://localhost:8333 |
| Master UI | http://localhost:9333 |
| Filer UI | http://localhost:8888 |

Use path-style addressing in S3 SDKs (`forcePathStyle: true` in AWS SDK for JavaScript). The filer and master UIs bypass S3 authentication and are bound to loopback. Containers on this Compose network use `http://seaweedfs:8333`.

After starting the service, these AWS CLI commands exercise bucket creation and object storage:

```bash
export AWS_ACCESS_KEY_ID=seaweedfs-admin
export AWS_SECRET_ACCESS_KEY=development-secret-change-me
export AWS_DEFAULT_REGION=us-east-1
aws --endpoint-url http://localhost:8333 s3 mb s3://development
printf 'hello seaweedfs\n' > /tmp/seaweedfs-example.txt
aws --endpoint-url http://localhost:8333 s3 cp /tmp/seaweedfs-example.txt s3://development/example.txt
aws --endpoint-url http://localhost:8333 s3 cp s3://development/example.txt -
```

The Kubernetes equivalents are in `../../k8s/seaweedfs` (Kustomize) and `../../k8s/values/seaweedfs.yaml` (Helm). Migrate MinIO objects through the S3 API, for example with `rclone sync`; SeaweedFS cannot reuse MinIO's data directory.
