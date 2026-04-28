# Dream Server — Service Networking & Ports

```mermaid
flowchart LR
    subgraph external["External Access\n(Browser / Clients)"]
        browser["🌐 Browser\nlocalhost:3000"]
        git_client["🔧 Git Client\nlocalhost:3009/:2222"]
    end

    subgraph localhost_only["127.0.0.1 Only (No External Exposure)"]
        subgraph core_int["Core Internal"]
            llamaserver["llama-server\n:8080"]
            litellm["litellm\n:4000"]
            openwebui["open-webui\n:3000"]
            dashboard["dashboard\n:3001"]
            dashboard_api["dashboard-api\n:3002"]
        end

        subgraph optional_int["Optional Internal"]
            whisper["whisper\n:9000"]
            kokoro["kokoro TTS\n:8880"]
            comfyui["comfyui\n:8188"]
            qdrant["qdrant\n:6333"]
            embeddings["embeddings\n:8090"]
            docling["docling\n:5001"]
            hermes["hermes-agent\n:8642"]
            dreamforge["dreamforge\n:3010"]
            ape["ape\n:7890"]
            privacy_shield["privacy-shield\n:8085"]
            searxng["searxng\n:8888"]
            n8n["n8n\n:5678"]
            baserow["baserow\n:8110"]
        end

        subgraph observability_int["Observability Internal"]
            prometheus["prometheus\n:9090"]
            grafana["grafana\n:3007"]
            langfuse["langfuse\n:3006"]
            cadvisor["cadvisor\n:8083"]
            nodeexp["nodeexp\n:9100"]
            uptimekuma["uptimekuma\n:3008"]
        end

        subgraph infra_int["Infrastructure Internal"]
            vaultwarden["vaultwarden\n:8222"]
            forgejo["forgejo\n:3009"]
            authelia["authelia\n:9091"]
        end
    end

    subgraph lan_access["LAN Access (0.0.0.0)"]
        caddy["caddy\n:80/:443"]
    end

    subgraph host_network["Host Network (network_mode: host)"]
        nodeexp_host["nodeexp\nhost:9100"]
    end

    %% External → Caddy → Authelia → Services
    browser -->|"HTTPS :443"| caddy
    caddy -->|"forward-auth"| authelia
    caddy --> openwebui
    caddy --> dashboard
    caddy --> grafana
    caddy --> langfuse
    caddy --> n8n
    caddy --> baserow
    caddy --> forgejo
    caddy --> uptimekuma
    caddy --> vaultwarden

    %% Direct browser access (localhost)
    browser -.->|"localhost :3000"| openwebui
    browser -.->|"localhost :3001"| dashboard
    browser -.->|"localhost :3007"| grafana
    browser -.->|"localhost :3006"| langfuse
    browser -.->|"localhost :3008"| uptimekuma
    browser -.->|"localhost :3009"| forgejo
    browser -.->|"localhost :8222"| vaultwarden

    %% Git client → Forgejo SSH
    git_client -->|"SSH :2222"| forgejo

    %% Host → Node Exporter
    prometheus -->|"scrape :9100"| nodeexp_host

    style caddy fill:#e65100,color:#fff
    style authelia fill:#1565c0,color:#fff
    style nodeexp_host fill:#b71c1c,color:#fff
```

## Port Reference

| Port | Service | Bind | Auth | Notes |
|------|---------|------|------|-------|
| `:80` / `:443` | Caddy | `0.0.0.0` | N/A | LAN entry point + HTTPS |
| `:2222` | Forgejo SSH | `127.0.0.1` | SSH key | Remote Git push via tunnel |
| `:3000` | Open WebUI | `127.0.0.1` | Authelia | Chat UI |
| `:3001` | Dashboard | `127.0.0.1` | Authelia | Control center |
| `:3006` | Langfuse | `127.0.0.1` | Authelia | LLM observability |
| `:3007` | Grafana | `127.0.0.1` | Authelia | Metrics dashboards |
| `:3008` | Uptime Kuma | `127.0.0.1` | Authelia | Status monitoring |
| `:3009` | Forgejo | `127.0.0.1` | Authelia | Self-hosted Git |
| `:3010` | DreamForge | `127.0.0.1` | Bearer token | Agent system |
| `:4000` | LiteLLM | `127.0.0.1` | LITELLM_KEY | Unified LLM gateway |
| `:5001` | Docling | `127.0.0.1` | Internal only | Document ingestion |
| `:5678` | n8n | `127.0.0.1` | Authelia | Workflow automation |
| `:6333` | Qdrant | `127.0.0.1` | Internal only | Vector database |
| `:8080` | llama-server | `127.0.0.1` | Internal only | LLM inference |
| `:8083` | cAdvisor | `127.0.0.1` | Internal only | Container metrics |
| `:8085` | Privacy Shield | `127.0.0.1` | Internal only | PII redaction |
| `:8090` | TEI Embeddings | `127.0.0.1` | Internal only | Text embeddings |
| `:8110` | Baserow | `127.0.0.1` | Authelia | No-code database |
| `:8188` | ComfyUI | `127.0.0.1` | Internal only | Image generation |
| `:8222` | Vaultwarden | `127.0.0.1` | Self-managed | Password manager |
| `:8642` | Hermes Agent | `127.0.0.1` | Bearer token | Autonomous agent |
| `:8880` | Kokoro TTS | `127.0.0.1` | Internal only | Voice synthesis |
| `:8888` | SearXNG | `127.0.0.1` | Internal only | Web search |
| `:9000` | Whisper | `127.0.0.1` | Internal only | Speech-to-text |
| `:9090` | Prometheus | `127.0.0.1` | Authelia | Metrics DB |
| `:9091` | Authelia | `0.0.0.0` | Public (login) | SSO provider |
| `:9100` | Node Exporter | **host** | Internal only | Host metrics (no Docker port) |

## Network Zones

| Zone | Services | External Access |
|------|----------|-----------------|
| **Public** | Caddy, Authelia (login page) | LAN + remote (via Tailscale/VPN) |
| **Authelia Protected** | Open WebUI, Dashboard, Grafana, Langfuse, n8n, Baserow, Forgejo, Uptime Kuma | Via Caddy + SSO |
| **Internal Only** | llama-server, litellm, Whisper, Kokoro, ComfyUI, Qdrant, TEI, Docling, Privacy Shield, SearXNG, cAdvisor, Prometheus | Docker network only |
| **Host Network** | Node Exporter | Host network (no Docker proxy) |
| **Self-Managed Auth** | Vaultwarden | Direct localhost access |
