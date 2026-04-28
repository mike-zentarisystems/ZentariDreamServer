# DreamServer Upgrade Prompt: Replace OpenClaw → Hermes Agent + Add New Extensions

## Context

You are modifying an existing DreamServer installation (v2.3+). DreamServer uses a manifest-based extension system: every service lives in `dream-server/extensions/services/<id>/` with a `manifest.yaml` and a `compose.yaml`. Services are enabled/disabled via the `dream` CLI and composed dynamically by `resolve-compose-stack.sh`. All services bind to `127.0.0.1` by default. The `.env` file controls all runtime config.

## Objectives

Perform the following changes to the DreamServer repository and installation:

1. **Remove OpenClaw** — disable and remove the OpenClaw extension
2. **Add Hermes Agent** — replace OpenClaw as the agent backend
3. **Add Hermes Agent Web Dashboard** — the built-in Hermes TUI/web UI
4. **Add Baserow** — lightweight self-hosted database/app builder
5. **Add Prometheus + Grafana** — metrics collection and dashboards
6. **Add Authelia** — SSO / authentication middleware
7. **Add Caddy** — reverse proxy with automatic HTTPS and route-based auth enforcement

***

## STEP 1: Remove OpenClaw

### 1a. Disable OpenClaw via CLI
```bash
dream disable openclaw
```

### 1b. Remove OpenClaw env vars from `.env`
Remove the following lines from `dream-server/.env`:
```
OPENCLAW_TOKEN=...
OPENCLAW_PORT=...
OPENCLAW_HOST=...
```

### 1c. Remove the Open WebUI multi-backend wiring for OpenClaw
In `dream-server/extensions/services/openclaw/compose.yaml`, the `open-webui` service override injected:
```yaml
open-webui:
  environment:
    - OPENAI_API_BASE_URLS=${LLM_API_URL:-http://llama-server:8080}/v1;http://openclaw:18790/v1
    - OPENAI_API_KEYS=;${OPENCLAW_TOKEN:-}
```
This will be replaced in Step 2 with Hermes Agent's equivalent wiring.

### 1d. (Optional) Archive the OpenClaw extension folder
```bash
mv dream-server/extensions/services/openclaw dream-server/extensions/services/_disabled/openclaw
```

***

## STEP 2: Add Hermes Agent

### 2a. Create the extension directory
```
dream-server/extensions/services/hermes-agent/
├── manifest.yaml
└── compose.yaml
```

### 2b. Write `manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: hermes-agent
  name: Hermes Agent (Nous Research)
  aliases: []
  container_name: dream-hermes-agent
  host_env: HERMES_HOST
  default_host: hermes-agent
  port: 8642
  external_port_env: HERMES_PORT
  external_port_default: 8642
  health: /health
  ui_path: /
  type: docker
  gpu_backends: [all]
  compose_file: compose.yaml
  category: optional
  depends_on: [llama-server, searxng]
  env_vars:
    - key: HERMES_API_KEY
      required: true
      secret: true
      description: Bearer token for Hermes Agent API server
    - key: HERMES_PORT
      required: false
      secret: false
      description: External port for Hermes Agent API (default 8642)
