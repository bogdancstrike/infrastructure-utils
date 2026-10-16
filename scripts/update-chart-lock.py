#!/usr/bin/env python3
"""Refresh archive URLs/checksums for the versions selected in k8s/helmfile.yaml."""
import concurrent.futures
import hashlib
import json
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
state = yaml.safe_load((ROOT / 'k8s/helmfile.yaml').read_text())
repositories = {r['name']: r['url'].rstrip('/') for r in state['repositories']}


def fetch(url):
    request = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 infrastructure-utils'})
    return urllib.request.urlopen(request, timeout=90).read()


def index(item):
    name, url = item
    return name, yaml.safe_load(fetch(url + '/index.yaml'))['entries']


with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    indexes = dict(pool.map(index, repositories.items()))

lock = {}
for release in state['releases']:
    repo, chart = release['chart'].split('/', 1)
    version = str(release['version'])
    entry = next(e for e in indexes[repo][chart] if str(e['version']) == version)
    url = entry['urls'][0]
    if not url.startswith('https://'):
        url = repositories[repo] + '/' + url
    digest = hashlib.sha256(fetch(url)).hexdigest()
    if digest != entry['digest']:
        raise RuntimeError(f'Checksum mismatch for {chart}:{version}')
    lock[release['name']] = {
        'chart': release['chart'], 'version': version, 'appVersion': entry.get('appVersion'),
        'repository': repositories[repo], 'url': url, 'digest': digest,
    }
    print(f'Verified {chart}:{version}', flush=True)

from datetime import date
result = {'verifiedOn': date.today().isoformat(), 'releases': lock}
(ROOT / 'k8s/catalog.lock.json').write_text(json.dumps(result, indent=2) + '\n')
