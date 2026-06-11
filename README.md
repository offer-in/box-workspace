# Box Project

- This is the entry of multiple git submodule prjects

```sh
# Prerequisites
# 1. pull env from doppler first. See readme in each submodules
# 2. open port
docker compose -f docker-compose.dev.yml up --build
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml restart caddy
```

### Database

Load the `box` helper once per terminal session:

```sh
source ./scripts/box-cmd.sh
```

| Command        | What it does                  |
| -------------- | ----------------------------- |
| `box`          | Interactive menu              |
| `box migrate`  | Run pending SQL migrations    |
| `box seed`     | Add test users                |
| `box db_reset` | Wipe postgres and start fresh |
| `box help`     | Show commands                 |

**First-time setup** (after docker is running):

```sh
source ./scripts/box-cmd.sh
box migrate
box seed
```

**Start over** (deletes all data):

```sh
box db_reset
box migrate
box seed
```

`box seed` creates three users with password `password123`:

- `alice@example.com` (verified)
- `bob@example.com` (verified)
- `charlie@example.com` (not verified)

You can also run the scripts directly: `./scripts/db/migrate.sh`, `./scripts/db/seed.sh`, `./scripts/db/reset_db.sh`.

### Verdaccio

- Dev: http://localhost:4873

Register user

```sh
# bobby | pwd: 12qwaszx
npm adduser --registry http://localhost:4873/
```

List users

```sh
# output -> bobby:$2a$10$xDcG82D098sDN...
# No such file or directory -> then no user is registered yet
docker exec -it verdaccio cat /verdaccio/storage/htpasswd
```

### Submodule

Add new submodule

```sh
git submodule add -f git@github.com:offer-in/rntk-ui.git packages/rntk-ui
```

Clone and update

```sh
git clone --recursive git@github.com:offer-in/box-workspace.git
# or update for the first time after clone non-recursively
git submodule update --init --recursive
```

Check status / list submodules

```sh
git submodule status --recursive
```
