FROM python:3.11-slim-bookworm

# ─── System dependencies ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ─── Install uv (fast Python package manager, required by Hermes) ──────────────
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# ─── Install Hermes Agent via official installer ───────────────────────────────
# --skip-setup skips interactive provider prompts; we configure via env vars
RUN curl -LsSf https://raw.githubusercontent.com/NousResearch/hermes-agent/main/install.sh \
    | bash -s -- --skip-setup

ENV PATH="/root/.hermes/bin:$PATH"

# ─── Runtime configuration ─────────────────────────────────────────────────────
# These are overridden at runtime via docker-compose environment:
ENV HERMES_API_SERVER_HOST=0.0.0.0
ENV HERMES_API_SERVER_PORT=8642
ENV HERMES_DATA_DIR=/data/hermes

WORKDIR /root/.hermes

# ─── Entrypoint: start the Hermes Agent API server ────────────────────────────
# Hermes serves an OpenAI-compatible API + its own tool execution engine
ENTRYPOINT ["hermes", "serve", "--host", "0.0.0.0", "--port", "8642"]

EXPOSE 8642

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8642/health || exit 1
