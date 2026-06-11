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
POSTGRES_CONTAINER="box-postgres"
POSTGRES_USER="postgres"
POSTGRES_DB="box-db"
TEST_PASSWORD="password123"

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

seed() {
  ensure_postgres_ready

  psql -v test_password="$TEST_PASSWORD" <<'SQL'
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO bff.users (email, first_name, last_name, password, email_verified)
SELECT 'alice@example.com', 'Alice', 'Smith', crypt(:'test_password', gen_salt('bf')), TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM bff.users WHERE lower(email) = lower('alice@example.com')
);

INSERT INTO bff.users (email, first_name, last_name, password, email_verified)
SELECT 'bob@example.com', 'Bob', 'Jones', crypt(:'test_password', gen_salt('bf')), TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM bff.users WHERE lower(email) = lower('bob@example.com')
);

INSERT INTO bff.users (email, first_name, last_name, password, email_verified)
SELECT 'charlie@example.com', 'Charlie', 'Brown', crypt(:'test_password', gen_salt('bf')), FALSE
WHERE NOT EXISTS (
  SELECT 1 FROM bff.users WHERE lower(email) = lower('charlie@example.com')
);
SQL

  echo "Seeded test users (password for all: $TEST_PASSWORD):"
  psql -c "SELECT email, first_name, last_name, email_verified FROM bff.users ORDER BY email;"
}

seed
