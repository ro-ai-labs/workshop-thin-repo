#!/usr/bin/env bash
# scripts/prepare-build-context.sh
# Stages everything the Dockerfile expects under ./build-context/
# Run before docker buildx.
set -euo pipefail

DELIV=${DELIVERABLES_DIR:-$HOME/ai-labs/workshops/ITSS/deliverables}
HOST_CLAUDE=${HOST_CLAUDE_DIR:-$HOME/.claude}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=$ROOT/build-context

if [ ! -d "$DELIV" ]; then
  echo "ERROR: deliverables dir not found at $DELIV"
  echo "Set DELIVERABLES_DIR env var if it's elsewhere."
  exit 1
fi
if [ ! -d "$HOST_CLAUDE/plugins/cache" ]; then
  echo "ERROR: host Claude plugin cache not found at $HOST_CLAUDE/plugins/cache"
  echo "Install plugins on host first (or set HOST_CLAUDE_DIR)."
  exit 1
fi

echo "==> Staging deliverables content into $DEST/deliverables-content/"
rm -rf "$DEST/deliverables-content"
mkdir -p "$DEST/deliverables-content"/{cheatsheets,pdfs,ship-it-with-ai,knowledge-base,plugins,demo-examples,scripts}

cp "$DELIV/cheatsheets/"*.md            "$DEST/deliverables-content/cheatsheets/"
cp "$DELIV/drive-share/"*.pdf           "$DEST/deliverables-content/pdfs/"
cp "$DELIV/ship-it-with-ai/Ship_It_With_AI.md"   "$DEST/deliverables-content/ship-it-with-ai/"
cp "$DELIV/ship-it-with-ai/ship_it_with_ai.html" "$DEST/deliverables-content/ship-it-with-ai/"
cp "$DELIV/ship-it-with-ai/cover."*     "$DEST/deliverables-content/ship-it-with-ai/" 2>/dev/null || true
cp -r "$DELIV/knowledge-base/"*         "$DEST/deliverables-content/knowledge-base/"

cp "$DELIV/drive-share/demo-codex-architecture.html" \
   "$DEST/deliverables-content/demo-examples/codex-architecture-fallback.html"
cp "$DELIV/drive-share/demo-opencode-architecture.html" \
   "$DEST/deliverables-content/demo-examples/opencode-architecture-fallback.html"

cp -r "$DELIV/plugins/ailabs-arch-flows" \
      "$DEST/deliverables-content/plugins/ailabs-arch-flows"
(cd "$DELIV/plugins" && zip -qr - ailabs-arch-flows) \
   > "$DEST/deliverables-content/plugins/ailabs-arch-flows.zip"

cp "$DELIV/demo-3-setup/create_demo_repo.sh" \
   "$DEST/deliverables-content/scripts/create_demo_repo.sh"
chmod +x "$DEST/deliverables-content/scripts/create_demo_repo.sh"

# ---- Claude plugin cache (from host) ----
echo "==> Staging Claude plugins from $HOST_CLAUDE/plugins/"
rm -rf "$DEST/claude-plugins"
mkdir -p "$DEST/claude-plugins/cache"
cp -r "$HOST_CLAUDE/plugins/cache/"* "$DEST/claude-plugins/cache/"
# Strip host node_modules — they have host-arch native binaries that won't
# work in linux/amd64 or linux/arm64 containers. Dockerfile rebuilds per-arch.
find "$DEST/claude-plugins/cache" -type d -name "node_modules" -prune -exec rm -rf {} + 2>/dev/null || true

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
echo ""
echo "Next step: ensure understand-anything knowledge graphs are staged."
echo "Run: bash scripts/prep-understand-graphs.sh"
