#!/usr/bin/env bash
# scripts/prep-understand-graphs.sh
# Stages .understand-anything/ knowledge graphs from existing host clones
# into the build context. The graphs must already exist on host — generate
# them with `claude` -> `/understand` in each demo repo BEFORE running this.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=$ROOT/build-context/understand-anything
mkdir -p "$DEST"/{codex,opencode,twenty}

WORKSHOP_SRC=${WORKSHOP_SRC:-$HOME/workshop}

missing=0
for repo in codex opencode twenty; do
  src=$WORKSHOP_SRC/$repo/.understand-anything
  out=$DEST/$repo
  echo ""
  echo "==> $repo"
  echo "    source: $src"
  echo "    dest:   $out"
  if [ ! -f "$src/knowledge-graph.json" ]; then
    echo "    MISSING: no knowledge-graph.json. Generate it on host:"
    echo "      cd $WORKSHOP_SRC/$repo && claude"
    echo "      (inside claude) /understand"
    echo "    Then re-run this script."
    missing=$((missing+1))
    continue
  fi
  rm -rf "$out"/*
  cp -r "$src/"* "$out/"
  echo "    OK ($(du -sh "$out" | awk '{print $1}'))"
done

if [ "$missing" -gt 0 ]; then
  echo ""
  echo "$missing repo(s) missing understand-anything graphs. See instructions above."
  exit 1
fi

echo ""
echo "All three graphs staged at $DEST"
