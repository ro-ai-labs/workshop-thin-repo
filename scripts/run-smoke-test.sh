#!/usr/bin/env bash
# scripts/run-smoke-test.sh
# Spins up a transient container of itss-workshop:local and runs smoke-test inside.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)

docker run --rm \
  -v "$ROOT/scripts/smoke-test.sh:/tmp/smoke-test.sh:ro" \
  -e WORKSHOP_HOME=/home/vscode/workshop \
  --user vscode \
  itss-workshop:local \
  bash /tmp/smoke-test.sh
