#!/usr/bin/env bash

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$ROOT/docker-compose.base.yml"
COMPOSE=(docker compose -f "$COMPOSE_FILE")
POSTGRES_CONTAINER="box-postgres"

function reset_db() {
  echo "Stopping postgres..."
  "${COMPOSE[@]}" stop postgres
  "${COMPOSE[@]}" rm -f postgres

  echo "Removing postgres volume..."
  local project volume_id
  project="${COMPOSE_PROJECT_NAME:-$(basename "$ROOT")}"
  volume_id="$(docker volume ls -q \
    --filter "label=com.docker.compose.project=${project}" \
    --filter "label=com.docker.compose.volume=postgres_data")"

  if [[ -z "$volume_id" ]]; then
    volume_id="${project}_postgres_data"
  fi

  docker volume rm -f "$volume_id" 2>/dev/null || true

  echo "Starting fresh postgres..."
  "${COMPOSE[@]}" up -d postgres

  echo "Waiting for postgres..."
  local attempts=0
  until docker exec "$POSTGRES_CONTAINER" pg_isready -U postgres -d box-db >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [[ $attempts -ge 30 ]]; then
      echo "Postgres did not become ready in time." >&2
      return 1
    fi
    sleep 1
  done

  echo "Postgres reset complete (box-db is empty)."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  reset_db
fi
