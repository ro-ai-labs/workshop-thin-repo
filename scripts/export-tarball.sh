#!/usr/bin/env bash
# scripts/export-tarball.sh
# Saves the local image to a tarball for offline distribution.
# Use only if ghcr.io is unreachable on workshop morning.
#   Receive end: docker load -i itss-workshop-<tag>.tar
set -euo pipefail

if [ ! -f /tmp/itss-build-vars.sh ]; then
  echo "ERROR: /tmp/itss-build-vars.sh not found."
  exit 1
fi
source /tmp/itss-build-vars.sh

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT="$ROOT/itss-workshop-${IMAGE_TAG##*:}.tar"

# Prefer local image; fall back to the pushed remote
if docker image inspect itss-workshop:local >/dev/null 2>&1; then
  src=itss-workshop:local
elif docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
  src="$IMAGE_TAG"
else
  echo "ERROR: no local image found. Build first with build-local.sh or pull."
  exit 1
fi

echo "Saving $src to $OUT ..."
docker save -o "$OUT" "$src"
ls -lh "$OUT"

echo ""
echo "Distribute $OUT via USB / Drive."
echo "Recipient command: docker load -i $(basename "$OUT")"