```

### 2c. Write `compose.yaml`
```yaml
services:
  hermes-agent:
    image: ghcr.io/nousresearch/hermes-agent:latest
    container_name: dream-hermes-agent
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    environment:
      - API_SERVER_ENABLED=true
      - API_SERVER_HOST=0.0.0.0
      - API_SERVER_PORT=8642
      - API_SERVER_KEY=${HERMES_API_KEY:?Set HERMES_API_KEY in .env}
      - LLM_BASE_URL=${LLM_API_URL:-http://llama-server:8080}/v1
      - LLM_API_KEY=${LITELLM_KEY:-}
      - SEARXNG_URL=http://searxng:8080
    volumes:
      - hermes-agent-data:/home/hermes/.hermes
    ports:
      - "${BIND_ADDRESS:-127.0.0.1}:${HERMES_PORT:-8642}:8642"
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 1G
    depends_on:
      searxng:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:8642/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 45s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Register Hermes Agent as a second model backend in Open WebUI
  # (mirrors the OpenClaw pattern for Open WebUI multi-backend support)
  open-webui:
    environment:
      - OPENAI_API_BASE_URLS=${LLM_API_URL:-http://llama-server:8080}/v1;http://hermes-agent:8642/v1
      - OPENAI_API_KEYS=;${HERMES_API_KEY:-}

volumes:
  hermes-agent-data:
```

### 2d. Add to `.env`
```dotenv
# Hermes Agent
HERMES_API_KEY=<generate-a-strong-random-string>
HERMES_PORT=8642
HERMES_HOST=hermes-agent
```

### 2e. Enable the extension
```bash
dream enable hermes-agent
```

***

## STEP 3: Add Hermes Agent Web Dashboard

Hermes ships a web-based dashboard UI accessible when the gateway is running. It is exposed on the same port as the API server (port 8642) at the `/` path. No separate container is needed — the `hermes-agent` service from Step 2 already serves it.

### 3a. Register the dashboard as a service entry in the DreamServer dashboard

Add a dashboard sidebar entry for Hermes UI by including the following in the manifest (already included in Step 2b):
```yaml
  ui_path: /
```

This tells the DreamServer dashboard to link to `http://localhost:8642/` as the Hermes UI. No additional extension is required.

### 3b. (Optional) Add a dedicated manifest alias
If you want a separate "Hermes Dashboard" tile in the DreamServer UI, create a lightweight `hermes-dashboard` virtual extension that references the same port with a `ui_path` of `/dashboard` (if Hermes exposes one). Otherwise, the `/` path from Step 2b is sufficient.

***

## STEP 4: Add Baserow

### 4a. Create the extension directory
```
dream-server/extensions/services/baserow/
├── manifest.yaml
└── compose.yaml
```

### 4b. Write `manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: baserow
  name: Baserow (Database / App Builder)
  aliases: []
  container_name: dream-baserow
  host_env: BASEROW_HOST
  default_host: baserow
  port: 80
  external_port_env: BASEROW_PORT
  external_port_default: 8110
  health: /api/_health/
  ui_path: /
  type: docker
  gpu_backends: [cpu, none]
  compose_file: compose.yaml
  category: optional
  depends_on: []
  env_vars:
    - key: BASEROW_PORT
      required: false
      secret: false
      description: External port for Baserow UI (default 8110)
    - key: BASEROW_SECRET_KEY
      required: true
      secret: true
      description: Django secret key for Baserow
    - key: BASEROW_JWT_SIGNING_KEY
      required: true
      secret: true
      description: JWT signing key for Baserow auth
```

### 4c. Write `compose.yaml`
```yaml
services:
  baserow:
    image: baserow/baserow:1.28
    container_name: dream-baserow
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    environment:
      - BASEROW_PUBLIC_URL=http://localhost:${BASEROW_PORT:-8110}
      - SECRET_KEY=${BASEROW_SECRET_KEY:?Set BASEROW_SECRET_KEY in .env}
      - JWT_SIGNING_KEY=${BASEROW_JWT_SIGNING_KEY:?Set BASEROW_JWT_SIGNING_KEY in .env}
      - DATABASE_URL=sqlite:////baserow/data/baserow.db
    volumes:
      - baserow-data:/baserow/data
    ports:
      - "${BIND_ADDRESS:-127.0.0.1}:${BASEROW_PORT:-8110}:80"
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://127.0.0.1/api/_health/ || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  baserow-data:
```

### 4d. Add to `.env`
```dotenv
# Baserow
BASEROW_PORT=8110
BASEROW_SECRET_KEY=<generate-a-strong-random-string>
BASEROW_JWT_SIGNING_KEY=<generate-a-separate-strong-random-string>
BASEROW_HOST=baserow
```

### 4e. Enable the extension
```bash
dream enable baserow
```

***

## STEP 5: Add Prometheus + Grafana

### 5a. Create the extension directories
```
dream-server/extensions/services/prometheus/
├── manifest.yaml
└── compose.yaml
dream-server/extensions/services/grafana/
├── manifest.yaml
└── compose.yaml
```

You may implement these as a single extension (`monitoring`) or two separate ones. Separate manifests are recommended so each can be independently enabled/disabled.

***

### Prometheus

#### `prometheus/manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: prometheus
  name: Prometheus (Metrics)
  container_name: dream-prometheus
  host_env: PROMETHEUS_HOST
  default_host: prometheus
  port: 9090
  external_port_env: PROMETHEUS_PORT
  external_port_default: 9090
  health: /-/healthy
  ui_path: /
  type: docker
  gpu_backends: [cpu, none]
  compose_file: compose.yaml
  category: optional
  depends_on: []
  env_vars:
    - key: PROMETHEUS_PORT
      required: false
      secret: false
      description: External port for Prometheus UI (default 9090)
```

#### `prometheus/compose.yaml`
```yaml
services:
  prometheus:
    image: prom/prometheus:v3.3.1
    container_name: dream-prometheus
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    volumes:
      - ./config/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    ports:
      - "${BIND_ADDRESS:-127.0.0.1}:${PROMETHEUS_PORT:-9090}:9090"
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:9090/-/healthy || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  prometheus-data:
```

#### Create `dream-server/config/prometheus/prometheus.yml`
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'dream-dashboard-api'
    static_configs:
      - targets: ['dashboard-api:3002']
    metrics_path: '/metrics'

  - job_name: 'dream-llama-server'
    static_configs:
      - targets: ['llama-server:8080']
    metrics_path: '/metrics'

  - job_name: 'dream-cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'dream-node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

***

### Grafana

#### `grafana/manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: grafana
  name: Grafana (Dashboards)
  container_name: dream-grafana
  host_env: GRAFANA_HOST
  default_host: grafana
  port: 3000
  external_port_env: GRAFANA_PORT
  external_port_default: 3007
  health: /api/health
  ui_path: /
  type: docker
  gpu_backends: [cpu, none]
  compose_file: compose.yaml
  category: optional
  depends_on: [prometheus]
  env_vars:
    - key: GRAFANA_PORT
      required: false
      secret: false
      description: External port for Grafana UI (default 3007)
    - key: GRAFANA_ADMIN_PASSWORD
      required: true
      secret: true
      description: Grafana admin password
```

#### `grafana/compose.yaml`
```yaml
services:
  grafana:
    image: grafana/grafana:11.6.1
    container_name: dream-grafana
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:?Set GRAFANA_ADMIN_PASSWORD in .env}
      - GF_SECURITY_ADMIN_USER=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_ROOT_URL=http://localhost:${GRAFANA_PORT:-3007}
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - grafana-data:/var/lib/grafana
      - ./config/grafana/provisioning:/etc/grafana/provisioning:ro
    ports:
      - "${BIND_ADDRESS:-127.0.0.1}:${GRAFANA_PORT:-3007}:3000"
    depends_on:
      prometheus:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:3000/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  grafana-data:
```

#### Create `dream-server/config/grafana/provisioning/datasources/prometheus.yaml`
```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

### 5b. Add to `.env`
```dotenv
# Prometheus + Grafana
PROMETHEUS_PORT=9090
GRAFANA_PORT=3007
GRAFANA_ADMIN_PASSWORD=<generate-a-strong-random-string>
PROMETHEUS_HOST=prometheus
GRAFANA_HOST=grafana
```

### 5c. Enable the extensions
```bash
dream enable prometheus
dream enable grafana
```

***

## STEP 6: Add Authelia (Authentication / SSO)

Authelia provides LDAP-free, single-factor or MFA authentication in front of any service routed through Caddy (added in Step 7).

### 6a. Create the extension directory
```
dream-server/extensions/services/authelia/
├── manifest.yaml
└── compose.yaml
```

#### `authelia/manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: authelia
  name: Authelia (Authentication)
  container_name: dream-authelia
  host_env: AUTHELIA_HOST
  default_host: authelia
  port: 9091
  external_port_env: AUTHELIA_PORT
  external_port_default: 9091
  health: /api/health
  ui_path: /
  type: docker
  gpu_backends: [cpu, none]
  compose_file: compose.yaml
  category: optional
  depends_on: []
  env_vars:
    - key: AUTHELIA_JWT_SECRET
      required: true
      secret: true
      description: JWT secret for Authelia session tokens
    - key: AUTHELIA_SESSION_SECRET
      required: true
      secret: true
      description: Session encryption secret
    - key: AUTHELIA_STORAGE_ENCRYPTION_KEY
      required: true
      secret: true
      description: Storage encryption key (min 20 chars)
```

#### `authelia/compose.yaml`
```yaml
services:
  authelia:
    image: authelia/authelia:4.38
    container_name: dream-authelia
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    environment:
      - AUTHELIA_JWT_SECRET=${AUTHELIA_JWT_SECRET:?Set AUTHELIA_JWT_SECRET in .env}
      - AUTHELIA_SESSION_SECRET=${AUTHELIA_SESSION_SECRET:?Set AUTHELIA_SESSION_SECRET in .env}
      - AUTHELIA_STORAGE_ENCRYPTION_KEY=${AUTHELIA_STORAGE_ENCRYPTION_KEY:?Set AUTHELIA_STORAGE_ENCRYPTION_KEY in .env}
    volumes:
      - ./config/authelia:/config
      - authelia-data:/var/lib/authelia
    ports:
      - "${BIND_ADDRESS:-127.0.0.1}:${AUTHELIA_PORT:-9091}:9091"
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:9091/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  authelia-data:
```

### 6b. Create `dream-server/config/authelia/configuration.yml`
```yaml
---
server:
  host: 0.0.0.0
  port: 9091

log:
  level: info

jwt_secret: "{{ env \"AUTHELIA_JWT_SECRET\" }}"

default_redirection_url: https://localhost

totp:
  issuer: dreamserver.local

authentication_backend:
  file:
    path: /config/users_database.yml
    password:
      algorithm: argon2id
      iterations: 1
      salt_length: 16
      parallelism: 8
      memory: 64

access_control:
  default_policy: deny
  rules:
    # Allow unauthenticated health checks
    - domain: "localhost"
      resources:
        - "^/api/health$"
      policy: bypass
    # Require auth for all dashboard and management services
    - domain: "localhost"
      policy: one_factor

session:
  name: authelia_session
  secret: "{{ env \"AUTHELIA_SESSION_SECRET\" }}"
  expiration: 3600
  inactivity: 300
  domain: localhost

regulation:
  max_retries: 3
  find_time: 120
  ban_time: 300

storage:
  local:
    path: /var/lib/authelia/db.sqlite3
  encryption_key: "{{ env \"AUTHELIA_STORAGE_ENCRYPTION_KEY\" }}"

notifier:
  disable_startup_check: false
  filesystem:
    filename: /config/notification.txt
```

### 6c. Create `dream-server/config/authelia/users_database.yml`
```yaml
---
users:
  admin:
    displayname: "DreamServer Admin"
    # Generate with: docker run authelia/authelia:latest authelia crypto hash generate argon2 --password 'your-password'
    password: "$argon2id$v=19$m=65536,t=3,p=4$<replace-with-generated-hash>"
    email: admin@dreamserver.local
    groups:
      - admins
```

> **IMPORTANT**: Generate the password hash before enabling Authelia:
> ```bash
> docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'your-chosen-password'
> ```
> Replace the `password:` value in `users_database.yml` with the output.

### 6d. Add to `.env`
```dotenv
# Authelia
AUTHELIA_PORT=9091
AUTHELIA_HOST=authelia
AUTHELIA_JWT_SECRET=<generate-a-strong-random-string-32+chars>
AUTHELIA_SESSION_SECRET=<generate-a-strong-random-string-32+chars>
AUTHELIA_STORAGE_ENCRYPTION_KEY=<generate-a-strong-random-string-20+chars>
```

### 6e. Enable the extension
```bash
dream enable authelia
```

***

## STEP 7: Add Caddy (Reverse Proxy)

Caddy auto-manages HTTPS (with self-signed certs for localhost), routes traffic to internal services, and enforces Authelia forward auth on protected routes.

### 7a. Create the extension directory
```
dream-server/extensions/services/caddy/
├── manifest.yaml
└── compose.yaml
```

#### `caddy/manifest.yaml`
```yaml
schema_version: dream.services.v1

compatibility:
  dream_min: "2.0.0"

service:
  id: caddy
  name: Caddy (Reverse Proxy)
  container_name: dream-caddy
  host_env: CADDY_HOST
  default_host: caddy
  port: 80
  external_port_env: CADDY_HTTP_PORT
  external_port_default: 80
  health: /healthz
  ui_path: /
  type: docker
  gpu_backends: [cpu, none]
  compose_file: compose.yaml
  category: optional
  depends_on: [authelia]
  env_vars:
    - key: CADDY_HTTP_PORT
      required: false
      secret: false
      description: Caddy HTTP port (default 80)
    - key: CADDY_HTTPS_PORT
      required: false
      secret: false
      description: Caddy HTTPS port (default 443)
```

#### `caddy/compose.yaml`
```yaml
services:
  caddy:
    image: caddy:2.9-alpine
    container_name: dream-caddy
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_add:
      - NET_BIND_SERVICE
    volumes:
      - ./config/caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy-data:/data
      - caddy-config:/config
    ports:
      - "0.0.0.0:${CADDY_HTTP_PORT:-80}:80"
      - "0.0.0.0:${CADDY_HTTPS_PORT:-443}:443"
    depends_on:
      authelia:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  caddy-data:
  caddy-config:
```

> **Note:** Caddy binds to `0.0.0.0` (all interfaces) intentionally — it IS the public entrypoint. All other services remain on `127.0.0.1`. Authelia enforces authentication before any request reaches a backend service.

### 7b. Create `dream-server/config/caddy/Caddyfile`
```caddyfile
{
  # Use internal CA for localhost (self-signed)
  local_certs
  # Enable the admin API on localhost only
  admin localhost:2019
}

# Health check endpoint (no auth required)
http://localhost/healthz {
  respond "OK" 200
}

