#!/usr/bin/env bash
# scripts/build-and-push.sh
# Single-arch (linux/amd64) build, tag, and push to ghcr.io.
# Requires: docker login ghcr.io done.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

if [ ! -f /tmp/itss-build-vars.sh ]; then
  echo "ERROR: /tmp/itss-build-vars.sh not found."
  exit 1
fi
source /tmp/itss-build-vars.sh

bash scripts/prepare-build-context.sh
bash scripts/prep-understand-graphs.sh

echo ""
echo "==> Building $IMAGE_TAG for linux/amd64"
echo "    Expected wallclock: 15-25 min on a typical laptop."
echo ""

docker buildx build \
  --platform linux/amd64 \
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
