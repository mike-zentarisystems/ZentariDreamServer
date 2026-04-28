# DreamServer Upgrade: Gap Analysis

This document outlines the remaining tasks and configurations required to complete the DreamServer upgrade (Replace OpenClaw → Hermes Agent + New Extensions) and ensure the system is ready for production testing.

## Summary of Completed Changes

- [x] **Remove OpenClaw**: Extension moved to `_disabled/`, environment variables removed, and references in core config updated.
- [x] **Add Hermes Agent**: Extension directory created with `manifest.yaml` and `compose.yaml`.
- [x] **Add Baserow**: Extension directory created with `manifest.yaml` and `compose.yaml`.
- [x] **Add Monitoring**: Prometheus and Grafana extensions created with full configuration and provisioning.
- [x] **Add Authelia**: Authentication middleware extension created with `configuration.yml` and `users_database.yml`.
- [x] **Add Caddy**: Reverse proxy extension created with `Caddyfile` for routing and auth enforcement.
- [x] **Registry Updates**: `config/ports.json` and `config/core-service-ids.json` updated to reflect the new architecture.
- [x] **Environment Initialization**: `.env` file created with all required variables for the new services.

---

## Critical Gaps (Must Fix Before Startup)

### 1. Authelia Password Hash
The file `dream-server/config/authelia/users_database.yml` currently contains a placeholder for the admin password hash.
- **Action**: Generate an Argon2id hash and replace the placeholder.
- **Command**:
  ```bash
  docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'your-chosen-password'
  ```

### 2. Secret Rotation
The current `.env` file uses static placeholder values for critical secrets (e.g., `HERMES_API_KEY`, `AUTHELIA_JWT_SECRET`).
- **Action**: Rotate all secrets in `.env` using secure random strings.
- **Tip**: You can use `openssl rand -hex 32` to generate secure strings.

### 3. Script Line Endings (CRLF vs LF)
Several shell scripts, including `dream-cli`, were found to have CRLF (Windows) line endings. This will cause `command not found` errors when running via `bash`.
- **Action**: Convert all `.sh` and `dream-cli` files to LF line endings.
- **Command (Linux/WSL)**: `dos2unix dream-cli` or `sed -i 's/\r$//' dream-cli`.

### 4. Model File Availability
The `.env` is configured to use `Qwen3.5-9B-Q4_K_M.gguf`.
- **Action**: Ensure this file exists in `dream-server/data/models/`. If you wish to use a different model, update `GGUF_FILE` and `LLM_MODEL` in `.env`.

---

## Testing & Validation Steps

Once the critical gaps are addressed, follow these steps to validate the installation:

1. **Verify Registry**:
   ```bash
   bash ./dream-cli list
   ```
   *Expected: `hermes-agent`, `baserow`, `prometheus`, `grafana`, `authelia`, `caddy` should be listed.*

2. **Start the Stack**:
   ```bash
   # Note: Requires a working Docker environment
   docker compose -f docker-compose.base.yml -f docker-compose.nvidia.yml up -d
   ```

3. **Check Health**:
   ```bash
   bash ./dream-cli status
   ```

4. **Test Caddy Entrypoint**:
   Visit `https://localhost` (or `http://localhost` depending on Caddy config). You should be redirected to the Authelia login portal.

5. **Test Prometheus Scrape**:
   Check `http://localhost:9090/targets` to ensure all DreamServer services are being scraped successfully.

---

## Known Limitations / Future Work
- **LAN Access**: Caddy is currently configured for `localhost`. For LAN access, the `Caddyfile` and `AUTHELIA_PUBLIC_URL` (if applicable) must be updated with the host IP.
- **Persistent Data**: Ensure the Docker volumes defined in the new extensions are properly backed up during system migrations.
