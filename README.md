# MegaMek dedicated server — Docker

Runs the [MegaMek](https://megamek.org) **dedicated (headless) server** in a
container. Players connect to it from their own MegaMek desktop clients; the
container has no GUI — it just hosts the game.

## Requirements

- Docker + Docker Compose
- The host port (default `2346`) reachable by your players

## Quick start

```sh
cp .env.example .env       # optional — tweak version/port/memory
docker compose up -d --build
docker compose logs -f     # watch the server console
```

By default this builds the **latest** MegaMek GitHub release. To connect,
players open MegaMek → *Connect to a game* and enter your host's IP and port
`2346`.

> **Important:** your MegaMek **client version must match the server version.**
> Pin `MM_VERSION` in `.env` to the version your group uses (see below).

## Configuration

All settings are optional and live in `.env`:

| Variable        | Default  | Purpose                                                        |
|-----------------|----------|----------------------------------------------------------------|
| `MM_VERSION`    | `latest` | Release to build — `latest` or a pinned version like `0.50.12` |
| `MM_PORT`       | `2346`   | Server port (host and container)                               |
| `MM_XMX`        | `4096m`  | Max JVM heap                                                   |
| `MM_SAVEGAME`   | —        | Saved game to load on start, e.g. `savegames/mygame.sav.gz`    |
| `MM_EXTRA_ARGS` | —        | Extra MegaMek command-line arguments                           |

A password can be set in `mmconf/clientsettings.xml` (persisted in the
`megamek-mmconf` volume).

## Persistence

Three named volumes survive rebuilds and restarts:

- `megamek-mmconf` → `/opt/megamek/mmconf` (server config)
- `megamek-savegames` → `/opt/megamek/savegames` (saved games)
- `megamek-logs` → `/opt/megamek/logs` (logs)

## Common tasks

```sh
# Upgrade to a new release: edit MM_VERSION in .env, then
docker compose up -d --build

# Stop / start
docker compose down
docker compose up -d

# Attach to the live server console
docker attach megamek      # detach with Ctrl-P Ctrl-Q

# Copy a save into the container's savegames volume
docker compose cp ./mygame.sav.gz megamek:/opt/megamek/savegames/
```

## How it works

- **Dockerfile** — stage 1 downloads & extracts the release tarball
  (`MM_VERSION=latest` resolves the newest GitHub release); stage 2 runs it on
  `eclipse-temurin:17-jre` (MegaMek needs Java 17+) as a non-root user.
- **entrypoint.sh** — launches `java -jar MegaMek.jar -dedicated …` with the
  JVM flags MegaMek ships with, in headless mode.
