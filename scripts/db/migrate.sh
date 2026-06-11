#!/usr/bin/env bash
set -euo pipefail

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
MIGRATION_DIR="$SCRIPT_DIR/migration"
POSTGRES_CONTAINER="box-postgres"
POSTGRES_USER="postgres"
POSTGRES_DB="box-db"

psql() {
  docker exec -i "$POSTGRES_CONTAINER" psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" "$@"
}

ensure_postgres_ready() {
  if ! docker ps --format '{{.Names}}' | grep -qx "$POSTGRES_CONTAINER"; then
    echo "Starting postgres..."
    "${COMPOSE[@]}" up -d postgres
  fi

  local attempts=0
  until docker exec "$POSTGRES_CONTAINER" pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [[ $attempts -ge 30 ]]; then
      echo "Postgres did not become ready in time." >&2
      exit 1
    fi
    sleep 1
  done
}

ensure_migration_table() {
  psql <<'SQL'
CREATE SCHEMA IF NOT EXISTS bff;

CREATE TABLE IF NOT EXISTS bff.schema_migrations (
  version    TEXT PRIMARY KEY,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
SQL
}

migration_applied() {
  local version="$1"
  psql -tAc "SELECT 1 FROM bff.schema_migrations WHERE version = '$version' LIMIT 1;" | grep -q 1
}

apply_migration() {
  local file="$1"
  local version
  version="$(basename "$file" .sql)"

  if migration_applied "$version"; then
    echo "Skipping $version (already applied)"
    return 0
  fi

  echo "Applying $version..."
  psql <"$file"
  psql -c "INSERT INTO bff.schema_migrations (version) VALUES ('$version');"
  echo "Applied $version"
}

migrate() {
  ensure_postgres_ready
  ensure_migration_table

  local files=()
  local file
  shopt -s nullglob
  for file in "$MIGRATION_DIR"/V*.sql; do
    files+=("$file")
  done
  shopt -u nullglob

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No migrations found in $MIGRATION_DIR"
    return 0
  fi

  IFS=$'\n' files=($(printf '%s\n' "${files[@]}" | sort))
  unset IFS

  for file in "${files[@]}"; do
    apply_migration "$file"
  done

  echo "Migrations complete."
}

migrate
