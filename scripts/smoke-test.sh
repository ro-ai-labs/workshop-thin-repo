#!/usr/bin/env bash
# scripts/smoke-test.sh
# Runs inside the container after build. Verifies the 6 success criteria.
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

WORKSHOP=${WORKSHOP_HOME:-/home/vscode/workshop}

echo "== Toolchain =="
check "Node 24.5.x"         bash -c 'node --version | grep -E "^v24\.5\."'
check "Yarn 4.x"            bash -c 'yarn --version | grep -E "^4\."'
check "Bun 1.3.x"           bash -c 'bun --version | grep -E "^1\.3\."'
check "Rust 1.93.0"         bash -c 'rustc --version | grep "1.93.0"'
check "Java 21"             bash -c 'java --version | head -1 | grep -E "21\."'
check "Maven on PATH"       command -v mvn
check "Claude Code CLI"     command -v claude
check "docker CLI"          command -v docker
check "docker-compose shim" command -v docker-compose

echo "== Workshop sources =="
check "codex repo"          test -d "$WORKSHOP/codex/codex-rs"
check "opencode repo"       test -f "$WORKSHOP/opencode/bun.lock"
check "twenty repo"         test -f "$WORKSHOP/twenty/.env"
check "spring-boot repo"    test -f "$WORKSHOP/spring-boot-pr-demo/pom.xml"
check "demo-examples HTMLs" test -f "$WORKSHOP/demo-examples/codex-architecture-fallback.html"
check "ailabs plugin src"   test -f "$WORKSHOP/plugins/ailabs-arch-flows/.claude-plugin/plugin.json"
check "ailabs plugin zip"   test -f "$WORKSHOP/plugins/ailabs-arch-flows.zip"

echo "== Spring Boot demo branches =="
check "spring-boot main branch" \
  bash -c "cd $WORKSHOP/spring-boot-pr-demo && git rev-parse main"
check "spring-boot demo/risky-changes branch" \
  bash -c "cd $WORKSHOP/spring-boot-pr-demo && git rev-parse demo/risky-changes"

echo "== Cached deps =="
check "Maven offline cache"  test -d "$HOME/.m2/repository/org/springframework/boot"
check "Cargo registry cache" test -d "$HOME/.cargo/registry/cache"
check "Bun install cache"    test -d "$HOME/.bun/install/cache"
check "Twenty .yarn cache"   test -d "$WORKSHOP/twenty/.yarn/cache"
check "Playwright Chromium"  bash -c 'ls $HOME/.cache/ms-playwright/chromium-*/chrome-linux*/chrome 2>/dev/null'

echo "== Claude plugins baked =="
check "hookify plugin"          test -d "$HOME/.claude/plugins/cache/claude-plugins-official/hookify"
check "superpowers plugin"      test -d "$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
check "pr-review-toolkit"       test -d "$HOME/.claude/plugins/cache/claude-plugins-official/pr-review-toolkit"
check "code-review plugin"      test -d "$HOME/.claude/plugins/cache/claude-plugins-official/code-review"
check "commit-commands plugin"  test -d "$HOME/.claude/plugins/cache/claude-plugins-official/commit-commands"
check "security-guidance"       test -d "$HOME/.claude/plugins/cache/claude-plugins-official/security-guidance"
check "plugin-dev plugin"       test -d "$HOME/.claude/plugins/cache/claude-plugins-official/plugin-dev"
check "understand-anything"     bash -c 'test -d "$HOME/.claude/plugins/cache/understand-anything" || test -d "$HOME/.claude/plugins/cache/Lum1104__Understand-Anything"'
check "installed_plugins.json"  test -f "$HOME/.claude/plugins/installed_plugins.json"
check "known_marketplaces.json" test -f "$HOME/.claude/plugins/known_marketplaces.json"

echo "== Docs / cheatsheets =="
check "Workshop handout PDF"    test -f "$WORKSHOP/docs/pdfs/00_Workshop_Handout.pdf"
check "CLAUDE.md cheatsheet"    test -f "$WORKSHOP/docs/cheatsheets/CLAUDE_AGENTS_md_Cheatsheet.md"
check "Kill Signal card"        test -f "$WORKSHOP/docs/cheatsheets/Kill_Signal_Decision_Card.md"
check "ship-it-with-ai"         test -f "$WORKSHOP/docs/ship-it-with-ai/Ship_It_With_AI.md"
check "knowledge-base index"    test -f "$WORKSHOP/docs/knowledge-base/INDEX.md"

echo "== Understand-Anything pre-gen =="
# Twenty + opencode forks have .understand-anything/ committed; codex doesn't
# (decided 2026-05-27 — P2.5 covered by pre-rendered HTML fallback either way).
check "opencode graph baked"    test -f "$WORKSHOP/opencode/.understand-anything/knowledge-graph.json"
check "twenty graph baked"      test -f "$WORKSHOP/twenty/.understand-anything/knowledge-graph.json"
if [ -f "$WORKSHOP/codex/.understand-anything/knowledge-graph.json" ]; then
  ok "codex graph baked (bonus — not required)"
else
  printf "  \033[0;33m!\033[0m codex graph not baked (expected — P2.5 falls back to pre-rendered HTML)\n"
fi

echo "== Twenty compose ready =="
check "Twenty compose file"     test -f "$WORKSHOP/twenty/packages/twenty-docker/docker-compose.dev.yml"

echo ""
echo "Pass: $PASS  Fail: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failures:"
  for f in "${FAILURES[@]}"; do echo "  - $f"; done
  exit 1
fi
exit 0
