#!/usr/bin/env bash
# post-create.sh — runs once when the container is first created.
#
# Bootstraps the workshop:
#   1. Creates the symlinks doc paths assume (~/workshop, drive-share)
#   2. Clones the three demo repos into ${WORKSHOP_HOME} (workspace mount,
#      so participants' edits + git state survive container rebuild)
#   3. Pre-pulls per-repo deps (bun install / yarn install)
#   4. Brings Twenty's Postgres + Redis up and seeds the DB
#
# Idempotent: re-running skips work that's already done.
# Expected wallclock first time: ~10–15 min (bun + yarn over the network).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_FOLDER="$(dirname "$SCRIPT_DIR")"

# Pinned versions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/versions.env"

WORKSHOP_HOME="${WORKSHOP_HOME:-$WORKSPACE_FOLDER/workshop}"
mkdir -p "$WORKSHOP_HOME"

echo "[post-create] WORKSPACE_FOLDER = $WORKSPACE_FOLDER"
echo "[post-create] WORKSHOP_HOME    = $WORKSHOP_HOME"

# Git identity from host env (devcontainer remoteEnv) if not already configured
if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "${GIT_AUTHOR_EMAIL:-participant@itss.workshop}"
  git config --global user.name  "${GIT_AUTHOR_NAME:-ITSS Participant}"
fi

# --- 1. Convenience symlinks -------------------------------------------------

# ~/workshop -> $WORKSHOP_HOME so docs that say "~/workshop/codex" keep working.
if [ ! -e "$HOME/workshop" ] && [ "$HOME/workshop" != "$WORKSHOP_HOME" ]; then
  ln -s "$WORKSHOP_HOME" "$HOME/workshop"
fi

# drive-share is committed in the thin repo — expose it under $WORKSHOP_HOME too.
if [ ! -e "$WORKSHOP_HOME/drive-share" ]; then
  ln -s "$WORKSPACE_FOLDER/drive-share" "$WORKSHOP_HOME/drive-share"
fi

# --- 2. Clone demo repos -----------------------------------------------------

clone_at_sha() {
  local repo="$1" sha="$2" dest="$3" branch="${4:-}"
  if [ -d "$dest/.git" ]; then
    echo "[post-create] $(basename "$dest"): already cloned, skipping"
    return 0
  fi
  echo "[post-create] cloning $(basename "$dest") @ ${sha:0:10}..."
  git clone --filter=blob:none "$repo" "$dest"
  if [ -n "$branch" ]; then
    ( cd "$dest" && git fetch origin "${branch}:${branch}" 2>/dev/null || true )
  fi
  ( cd "$dest" && git checkout "$sha" )
}

clone_at_sha "$CODEX_REPO"    "$CODEX_SHA"    "$WORKSHOP_HOME/codex"    "$CODEX_BRANCH"
clone_at_sha "$OPENCODE_REPO" "$OPENCODE_SHA" "$WORKSHOP_HOME/opencode" "$OPENCODE_BRANCH"
clone_at_sha "$TWENTY_REPO"   "$TWENTY_SHA"   "$WORKSHOP_HOME/twenty"   "$TWENTY_BRANCH"

# --- 3. Per-repo dep installs (idempotent) -----------------------------------

# opencode: bun install
if [ ! -d "$WORKSHOP_HOME/opencode/node_modules" ]; then
  echo "[post-create] opencode: bun install (~2–3 min)..."
  ( cd "$WORKSHOP_HOME/opencode" && bun install --frozen-lockfile )
fi

# twenty: apply .env then yarn install
if [ ! -f "$WORKSHOP_HOME/twenty/.env" ]; then
  cp "$SCRIPT_DIR/twenty.env" "$WORKSHOP_HOME/twenty/.env"
fi
if [ ! -d "$WORKSHOP_HOME/twenty/.yarn/cache" ] || [ -z "$(ls -A "$WORKSHOP_HOME/twenty/.yarn/cache" 2>/dev/null)" ]; then
  echo "[post-create] twenty: yarn install (~8–12 min)..."
  ( cd "$WORKSHOP_HOME/twenty" && yarn install --immutable )
fi

# codex: cargo fetch (read-only demo; we just want the registry cache warm)
if [ ! -d "${CARGO_HOME:-/usr/local/cargo}/registry/cache" ] \
   || [ -z "$(ls -A "${CARGO_HOME:-/usr/local/cargo}/registry/cache" 2>/dev/null)" ]; then
  echo "[post-create] codex: cargo fetch..."
  ( cd "$WORKSHOP_HOME/codex/codex-rs" && cargo fetch )
fi

# --- 4. Twenty compose + DB init ---------------------------------------------

COMPOSE_FILE="$WORKSHOP_HOME/twenty/packages/twenty-docker/docker-compose.dev.yml"

echo "[post-create] waiting for docker daemon..."
for _ in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then break; fi
  sleep 2
done
if ! docker info >/dev/null 2>&1; then
  echo "[post-create] WARN: docker daemon not available; skipping Twenty compose bring-up."
  echo "[post-create]       Run later: docker compose -f $COMPOSE_FILE up -d"
  exit 0
fi

if [ -f "$COMPOSE_FILE" ]; then
  echo "[post-create] starting Twenty's Postgres + Redis..."
  docker compose -f "$COMPOSE_FILE" up -d

  echo "[post-create] waiting for Postgres healthy..."
  status=none
  for _ in $(seq 1 60); do
    status=$(docker inspect --format='{{.State.Health.Status}}' twenty-dev-db-1 2>/dev/null || echo none)
    if [ "$status" = "healthy" ]; then break; fi
    sleep 2
  done
  if [ "$status" != "healthy" ]; then
    echo "[post-create] WARN: Postgres health unknown (status=$status); continuing"
  fi

  echo "[post-create] running Twenty database init..."
  ( cd "$WORKSHOP_HOME/twenty" && yarn workspace twenty-server "$TWENTY_DB_RESET_SCRIPT" ) || {
    echo "[post-create] WARN: $TWENTY_DB_RESET_SCRIPT failed; Twenty will need manual DB init before yarn start"
  }
fi

echo "[post-create] complete"
