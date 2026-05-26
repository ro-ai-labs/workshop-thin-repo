#!/usr/bin/env bash
# post-create.sh — runs once when the container is first created.
# Brings Twenty's Postgres + Redis up and seeds the DB.
set -euo pipefail

# Set git identity from host env if not already configured
if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "${GIT_AUTHOR_EMAIL:-participant@itss.workshop}"
  git config --global user.name  "${GIT_AUTHOR_NAME:-ITSS Participant}"
fi

WORKSHOP=${WORKSHOP_HOME:-/home/vscode/workshop}
COMPOSE_FILE=$WORKSHOP/twenty/packages/twenty-docker/docker-compose.dev.yml

# Wait for the DinD daemon to be ready (sometimes races on first boot)
echo "[post-create] waiting for docker daemon..."
for i in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then break; fi
  sleep 2
done
if ! docker info >/dev/null 2>&1; then
  echo "[post-create] ERROR: docker daemon not available after 60s"
  echo "[post-create] Twenty's Postgres/Redis will need manual start later:"
  echo "  docker compose -f $COMPOSE_FILE up -d"
  exit 0  # don't block container creation
fi

# Bring Twenty's Postgres + Redis up
echo "[post-create] starting Twenty's compose stack..."
docker compose -f "$COMPOSE_FILE" up -d

# Wait for Postgres healthy (compose declares a healthcheck)
echo "[post-create] waiting for Postgres..."
status=none
for i in $(seq 1 60); do
  status=$(docker inspect --format='{{.State.Health.Status}}' twenty-dev-db-1 2>/dev/null || echo none)
  if [ "$status" = "healthy" ]; then break; fi
  sleep 2
done
if [ "$status" != "healthy" ]; then
  echo "[post-create] WARN: Postgres health unknown (status=$status); continuing anyway"
fi

# Twenty DB schema seed (idempotent; takes ~1-2 min on first run)
# Script is `database:init:prod` in packages/twenty-server (per Task 0 finding).
echo "[post-create] running Twenty database init..."
cd "$WORKSHOP/twenty"
if ! yarn workspace twenty-server database:init:prod; then
  echo "[post-create] WARN: yarn workspace twenty-server database:init:prod failed."
  echo "[post-create]       Twenty will need manual DB init before yarn start."
fi

echo "[post-create] complete"
