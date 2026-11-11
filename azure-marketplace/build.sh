#!/usr/bin/env bash
# Assembles the Azure Marketplace Kubernetes-application bundle sources into ./dist.
# Usage: ./build.sh <bundle-version #.#.#>
# Afterwards run Microsoft's packaging tool against ./dist on a Linux AMD64 host with Docker
# (see README.md). Requires: az (logged in, AcrPull on the registry), python3.
set -euo pipefail
cd "$(dirname "$0")"
BUNDLE_VERSION="${1:?bundle version (#.#.#) required}"
REGISTRY="${REGISTRY:-windmillmarketplace}"
CHART_DIR=../charts/windmill
APP_VERSION="$(awk '/^appVersion:/{print $2}' "$CHART_DIR/Chart.yaml")"
CHART_VERSION="$(awk '/^version:/{print $2}' "$CHART_DIR/Chart.yaml")"

digest() { # digest of the linux/amd64 image for <repo>:<tag>; the marketplace accepts AMD64 only
  az acr manifest show "$REGISTRY.azurecr.io/$1" -o json | python3 -c '
import json,sys
m=json.load(sys.stdin)
if "manifests" in m:
    d=[x["digest"] for x in m["manifests"] if x.get("platform",{}).get("architecture")=="amd64" and x.get("platform",{}).get("os")=="linux"]
    assert len(d)==1, "expected exactly one linux/amd64 manifest, got %r" % d
    print(d[0])
else:
    sys.exit("not a manifest list; resolve the digest with: az acr manifest show-metadata")'
}
D_WINDMILL="$(digest "windmill-ee:$APP_VERSION")"
D_EXTRA="$(digest "windmill-extra:$APP_VERSION")"
D_POSTGRES="$(digest "postgres:18")"

rm -rf dist && mkdir -p dist/windmill-aks/charts
cp createUiDefinition.json mainTemplate.json dist/
sed "s/__BUNDLE_VERSION__/$BUNDLE_VERSION/" manifest.yaml > dist/manifest.yaml
sed -e "s/__BUNDLE_VERSION__/$BUNDLE_VERSION/" -e "s/__APP_VERSION__/$APP_VERSION/" -e "s/__CHART_VERSION__/$CHART_VERSION/" \
  windmill-aks/Chart.yaml > dist/windmill-aks/Chart.yaml
sed -e "s/__DIGEST_WINDMILL__/$D_WINDMILL/" -e "s/__DIGEST_EXTRA__/$D_EXTRA/" -e "s/__DIGEST_POSTGRES__/$D_POSTGRES/" \
  windmill-aks/values.yaml > dist/windmill-aks/values.yaml

# The bundle may not contain .tgz archives or fetch charts at runtime, so the Windmill chart
# is copied in unpacked and its optional MinIO dependency (disabled by default) is dropped.
cp -R "$CHART_DIR" dist/windmill-aks/charts/windmill
rm -rf dist/windmill-aks/charts/windmill/{Chart.lock,ci,charts,README.md.gotmpl}
python3 - dist/windmill-aks/charts/windmill/Chart.yaml <<'PY'
import re,sys
p=sys.argv[1]; s=open(p).read()
out=re.sub(r'dependencies:\n(?:[ \t]+.*\n)+','',s)
assert out!=s, "MinIO dependency block not found; update build.sh"
open(p,'w').write(out)
PY
echo "dist/ ready: bundle $BUNDLE_VERSION, Windmill $APP_VERSION (chart $CHART_VERSION)"
