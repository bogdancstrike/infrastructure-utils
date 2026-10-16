# Legacy MinIO example

The original community container images are no longer available at the old registry paths. This example builds the last tagged upstream source release instead of depending on a missing image. Its source release is frozen; the Go compiler and runtime base are separately pinned. It is retained for compatibility experiments; use [SeaweedFS](../seaweedfs) for new S3 development environments.

`docker compose config --quiet` validates the configuration without building or starting anything. An intentional `docker compose up --build -d` builds the source before starting MinIO. Existing objects remain in `minio_data`; back up and migrate objects through S3 before switching implementations. The final source release has a reduced web console compared with older MinIO releases.
