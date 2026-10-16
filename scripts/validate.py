#!/usr/bin/env python3
"""Validate configuration without starting containers or contacting a Kubernetes cluster."""
import argparse
import hashlib
import io
import json
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]


class KubernetesLoader(yaml.SafeLoader):
    """Treat the YAML 1.2 scalar '=' in upstream CRD enums as a string."""


KubernetesLoader.add_constructor("tag:yaml.org,2002:value", KubernetesLoader.construct_scalar)


def run(command):
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=180)
    if result.returncode:
        raise RuntimeError(f"{' '.join(map(str, command))}\n{result.stdout}{result.stderr}")
    return result.stdout


def pinned(image):
    return "@sha256:" in image or (":" in image.rsplit("/", 1)[-1] and image.rsplit(":", 1)[-1] != "latest")


def read_yaml(path):
    with path.open() as handle:
        return list(yaml.load_all(handle, Loader=KubernetesLoader))


def require(tool):
    if not shutil.which(tool):
        raise RuntimeError(f"Install {tool} to run the requested checks")


def check_resources(documents, source):
    """Check portable workloads for reference and storage errors beyond YAML syntax."""
    objects = {d["metadata"]["name"]: d for d in documents if d and "metadata" in d}
    for document in documents:
        if not document or document.get("kind") not in {"Deployment", "StatefulSet", "DaemonSet"}:
            continue
        spec = document["spec"]
        pod = spec["template"]["spec"]
        labels = spec["template"]["metadata"]["labels"]
        assert all(labels.get(k) == v for k, v in spec["selector"]["matchLabels"].items()), source
        for container in pod["containers"]:
            assert pinned(container["image"]), f"Unpinned image in {source}"
            assert "readinessProbe" in container, f"Missing readiness probe in {source}"
        for volume in pod.get("volumes", []):
            for kind, key in [("secret", "secretName"), ("configMap", "name"), ("persistentVolumeClaim", "claimName")]:
                if kind in volume:
                    name = volume[kind][key]
                    assert name in objects, f"Missing {kind} {name} in {source}"
                    if kind == "persistentVolumeClaim":
                        assert objects[name]["kind"] == "PersistentVolumeClaim", source


