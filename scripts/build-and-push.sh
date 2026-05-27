#!/usr/bin/env bash
# scripts/build-and-push.sh
# Single-arch (linux/amd64) build, tag, and push to ghcr.io.
# Requires: docker login ghcr.io done.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

: "${IMAGE_TAG:=ghcr.io/ro-ai-labs/itss-workshop:2026.05.28}"

bash scripts/prepare-build-context.sh

echo ""
echo "==> Building $IMAGE_TAG for linux/amd64 (toolchain-only image)"
echo "    Expected wallclock: 8-15 min on a typical laptop."
echo ""

docker buildx build \
  --platform linux/amd64 \
  -t "$IMAGE_TAG" \
  -t "ghcr.io/ro-ai-labs/itss-workshop:latest" \
  --push \
  -f .devcontainer/Dockerfile .

echo ""
echo "Pushed: $IMAGE_TAG"
echo "Also tagged: ghcr.io/ro-ai-labs/itss-workshop:latest"
echo ""
echo "Verify with:"
echo "  docker buildx imagetools inspect $IMAGE_TAG"
