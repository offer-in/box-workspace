# Box workspace

Monorepo of **independent git submodules**. Each submodule is its own repo and must be
clonable and runnable on its own — do not introduce cross-submodule source dependencies.
(`box-mobile` consumes `@rntk/ui` only as a published registry package, never as a source link.)

| Path | What | Stack | Status |
|------|------|-------|--------|
| `apps/box-mobile` | Mobile app (primary product, iOS-first) | Expo / React Native | active |
| `apps/box-bff` | Backend-for-frontend API | Bun + Elysia | active |
| `packages/rntk-ui` | Design system (`@rntk/ui`) | Tamagui + Storybook | POC |
| `java/box-keycloak` | Keycloak auth SPI | Kotlin / Gradle | dormant POC |

When working inside a submodule, follow its own `AGENTS.md`.

## Development workflow: Comet (Spec-Driven Development)

Non-trivial changes go through [Comet](https://github.com/rpamis/comet) — a phase-guarded
SDD harness (installed for **Cursor** only) that chains
[OpenSpec](https://github.com/Fission-AI/openspec) (the *what*: specs/proposals) with
[Superpowers](https://github.com/obra/superpowers) (the *how*: brainstorming, TDD,
subagent-driven development).

- **Start non-trivial work with `/comet`** — it detects the phase and drives the flow:
  open → design → build → verify → archive (`/comet-hotfix` / `/comet-tweak` for small changes).
- Specs & changes live in `openspec/`; per-change state in `.comet.yaml`; config in `.comet/config.yaml`.
- The always-on `comet-phase-guard` rule and `.cursor/skills/` are the source of truth —
  don't hand-edit `.comet.yaml`; go through the Comet skills/scripts.

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

`context7`, `deepwiki`, `figma` are configured in `.mcp.json`.
