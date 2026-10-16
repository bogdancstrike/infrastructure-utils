# SeaweedFS on Kubernetes

Choose the standalone Kustomize example or the upstream Helm chart. Both provide a single-node development instance with persistent storage and an authenticated S3 gateway. A default StorageClass is required; override PVC settings for your cluster.

## Kustomize

From the repository root:

```bash
# Inspect resources; this does not contact the cluster.
kubectl kustomize k8s/seaweedfs
# When wanted, create the deployment, Service, configuration, Secret and 20 Gi PVC.
kubectl apply -k k8s/seaweedfs
kubectl -n infrastructure port-forward service/seaweedfs 8333:8333 9333:9333 8888:8888
```

Edit `s3.json` before deployment to replace the example credentials. Kustomize generates the referenced Secret; the server loads it with `-s3.config`. `filer.toml` keeps filer metadata in `/data/filerldb2` on the same persistent volume as the object volumes and master metadata. The Deployment uses `Recreate` to avoid concurrent access to its ReadWriteOnce volume.

The S3 API is at `http://localhost:8333`, master UI at `http://localhost:9333`, and filer UI at `http://localhost:8888` while port forwarding. Cluster clients use `http://seaweedfs.infrastructure.svc.cluster.local:8333`. Master/filer APIs do not enforce S3 credentials; expose them only to trusted clients.

## Helm alternative

The catalog uses the pinned upstream chart's `allInOne` mode, a 20 Gi PVC, and an existing S3 configuration Secret. From the repository root:

```bash
helmfile -f k8s/helmfile.yaml --selector name=seaweedfs template
# Edit the example credential JSON before applying this Secret.
kubectl create namespace infrastructure --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/seaweedfs/helm-secret.example.yaml
helmfile -f k8s/helmfile.yaml --selector name=seaweedfs sync
kubectl -n infrastructure port-forward service/seaweedfs-all-in-one 8333:8333
```

The Helm Secret key is `seaweedfs_s3_config`; the standalone Secret uses `s3.json`. Do not interchange the examples without adjusting the key. The Helm all-in-one Service is named `seaweedfs-all-in-one` and its filer configuration comes from the pinned image. Set `WEED_LEVELDB2_DIR=/data/filerldb2` explicitly in the Helm values to keep metadata on the persistent volume.

For S3 credentials, AWS CLI smoke commands and SDK path-style configuration, see the [Docker SeaweedFS guide](../../docker/seaweedfs/README.md). Credentials default to `seaweedfs-admin` / `development-secret-change-me`. These examples use a single storage node without replication. For a shared environment, split master, volume, filer and S3 services; configure replication, an appropriate metadata backend, authentication and TLS.