def chart_directory(name, entry, cache):
    """Fetch a chart archive by the committed URL and verify its SHA-256 before extraction."""
    digest = entry["digest"]
    folder = cache / digest
    chart = folder / entry["chart"].split("/")[1]
    if chart.exists():
        return chart
    url = entry["url"]
    if not url.startswith("https://"):
        url = entry["repository"].rstrip("/") + "/" + url
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 infrastructure-utils-validator"})
    archive = urllib.request.urlopen(request, timeout=60).read()
    if hashlib.sha256(archive).hexdigest() != digest:
        raise RuntimeError(f"Chart checksum mismatch: {name}")
    folder.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(archive)) as package:
        package.extractall(folder, filter="data")
    return chart


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--helm", action="store_true", help="Download verified chart archives, lint and render them")
    parser.add_argument("--kustomize", action="store_true", help="Render the portable Kubernetes examples")
    parser.add_argument("--schema", action="store_true", help="Validate rendered standard resources with kubeconform")
    parser.add_argument("--output", type=Path, help="Directory for rendered resources (otherwise a temporary directory)")
    args = parser.parse_args()
    if args.schema and not (args.helm and args.kustomize):
        parser.error("--schema requires both --helm and --kustomize")
    require("docker")
    run(["docker", "compose", "version"])
    compose_files = sorted(ROOT.glob("docker/**/*compose*.y*ml"))
    count = 0
    for path in compose_files:
        if not path.stat().st_size:  # A preserved, empty Hera SSL override is a historical reference.
            continue
        document = read_yaml(path)[0]
        assert "version" not in document, f"Obsolete Compose version in {path}"
        for service in document["services"].values():
            if "image" in service:
                assert pinned(service["image"]), f"Unpinned image in {path}"
        run(["docker", "compose", "-f", str(path), "config", "--quiet"])
        count += 1
    print(f"Compose: {count} configurations valid", flush=True)

    state = read_yaml(ROOT / "k8s/helmfile.yaml")[0]
    lock = json.loads((ROOT / "k8s/catalog.lock.json").read_text())["releases"]
    assert {r["name"] for r in state["releases"]} == set(lock), "Catalog/lock release mismatch"
    for release in state["releases"]:
        entry = lock[release["name"]]
        assert release["version"] == entry["version"] and release["chart"] == entry["chart"], release["name"]
        assert len(entry["digest"]) == 64, release["name"]
        for values in release["values"]:
            read_yaml(ROOT / "k8s" / values)
    s3 = json.loads((ROOT / "docker/seaweedfs/s3.json").read_text())
    assert s3 == json.loads((ROOT / "k8s/seaweedfs/s3.json").read_text()), "SeaweedFS example credentials differ"
    assert s3["identities"] and all(i.get("credentials") for i in s3["identities"]), "S3 authentication missing"
    print(f"Catalog: {len(lock)} pinned charts and values consistent", flush=True)

    output = args.output or Path(tempfile.mkdtemp(prefix="infrastructure-utils-rendered-"))
    output.mkdir(parents=True, exist_ok=True)
    rendered = []
    if args.kustomize:
        require("kustomize")
        examples = sorted((ROOT / "k8s/apps").glob("*/kustomization.yaml")) + [ROOT / "k8s/seaweedfs/kustomization.yaml"]
        for path in examples:
            text = run(["kustomize", "build", str(path.parent)])
            documents = list(yaml.load_all(text, Loader=KubernetesLoader))
            check_resources(documents, path)
            target = output / f"app-{path.parent.name}.yaml"
            target.write_text(text)
            rendered.append(target)
        print(f"Kustomize: {len(examples)} examples rendered and references checked", flush=True)

    if args.helm:
        require("helm")
        cache = Path(tempfile.gettempdir()) / "infrastructure-utils-charts"
        for release in state["releases"]:
            name = release["name"]
            chart = chart_directory(name, lock[name], cache)
            flags = [flag for values in release["values"] for flag in ["-f", str(ROOT / "k8s" / values)]]
            run(["helm", "lint", str(chart), *flags])
            text = run(["helm", "template", name, str(chart), "--namespace", release["namespace"], "--kube-version", "1.35.0", "--include-crds", *flags])
            list(yaml.load_all(text, Loader=KubernetesLoader))
            target = output / f"helm-{name}.yaml"
            target.write_text(text)
            rendered.append(target)
            print(f"Helm: {name} linted and rendered", flush=True)

    if args.schema:
        require("kubeconform")
        print(run(["kubeconform", "-strict", "-summary", "-ignore-missing-schemas", "-kubernetes-version", "1.35.0", *map(str, rendered)]).strip())
        # Operator resources lack public JSON schemas; check them against the actual pinned CRDs.
        from jsonschema import Draft7Validator
        schemas = {}
        documents = [document for path in rendered for document in read_yaml(path) if document]
        for document in documents:
            if document.get("kind") == "CustomResourceDefinition":
                spec = document["spec"]
                for version in spec["versions"]:
                    schema = version.get("schema", {}).get("openAPIV3Schema")
                    if schema:
                        schemas[(spec["group"] + "/" + version["name"], spec["names"]["kind"])] = schema
        checked = 0
        for document in documents:
            key = (document.get("apiVersion"), document.get("kind"))
            if key in schemas:
                Draft7Validator(schemas[key]).validate(document)
                checked += 1
        print(f"Custom resources: {checked} validated against pinned operator CRDs", flush=True)
    if rendered:
        print(f"Rendered manifests: {output}")


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, RuntimeError, OSError, ValueError) as error:
        print(f"Validation failed: {error}", file=sys.stderr)
        sys.exit(1)
