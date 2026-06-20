# Box workspace

Monorepo of git submodules: `apps/box-mobile` (Expo/React Native app), `packages/rntk-ui` (Tamagui design
system), `box-bff` (Bun/Elysia backend), `java/box-keycloak` (auth). When working inside a submodule, follow
its own `AGENTS.md` too.

## Tooling: Bun (not npm/npx/pnpm/yarn/node)

`bun install`, `bun add <pkg>`, `bun add -d <pkg>`, `bun run <script>`, `bunx <cli>` (e.g. `bunx expo …`,
`bunx drizzle-kit …`).
