#!/usr/bin/env bash
# scripts/build-multiarch.sh
# Multi-arch build (linux/amd64 + linux/arm64) and push to ghcr.io.
# Requires: docker login ghcr.io done; buildx ready for arm64 (QEMU acceptable).
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

if [ ! -f /tmp/itss-build-vars.sh ]; then
  echo "ERROR: /tmp/itss-build-vars.sh not found."
  exit 1
fi
source /tmp/itss-build-vars.sh

# Confirm buildx can target arm64
if ! docker buildx inspect default 2>/dev/null | grep -q "linux/arm64"; then
  echo "==> Setting up multi-arch buildx (may take ~30s)..."
  docker run --privileged --rm tonistiigi/binfmt --install all
  docker buildx create --use --name itss-builder --bootstrap 2>/dev/null || \
    docker buildx use itss-builder
fi

bash scripts/prepare-build-context.sh
bash scripts/prep-understand-graphs.sh

echo ""
echo "==> Building $IMAGE_TAG for linux/amd64 + linux/arm64"
echo "    This takes 30-60 min (arm64 via QEMU emulation on amd64 host)."
echo ""

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg CODEX_SHA="$CODEX_SHA" \
  --build-arg OPENCODE_SHA="$OPENCODE_SHA" \
  --build-arg TWENTY_SHA="$TWENTY_SHA" \
  --build-arg TWENTY_BRANCH="$TWENTY_BRANCH" \
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
