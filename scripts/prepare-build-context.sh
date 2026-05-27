#!/usr/bin/env bash
# scripts/prepare-build-context.sh
# Stages host-only build inputs into ./build-context/ before docker buildx.
#
# This image is toolchain-only (Node, Bun, Rust, Claude Code, plugins, Playwright).
# Demo repo clones + per-repo deps are NOT baked — they're materialised on the
# workspace bind-mount at container creation by .devcontainer/post-create.sh.
# That means the only host-specific input we need here is the Claude plugin cache.
set -euo pipefail

HOST_CLAUDE=${HOST_CLAUDE_DIR:-$HOME/.claude}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=$ROOT/build-context

if [ ! -d "$HOST_CLAUDE/plugins/cache" ]; then
  echo "ERROR: host Claude plugin cache not found at $HOST_CLAUDE/plugins/cache"
  echo "Install plugins on host first (or set HOST_CLAUDE_DIR)."
  exit 1
fi

echo "==> Staging Claude plugins from $HOST_CLAUDE/plugins/"
rm -rf "$DEST/claude-plugins"
mkdir -p "$DEST/claude-plugins/cache"
cp -r "$HOST_CLAUDE/plugins/cache/"* "$DEST/claude-plugins/cache/"

# Strip host node_modules — they have host-arch native binaries that won't run
# in the linux/amd64 container. The Dockerfile re-runs `pnpm install` per-plugin.
find "$DEST/claude-plugins/cache" -type d -name "node_modules" -prune -exec rm -rf {} + 2>/dev/null || true

# Strip embedded .git directories from plugins shipped as full git checkouts
# (e.g. sourcegraph). Without this they become broken submodules in our repo.
find "$DEST/claude-plugins/cache" -type d -name ".git" -prune -exec rm -rf {} + 2>/dev/null || true

# Strip Claude Code's per-process runtime state (.in_use/<pid> markers) — not
# source content, will leak host PIDs into the image and the repo.
find "$DEST/claude-plugins/cache" -type d -name ".in_use" -prune -exec rm -rf {} + 2>/dev/null || true

# Copy plugin registry files (installed_plugins.json + known_marketplaces.json)
for f in installed_plugins.json known_marketplaces.json; do
  if [ -f "$HOST_CLAUDE/plugins/$f" ]; then
    cp "$HOST_CLAUDE/plugins/$f" "$DEST/claude-plugins/$f"
  else
    echo "WARN: $HOST_CLAUDE/plugins/$f not found — skipping"
  fi
done

echo ""
echo "Build context ready:"
du -sh "$DEST"/*
