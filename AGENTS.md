# Box workspace

Monorepo of **independent git submodules**, see `.gitmodules`. Work in the workspace (parent + siblings + `/ops`); each app is mostly runnable alone, with local infra/shared packages as needed.

| Path | What | Stack | Status |
|------|------|-------|--------|
| `apps/box-mobile` | Mobile app (primary product, iOS-first) | Expo / React Native | active |
| `apps/box-bff` | Backend-for-frontend API | Bun + Elysia | active |
| `packages/rntk-ui` | Design system (`@rntk/ui`) | Tamagui + Storybook | POC |
| `java/box-keycloak` | Keycloak auth SPI | Kotlin / Gradle | dormant POC |

When working inside a submodule, follow its own `AGENTS.md`.

## AI Harness

Agents must follow the **AI Harness** principles in [`.cursor/rules/feature-development.mdc`](.cursor/rules/feature-development.mdc):

**YAGNI · human-in-the-loop batches · bite-sized reviewable work · QA Playbook (e2e-verifiable chunks).**

Change machinery is Superpowers (`brainstorming` → `writing-plans` → execute → verify) plus workspace skills `box-todo` / `box-finish`.

## Code intelligence: CodeGraph

[CodeGraph](https://github.com/colbymchenry/codegraph) indexes the codebase into a
queryable graph. Use it to navigate and understand cross-file relationships before
making changes.

## Tooling: Bun only

Use `bun` / `bunx` for everything. Never `npm` / `npx` / `pnpm` / `yarn` / `node`
(exception: `java/box-keycloak`, which is Gradle-based).

## Secrets: Doppler

No secrets in git. `.env*` is gitignored (except `.env.example`). Each submodule pulls
its own config from Doppler (project `box-backend`) — e.g. `bun run env:dev`. See `README.md`.

## Backend stack (Docker)

`just` recipes wrap `ops/docker-compose.yml` (postgres + box-bff + keycloak + nginx):

```sh
just                 # list all recipes
just backend-up      # build & start (detached)
just backend-down    # stop (volumes preserved; pass `-v` to nuke data)
just backend-wipe-db # recreate the postgres volume only
```

Postgres provisions the `bff` and `kc` schemas on first boot (`ops/postgres/init`).

## MCP

Configured in `.mcp.json`:

- `context7` — up-to-date library/framework docs.
- `deepwiki` — AI docs & Q&A for GitHub repos.
- `figma` — read/write Figma designs (design ↔ code).
- `maestro` — author & run mobile/web UI tests.
- `expo` — Expo tooling & docs.
- `browsermcp` — drive a browser (navigate, click, screenshot).