# ─── Authelia forward-auth snippet ───────────────────────────────────────────
(authelia_forward_auth) {
  forward_auth authelia:9091 {
    uri /api/authz/forward-auth
    copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
  }
}

# ─── Open WebUI (Chat) ────────────────────────────────────────────────────────
localhost:3000 {
  import authelia_forward_auth
  reverse_proxy open-webui:3000
}

# ─── DreamServer Dashboard ───────────────────────────────────────────────────
localhost:3001 {
  import authelia_forward_auth
  reverse_proxy dashboard:3001
}

# ─── Hermes Agent API (used by Open WebUI — bypass auth for API calls) ────────
localhost:8642 {
  reverse_proxy hermes-agent:8642
}

# ─── Baserow ─────────────────────────────────────────────────────────────────
localhost:8110 {
  import authelia_forward_auth
  reverse_proxy baserow:80
}

# ─── n8n ─────────────────────────────────────────────────────────────────────
localhost:5678 {
  import authelia_forward_auth
  reverse_proxy n8n:5678
}

# ─── Grafana ─────────────────────────────────────────────────────────────────
localhost:3007 {
  import authelia_forward_auth
  reverse_proxy grafana:3000
}

# ─── Prometheus ──────────────────────────────────────────────────────────────
localhost:9090 {
  import authelia_forward_auth
  reverse_proxy prometheus:9090
}

