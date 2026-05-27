#!/usr/bin/env bash
# scripts/export-tarball.sh
# Saves itss-workshop:local to a tarball for offline-fallback distribution.
# Recipient: docker load -i itss-workshop-2026.05.28.tar
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TAG="${1:-2026.05.28}"
OUT="$ROOT/itss-workshop-${TAG}.tar"

if ! docker image inspect itss-workshop:local >/dev/null 2>&1; then
  echo "ERROR: itss-workshop:local not found locally."
  echo "       Build first with: bash scripts/build-local.sh"
  exit 1
fi

echo "Saving itss-workshop:local to $OUT ..."
docker save -o "$OUT" itss-workshop:local
ls -lh "$OUT"

echo ""
echo "Distribute $OUT via USB / Drive."
echo "Recipient command: docker load -i $(basename "$OUT")"
echo "After load, image is available as itss-workshop:local — VS Code 'Reopen"
echo "in Container' will then use the cached build instead of rebuilding."
