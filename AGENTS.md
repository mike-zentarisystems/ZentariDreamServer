# AGENTS.md — Dream Server

## Work from `dream-server/`

Nearly all code, config, scripts, and tests live under `dream-server/`. Run all Make targets from there.

## Build & Test Commands

```bash
cd dream-server
make lint      # bash -n syntax + Python compile check (NOT mypy — that's a separate CI job)
make test      # Tier map + installer contracts + preflight fixtures
make smoke     # Platform smoke tests (linux-amd, linux-nvidia, wsl, macos)
make bats      # BATS unit tests (auto-installs bats-core on first run)
make simulate  # Installer simulation harness
make gate      # lint + test + bats + smoke + simulate
make doctor    # Diagnostic report

# Single test
bash tests/test-tier-map.sh
bash tests/contracts/test-installer-contracts.sh
cd extensions/services/dashboard-api && pytest tests/
```

## CI vs Local Commands

CI runs **lint-shell.yml**, **lint-python.yml**, **type-check-python.yml**, **dashboard.yml**, **test-linux.yml** independently. `make lint` only runs syntax checks — it does NOT run mypy or pytest. The `gate` target skips mypy (it's `continue-on-error: true` in CI).

## Installer Architecture

`install-core.sh` is the orchestrator. It sets `INSTALL_PHASE`, then `source`s libraries from `installers/lib/` followed by phases from `installers/phases/`. **Phases execute on `source`** — they are not function calls. They run sequentially and share state via environment variables. Each phase file has a standardized header (Purpose/Expects/Provides/Modder notes).

## Extension System

Every service is an extension under `extensions/services/<name>/`:
- `manifest.yaml` — metadata (id, port, health endpoint, GPU backends, aliases)
- `compose.yaml` — optional; gets auto-merged into the Docker Compose stack by `scripts/resolve-compose-stack.sh`

Core services (llama-server, open-webui, dashboard, dashboard-api) have only manifests — their compose definitions live in `docker-compose.base.yml`.

Disabled extensions are archived in `_disabled/`.

## Docker Compose Layering

The stack is built from three layers merged in order:
1. `docker-compose.base.yml` — core services
2. `docker-compose.{amd,nvidia,apple}.yml` — GPU-specific overlay
3. Extension `compose.yaml` files — auto-discovered and merged

Services bind to `127.0.0.1` by default. Port conflicts are resolved via `ports.json`.

## Tier / GPU Backend System

GPU detection in `installers/lib/detection.sh` maps hardware to a tier via `installers/lib/tier-map.sh`. Backend configs in `config/backends/{amd,nvidia,apple,cpu}.json` define per-tier model selections. To add a new tier or swap a model, edit `tier-map.sh`.

## Extension Manifest Schema

```yaml
schema_version: dream.services.v1
compatibility:
  dream_min: "2.0.0"
service:
  id: my-service
  name: My Service
  aliases: []
  container_name: dream-my-service
  host_env: MY_SERVICE_HOST
  default_host: my-service
  port: 8080
  external_port_env: MY_SERVICE_PORT
  external_port_default: 8080
  health: /health
  ui_path: /              # optional; dashboard links here if set
  type: docker
  gpu_backends: [all]     # or [cpu, none] for CPU-only services
  compose_file: compose.yaml
  category: optional
  depends_on: []
  env_vars:
    - key: MY_API_KEY
      required: true
      secret: true
      description: Bearer token for the service
```

## Extension Compose Conventions

- Always `restart: unless-stopped` and `security_opt: [no-new-privileges:true]`
- Always a `healthcheck` with `wget -qO-` (not curl — Linux containers may lack curl)
- Always `${BIND_ADDRESS:-127.0.0.1}` for ports (defaults to localhost)
- CPU-only services use `gpu_backends: [cpu, none]`
- Agent backends integrating with Open WebUI multi-backend: inject `OPENAI_API_BASE_URLS` and `OPENAI_API_KEYS` via `open-webui` service override in compose.yaml

## Code Style

- **Shell**: `set -euo pipefail` everywhere. Avoid GNU-only constructs (GNU `date`, GNU `grep`) for macOS portability. BSD/GNU sed compatibility via `_sed_i()` in `lib/`.
- **Python**: FastAPI for APIs. Pytest for tests. **No broad exception catches** — never `except Exception: pass`. Raise `HTTPException` instead of returning `None`. Tests crash visibly.
- **JavaScript/React**: ESLint flat config. Vite + Tailwind CSS.

## Error Handling Philosophy

**Let It Crash > KISS > Pure Functions > SOLID**. Internal functions let exceptions propagate. Narrow exception catches at I/O boundaries (health checks, network calls) are fine.

## Pre-commit Hooks

Root `.pre-commit-config.yaml` runs gitleaks, private key detection, and large-file checks (`>500KB`). Install: `pip install pre-commit && pre-commit install`

## Key Paths

| File | Purpose |
|------|---------|
| `dream-server/install-core.sh` | Installer orchestrator |
| `dream-server/installers/lib/detection.sh` | GPU detection |
| `dream-server/installers/lib/tier-map.sh` | Tier → model mapping |
| `dream-server/scripts/resolve-compose-stack.sh` | Compose stack resolver |
| `dream-server/.env.schema.json` | Env var validation schema |
| `dream-server/ports.json` | Canonical port registry |
| `dream-server/dream-cli` | Main CLI tool (~45K lines Bash) |
| `dream-server/tests/bats-tests/*.bats` | BATS unit tests |

## Dashboard UI / API

- **UI**: `extensions/services/dashboard/` — React + Vite + Tailwind. `npm run dev` for dev server.
- **API**: `extensions/services/dashboard-api/` — Python FastAPI. `pytest tests/` to run tests.
- Both built by `.github/workflows/dashboard.yml` (Node 20, Python 3.11).

## Service Stack (v2.4+)

### Core Services
- **llama-server** — LLM inference (port 8080 internal)
- **open-webui** — Chat UI (port 3000 external)
- **dashboard** — DreamServer Dashboard UI (port 3001 external)
- **dashboard-api** — Dashboard backend (port 3002 external)

### Optional Extensions
| Service | Port | Auth | GPU |
|---------|------|------|-----|
| hermes-agent | 8642 | Bearer token | all |
| baserow | 8110 | Authelia | cpu/none |
| prometheus | 9090 | Authelia | cpu/none |
| grafana | 3007 | Authelia | cpu/none |
| authelia | 9091 | Public (login) | cpu/none |
| caddy | 80/443 | N/A | cpu/none |

### Networking Options

**Option A — Caddy only (localhost):**
- Caddy binds `0.0.0.0` and handles HTTPS + Authelia forward-auth
- All other services remain on `127.0.0.1`
- Access via `localhost` or LAN IP

**Option B — Tailscale + Caddy (remote access):**
- Run Tailscale on the host machine (not in a container)
- Caddy serves only on `localhost` for local access
- Tailscale provides the VPN layer for external access — no ports need exposure
- Authelia still enforces forward-auth for protected routes

## Important Constraints

- **Do not commit secrets.** `.env`, `*.key`, `*.pem`, `credentials.*`, `secrets.*` are gitignored.
- **Docker socket**: Privacy Shield's Docker socket approach is deprecated; use the host agent API instead.
- **llama-server default port**: Falls back to 8080 (not 11434 — Ollama's default).
- **Caddy is the only service** that binds to `0.0.0.0` — all others remain on `127.0.0.1`.
