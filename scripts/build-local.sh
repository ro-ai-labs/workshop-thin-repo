#!/usr/bin/env bash
# scripts/build-local.sh
# Single-arch (linux/amd64) build for fast local iteration.
# Loads into local Docker for immediate smoke-testing.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# Image is toolchain-only — demo repos are cloned by post-create.sh on first
# reopen, and plugins are installed manually inside the container via
# `/plugin add`. Nothing host-specific gets baked in; no staging step needed.

echo ""
echo "==> Building itss-workshop:local (linux/amd64 only, toolchain-only image)..."
echo ""

docker buildx build \
  --platform linux/amd64 \
  -t itss-workshop:local \
  --load \
  -f .devcontainer/Dockerfile .

echo ""
echo "Built: itss-workshop:local"
echo "Smoke-test it with: bash scripts/run-smoke-test.sh"
