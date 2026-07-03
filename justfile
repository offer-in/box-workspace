set dotenv-load := false

default:
	@just --list --list-prefix ··

# Tear down the backend docker compose stack.
# Pass `-v` manually nukes postgres_data / nginx_secrets (require regenerate certs).
[doc("Tear down backend stack (volumes preserved; pass `-v` to nuke postgres_data / nginx_secrets)")]
backend-down *FLAGS:
	docker compose --env-file ops/.env -f ops/docker-compose.yml --profile backend --project-directory . down {{FLAGS}}

# Build and start the backend docker compose stack in detached mode.
[doc("Build & start backend stack (docker compose up -d --build, profile=backend)")]
backend-up:
	docker compose --env-file ops/.env -f ops/docker-compose.yml --profile backend --project-directory . up -d --build

# Wipe ONLY the postgres volume (leaves nginx_secrets / LE certs intact).
# Use this when you need a fresh DB — e.g. after changing KC_DB_SCHEMA so the
# init script in ops/postgres/init/ re-runs.
[doc("Wipe postgres_data volume only (nginx_secrets preserved)")]
backend-wipe-db:
	docker compose --env-file ops/.env -f ops/docker-compose.yml --profile backend --project-directory . rm -sfv postgres
	docker volume rm box-workspace_postgres_data

# Build and start the verdaccio docker compose stack in detached mode.
verdaccio-up:
	docker compose --env-file ops/.env -f ops/docker-compose.yml --profile verdaccio --project-directory . up -d --build

# Tear down the verdaccio docker compose stack.
verdaccio-down:
	docker compose --env-file ops/.env -f ops/docker-compose.yml --profile verdaccio --project-directory . down