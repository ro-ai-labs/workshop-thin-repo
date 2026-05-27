#!/usr/bin/env bash
# scripts/build-local.sh
# Single-arch (linux/amd64) build for fast local iteration.
# Loads into local Docker for immediate smoke-testing.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# Pull build args from /tmp/itss-build-vars.sh (created by Task 0)
if [ ! -f /tmp/itss-build-vars.sh ]; then
  echo "ERROR: /tmp/itss-build-vars.sh not found."
  echo "Run Task 0 first to capture host state (SHAs, paths)."
  exit 1
fi
source /tmp/itss-build-vars.sh

# Stage build context
bash scripts/prepare-build-context.sh

# Note: .understand-anything/ knowledge graphs are committed to the ro-ai-labs
# forks (twenty + opencode). Codex graph intentionally not baked — Demo 1 P2.5
# falls back to pre-rendered HTML. Graphs arrive via `git clone` in Dockerfile.

echo ""
echo "==> Building itss-workshop:local (linux/amd64 only, for fast iteration)..."
echo "    CODEX_SHA=$CODEX_SHA"
echo "    OPENCODE_SHA=$OPENCODE_SHA"
echo "    TWENTY_SHA=$TWENTY_SHA"
echo "    TWENTY_BRANCH=$TWENTY_BRANCH"
echo ""

docker buildx build \
  --platform linux/amd64 \
  --build-arg CODEX_SHA="$CODEX_SHA" \
  --build-arg OPENCODE_SHA="$OPENCODE_SHA" \
  --build-arg TWENTY_SHA="$TWENTY_SHA" \
  --build-arg TWENTY_BRANCH="$TWENTY_BRANCH" \
  -t itss-workshop:local \
  --load \
  -f .devcontainer/Dockerfile .

echo ""
echo "Built: itss-workshop:local"
echo "Smoke-test it with: bash scripts/run-smoke-test.sh"