# ─── Authelia itself (login portal) ──────────────────────────────────────────
localhost:9091 {
  reverse_proxy authelia:9091
}

# ─── Perplexica ──────────────────────────────────────────────────────────────
localhost:3004 {
  import authelia_forward_auth
  reverse_proxy perplexica:3000
}

# ─── ComfyUI ─────────────────────────────────────────────────────────────────
localhost:8188 {
  import authelia_forward_auth
  reverse_proxy comfyui:8188
}
```

> **Customization notes:**
> - For LAN access (e.g., `http://192.168.x.x`), replace `localhost` with your machine's hostname or IP throughout the Caddyfile.
> - For external domain access with real HTTPS certs, replace `localhost` with your domain name and remove `local_certs` from the global block — Caddy will auto-provision Let's Encrypt certs.
> - Hermes Agent API is intentionally left without forward auth because it uses its own `API_SERVER_KEY` bearer token authentication, which Open WebUI sends in every request.

### 7c. Add to `.env`
```dotenv
# Caddy
CADDY_HTTP_PORT=80
CADDY_HTTPS_PORT=443
CADDY_HOST=caddy
```

### 7d. Enable the extension
```bash
dream enable caddy
```

***

## STEP 8: Final Validation

### 8a. Verify all new extensions are registered
```bash
dream list
```
Expected output should show: `hermes-agent`, `baserow`, `prometheus`, `grafana`, `authelia`, `caddy` as enabled. `openclaw` should be disabled or absent.

