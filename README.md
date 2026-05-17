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
