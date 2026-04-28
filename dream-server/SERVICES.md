# Dream Server Service Reference

## Core Services

| Service | Docker Container | Description | Port | Direct URL |
|--------|----------------|-------------|------|-----------|
| **llama-server** | `dream-llama-server` | LLM inference server (OpenAI-compatible API) | 8080 | `http://localhost:8080` |
| **open-webui** | `dream-webui` | Chat UI — web interface for AI chat, voice, file uploads | 3000 | `http://localhost:3000` |
| **dashboard-api** | `dream-dashboard-api` | Backend API for DreamServer dashboard and system management | 3002 | `http://localhost:3002/health` |
| **dashboard** | `dream-dashboard` | Control center UI — GPU status, service health, model management | 3001 | `http://localhost:3001` |
| **searxng** | `dream-searxng` | Privacy-respecting metasearch engine — aggregates Google, DuckDuckGo, Brave, Wikipedia, GitHub | 8888 | `http://localhost:8888` |

## Recommended Services

| Service | Docker Container | Description | Port | Direct URL |
|--------|----------------|-------------|------|-----------|
| **litellm** | `dream-litellm` | Unified API gateway for multiple LLM providers — local models, Claude, GPT-4, Gemini | 4000 | `http://localhost:4000` / `http://localhost:4000/ui/` |
| **token-spy** | `dream-token-spy` | LLM token usage monitoring and cost tracking dashboard | 3005 | `http://localhost:3005/dashboard` |

## Optional Services

| Service | Docker Container | Description | Port | Direct URL |
|--------|----------------|-------------|------|-----------|
| **hermes-agent** | `dream-hermes-agent` | Nous Research autonomous agent — multi-step reasoning, web search, file operations | 8642 | `http://localhost:8642` |
| **n8n** | `dream-n8n` | Workflow automation — 400+ integrations (Slack, email, databases, APIs) with visual editor | 5678 | `http://localhost:5678` |
| **qdrant** | `dream-qdrant` | Vector database for semantic search and RAG — stores embeddings for document retrieval | 6333 | `http://localhost:6333` |
| **embeddings** (TEI) | `dream-embeddings` | Text Embeddings Inference service — converts text to vectors for RAG pipelines | 8090 | `http://localhost:8090/info` |
| **perplexica** | `dream-perplexica` | AI-powered deep research agent — searches web, synthesizes findings, cites sources | 3004 | `http://localhost:3004` |
| **comfyui** | `dream-comfyui` | Image generation via FLUX.1 — node-based visual workflow editor for AI image pipelines | 8188 | `http://localhost:8188` |
| **whisper** | `dream-whisper` | Speech-to-text — converts spoken audio to text for voice conversations | 9000 | `http://localhost:9000` |
| **kokoro** (TTS) | `dream-tts` | Text-to-speech voice synthesis — generates natural audio from text responses | 8880 | `http://localhost:8880/docs` |
| **privacy-shield** | `dream-privacy-shield` | PII detection and redaction — scrubs sensitive data from API calls before forwarding | 8085 | `http://localhost:8085/docs` |
| **dreamforge** | `dream-dreamforge` | Local agent system with 40+ tools — file editing, bash execution, search, MCP integration | 3010 | `http://localhost:3010` |
| **langfuse** | `dream-langfuse-web` | LLM observability platform — traces, prompt management, latency/cost analytics | 3006 | `http://localhost:3006` |
| **baserow** | `dream-baserow` | Low-code database and app builder — spreadsheet-like interface with API and automation | 8110 | `http://localhost:8110` |
| **prometheus** | `dream-prometheus` | Metrics collection and time-series database — scrapes and stores service metrics | 9090 | `http://localhost:9090` |
| **grafana** | `dream-grafana` | Metrics visualization dashboards — charts, alerting, and monitoring | 3007 | `http://localhost:3007` |
| **authelia** | `dream-authelia` | Single sign-on and authentication — SSO provider for protected services | 9091 | `http://localhost:9091` |
| **caddy** | `dream-caddy` | Reverse proxy with automatic HTTPS — gateway for all services when LAN access is enabled | 80 | `http://localhost` |
| **ape** | `dream-ape` | Agent Policy Engine — intercepts and audits agent tool calls with configurable allow/deny rules | 7890 | `http://localhost:7890` |
| **cadvisor** | `dream-cadvisor` | Per-container CPU, memory, network, and disk I/O metrics — fed into Prometheus | 8083 | `http://localhost:8083` |
| **node-exporter** | `dream-node-exporter` | Host-level metrics — CPU, memory, disk, network, filesystem, GPU temp | 9100 | `http://localhost:9100` |
| **uptime-kuma** | `dream-uptime-kuma` | Service uptime history and alerting — HTTP/TCP/ping monitors with notifications | 3008 | `http://localhost:3008` |
| **docling** | `dream-docling` | IBM Research document parser — converts PDFs, DOCX, PPTX, HTML to structured markdown for RAG | 5001 | `http://localhost:5001` |
| **vaultwarden** | `dream-vaultwarden` | Self-hosted Bitwarden password manager — browser extension, mobile apps, API | 8222 | `http://localhost:8222` |
| **forgejo** | `dream-forgejo` | Self-hosted Git — version-control n8n workflows, prompts, Baserow schemas, Caddyfiles | 3009 | `http://localhost:3009` |