### 8b. Check service health
```bash
dream status
```
Wait for all new services to report healthy. Hermes Agent may take 45–60s to initialize on first run.

### 8c. Verify Open WebUI sees Hermes Agent
1. Open `http://localhost:3000` (or through Caddy)
2. Log in via Authelia if prompted
3. In Open WebUI → Admin Settings → Connections → OpenAI, verify `http://hermes-agent:8642/v1` is listed
4. In the model dropdown, `hermes-agent` should appear alongside your local LLM

### 8d. Verify Grafana connects to Prometheus
1. Open `http://localhost:3007`
2. Log in with `admin` / your `GRAFANA_ADMIN_PASSWORD`
3. Go to Configuration → Data Sources → Prometheus → Test → "Data source is working"

### 8e. Verify Authelia is protecting services
1. Open a protected route (e.g., `http://localhost:3001`)
2. You should be redirected to `http://localhost:9091` for login
3. Log in with your credentials from `users_database.yml`
4. You should be redirected back to the service

### 8f. Run the DreamServer test suite
```bash
cd dream-server
bash installers/tests/validate.sh
```

***

## Port Reference After Upgrade

| Port | Service | Auth Protected |
|------|---------|----------------|
| 80/443 | Caddy (entry point) | N/A |
| 3000 | Open WebUI | ✅ Authelia |
| 3001 | DreamServer Dashboard | ✅ Authelia |
| 3007 | Grafana | ✅ Authelia |
| 5678 | n8n | ✅ Authelia |
| 8110 | Baserow | ✅ Authelia |
| 8642 | Hermes Agent API | Bearer token (API_SERVER_KEY) |
| 9090 | Prometheus | ✅ Authelia |
| 9091 | Authelia (login portal) | Public |

***

## Security Notes

- All services except Caddy remain bound to `127.0.0.1`. Caddy is the only service that binds to `0.0.0.0`.
- Hermes Agent uses its own bearer token auth (`HERMES_API_KEY`) and does not need Authelia forward auth — the Caddyfile passes it through directly.
- The Authelia `users_database.yml` uses Argon2id password hashing. Never commit this file with a real password hash to a public repository.
- Rotate all generated secrets (`HERMES_API_KEY`, `BASEROW_SECRET_KEY`, `AUTHELIA_JWT_SECRET`, etc.) before any network exposure.
- For production or LAN-facing deployments, consider replacing the file-based Authelia user backend with an LDAP or OIDC provider, and enabling TOTP in `configuration.yml`.



