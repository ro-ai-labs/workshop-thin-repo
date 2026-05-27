#!/usr/bin/env bash
# post-start.sh — runs every time the container starts.
# Ensures Twenty's compose stack is up and prints the welcome banner.
set -u

WORKSHOP=${WORKSHOP_HOME:-/home/vscode/workshop}
COMPOSE_FILE=$WORKSHOP/twenty/packages/twenty-docker/docker-compose.dev.yml

# Re-ensure compose is up (no-op if already running)
if [ -f "$COMPOSE_FILE" ]; then
  docker compose -f "$COMPOSE_FILE" up -d >/dev/null 2>&1 || true
fi

# Welcome banner
cat <<'EOF'

  ╭─────────────────────────────────────────────────────────────╮
  │  ITSS Workshop 2026 — Container ready                       │
  ╰─────────────────────────────────────────────────────────────╯

  Demos live under ~/workshop/:
    • codex/        Demo 1 — Rust architecture (read-only)
    • opencode/     Demo 1 — TypeScript architecture (read-only)
    • twenty/       Demo 2 — Superpowers feature build

  Start Twenty UI:   cd ~/workshop/twenty && yarn start
                     (then http://localhost:3001)
  View architecture: right-click ~/workshop/drive-share/demo-*.html → Show Preview
  Handouts:          ~/workshop/drive-share/*.pdf
  Demo 1 Part 2:     in a `claude` session, ask the plugin-dev:create-plugin
                     skill to scaffold a marketplace at ~/workshop/itss-plugins/

  Run `claude` in any demo dir to start a session.

EOF