## Host-System Services

| Service | Type | Description | Port | Direct URL |
|---------|------|-------------|------|-----------|
| **opencode** | Host systemd | Browser-based code editor with AI assistance | 3003 | `http://localhost:3003` |
| **glances** | Host pip | Cross-platform system monitoring — CPU, memory, disk, network, GPU, containers; terminal and web UI | 61208 | `http://localhost:61208` |

## Cloud API Providers

These are external API services accessed via LiteLLM gateway. Set API keys in `.env` to enable.

| Provider | Environment Variable | Description |
|----------|---------------------|-------------|
| **MiniMax** | `MINIMAX_API_KEY` | MiniMax native LLM inference — efficient, low-cost, good for Chinese language tasks |
| **OpenRouter** | `OPENROUTER_API_KEY` | Unified gateway to 100+ LLMs — Claude, GPT-4, Gemini, Llama, Mistral via single API key |
| **Anthropic** | `ANTHROPIC_API_KEY` | Claude models — Sonnet, Haiku, Opus |
| **OpenAI** | `OPENAI_API_KEY` | GPT-4o, GPT-4-turbo models |
| **Together AI** | `TOGETHER_API_KEY` | Open-source models — Llama, Mistral, Qwen |

## Host Tools

These tools run on the host system (not in Docker).

### Glances — System Monitoring

**Install:** `pip install --user glances[all]` or `dream glances install`

**CLI:** `dream glances [install|status|web|top]`

| Feature | Command | Description |
|---------|---------|-------------|
| Browser dashboard | `dream glances web` | Opens `http://localhost:61208` — full web UI with CPU, memory, disk, network, GPU, Docker containers |
| Terminal view | `dream glances top` | Quick htop-like terminal view with all metrics |
| Install | `dream glances install` | One-time install via pip |
| Status | `dream glances status` | Check if Glances is installed |

Glances auto-detects NVIDIA GPUs (via `nvidia-smi`), Docker containers (via `docker`), and all standard system metrics. Customize the port with `GLANCES_PORT` in `.env`.

## Notes

- All Docker services bind to `127.0.0.1` by default (localhost-only). Only **caddy** binds to `0.0.0.0` when enabled for LAN access.
- **hermes-agent** connects to Open WebUI automatically via `OPENAI_API_BASE_URLS` / `OPENAI_API_KEYS` injection — no manual URL wiring needed.
- **grafana** depends on **prometheus** being healthy first.
- **caddy** depends on **authelia** for forward-authentication on protected routes.
- **dreamforge** and **ape** depend on **llama-server** being available.
- **node-exporter** uses `network_mode: host` — port 9100 cannot be bound to `127.0.0.1`. Ensure firewall blocks it externally.
- **cadvisor** requires `privileged: true` for container runtime access — expected for monitoring agents.
- **vaultwarden** uses its own auth system — keep on `127.0.0.1`, do not put behind Authelia (double-auth on a password manager creates lockout risk).
- **forgejo** SSH (port 2222) is bound to `127.0.0.1` only — use Caddy TCP proxying or SSH tunnel for remote push access.

## Complete Port Reference

| Port | Service | Auth | Notes |
|------|---------|------|-------|
| 80/443 | Caddy | N/A | Entry point for LAN access |
| 2222 | Forgejo SSH | SSH key | Bound to 127.0.0.1; use tunnel for remote |
| 3000 | Open WebUI | Authelia | Chat UI |
| 3001 | Dashboard | Authelia | Control center |
| 3006 | Langfuse | Authelia | LLM observability |
| 3007 | Grafana | Authelia | Metrics dashboards |
| 3008 | Uptime Kuma | Authelia | Status monitoring |
| 3009 | Forgejo | Authelia | Self-hosted Git |
| 3010 | DreamForge | Bearer token | Agent system |
| 4000 | LiteLLM | LITELLM_KEY | Unified LLM gateway |
| 5001 | Docling | Internal only | Document ingestion API |
| 5678 | n8n | Authelia | Workflow automation |
| 6333 | Qdrant | Internal only | Vector database |
| 8080 | llama-server | Internal only | LLM inference |
| 8083 | cAdvisor | Internal only | Container metrics |
| 8085 | Privacy Shield | Internal only | PII redaction |
| 8090 | TEI Embeddings | Internal only | Text embeddings |
| 8110 | Baserow | Authelia | No-code database |
| 8188 | ComfyUI | Internal only | Image generation |
| 8222 | Vaultwarden | Self-managed | Password manager |
| 8642 | Hermes Agent | Bearer token | Autonomous agent |
| 8880 | Kokoro TTS | Internal only | Voice synthesis |
| 8888 | SearXNG | Internal only | Web search |
| 9000 | Whisper | Internal only | Speech-to-text |
| 9090 | Prometheus | Authelia | Metrics collection |
| 9091 | Authelia | Public (login) | SSO provider |
| 9100 | Node Exporter | Internal only | Host metrics |
| 11434 | Ollama (alt) | Internal only | Alternative LLM server |
