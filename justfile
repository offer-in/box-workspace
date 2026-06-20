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
