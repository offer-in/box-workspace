#!/usr/bin/env bash

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

box_help() {
  cat <<'EOF'
box commands:
  box              pick a command from the menu
  box db_reset     wipe postgres volume and start fresh
  box migrate      run pending SQL migrations
  box seed         seed test users
  box help         show this help

Usage: source ./scripts/box-cmd.sh
EOF
}

box_db_reset() {
  bash "$SCRIPT_DIR/db/reset_db.sh"
}

box_migrate() {
  "$SCRIPT_DIR/db/migrate.sh"
}

box_seed() {
  "$SCRIPT_DIR/db/seed.sh"
}

box_pick() {
  cat <<'EOF'
1 - reset_db
2 - migrate
3 - seed
4 - help
EOF
  local choice
  printf "Pick a command: "
  read -r choice
  case "$choice" in
    1) box_db_reset ;;
    2) box_migrate ;;
    3) box_seed ;;
    4) box_help ;;
    *)
      echo "Unknown choice: $choice" >&2
      return 1
      ;;
  esac
}

box() {
  local cmd="${1:-}"

  if [[ -z "$cmd" ]]; then
    box_pick
    return
  fi

  case "$cmd" in
    db_reset | reset_db) box_db_reset ;;
    migrate) box_migrate ;;
    seed) box_seed ;;
    help) box_help ;;
    *)
      echo "Unknown command: $cmd" >&2
      box_help
      return 1
      ;;
  esac
}
