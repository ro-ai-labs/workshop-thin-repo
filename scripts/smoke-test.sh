#!/usr/bin/env bash
# scripts/smoke-test.sh
# Verifies the IMAGE only — toolchains, baked plugins, caches.
# Demo repos + per-repo deps are NOT in the image (post-create.sh materialises
# them on the workspace mount), so we don't check for them here.
# Non-zero exit on any failure.

set -u

PASS=0
FAIL=0
FAILURES=()

ok()   { printf "  \033[0;32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
bad()  { printf "  \033[0;31m✗\033[0m %s\n" "$1"; FAIL=$((FAIL+1)); FAILURES+=("$1"); }

check() {
  local label="$1"; shift
  if "$@" >/tmp/check.log 2>&1; then ok "$label"; else bad "$label  (see /tmp/check.log)"; fi
}

echo "== Toolchain =="
check "Node 24.x (system)"  bash -c 'node --version | grep -E "^v24\."'
# nvm + Node 24.5.0 pre-cached so Twenty's `nvm install` (from its .nvmrc)
# is a no-op at demo time, not a network fetch.
check "nvm + Node 24.5.0"   bash -c '. "$HOME/.nvm/nvm.sh" && nvm which 24.5.0 | grep -E "v24\.5\.0"'
# Corepack-managed yarn 4 only resolves inside a project context (package.json
# with `packageManager: yarn@4.13.0`). Twenty has that. The bare image doesn't,
# so we synthesise a tiny project to verify yarn 4 is reachable.
check "Yarn 4.13 via Corepack" bash -c '
  d=$(mktemp -d) && cd "$d" \
    && printf "{\"packageManager\":\"yarn@4.13.0\"}\n" > package.json \
    && yarn --version | grep -E "^4\."
'
check "Bun 1.3.x"           bash -c 'bun --version | grep -E "^1\.3\."'
check "Rust 1.93.0"         bash -c 'rustc --version | grep "1.93.0"'
check "Claude Code CLI"     command -v claude
# docker CLI is provided at devcontainer-creation time by the docker-in-docker
# feature, not by the image build. We only verify the v1-compat shim here;
# the real DinD smoke happens in RUNBOOK Step 2 (reopen-in-container).
check "docker-compose shim" command -v docker-compose
check "tree (Demo 1 P6.3)"  command -v tree

echo "== CARGO_HOME is vscode-writable =="
check "CARGO_HOME owner"    bash -c 'test -w "${CARGO_HOME:-/usr/local/cargo}"'

echo "== Playwright Chromium pre-pulled =="
check "Playwright Chromium" bash -c 'ls $HOME/.cache/ms-playwright/chromium-*/chrome-linux*/chrome 2>/dev/null'

echo "== Plugin volume mountpoint exists =="
# Plugins are installed manually at workshop time via `/plugin add`; the image
# only needs to provide the parent directory so the named volume can mount.
check "/home/vscode/.claude/plugins" test -d /home/vscode/.claude/plugins

echo ""
echo "Pass: $PASS  Fail: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failures:"
  for f in "${FAILURES[@]}"; do echo "  - $f"; done
  exit 1
fi
exit 0
