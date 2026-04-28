# Dream Server — Architecture Overview

```mermaid
flowchart TB
    subgraph user["User Layer"]
        browser[("🌐 Browser")]
        voice[("🎤 Voice I/O")]
        mobile[("📱 Mobile Apps")]
    end

    subgraph ui["User Interfaces"]
        openwebui["Open WebUI\n:3000"]
        dashboard["Dashboard\n:3001"]
        grafana["Grafana\n:3007"]
    end

    subgraph gateway["Reverse Proxy / Auth"]
        caddy["Caddy\n:80/:443"]
        authelia["Authelia\n:9091"]
    end

    subgraph llm["LLM Inference Layer"]
        litellm["LiteLLM Gateway\n:4000"]
        llamiserver["llama-server\n:8080"]
    end

    subgraph agents["Agent Layer"]
        hermes["Hermes Agent\n:8642"]
        dreamforge["DreamForge\n:3010"]
        ape["APE\n:7890"]
    end

    subgraph voice_io["Voice I/O"]
        whisper["Whisper STT\n:9000"]
        kokoro["Kokoro TTS\n:8880"]
    end

    subgraph image["Image Generation"]
        comfyui["ComfyUI\n:8188"]
    end

    subgraph data["Data & RAG"]
        qdrant["Qdrant\n:6333"]
        embeddings["TEI Embeddings\n:8090"]
        docling["Docling\n:5001"]
        baserow["Baserow\n:8110"]
    end

    subgraph automation["Automation"]
        n8n["n8n\n:5678"]
    end

    subgraph search["Search"]
        searxng["SearXNG\n:8888"]
    end

    subgraph observability["Observability"]
        prometheus["Prometheus\n:9090"]
        grafana_dash["Grafana\nDashboards"]
        langfuse["Langfuse\n:3006"]
        cadvisor["cAdvisor\n:8083"]
        nodeexp["Node Exporter\n:9100"]
        uptimekuma["Uptime Kuma\n:3008"]
    end

    subgraph infra["Infrastructure"]
        vaultwarden["Vaultwarden\n:8222"]
        forgejo["Forgejo\n:3009/:2222"]
    end

    subgraph cloud["Cloud Providers (via LiteLLM)"]
        anthropic["Anthropic\nClaude"]
        openai["OpenAI\nGPT-4o"]
        minimax["MiniMax"]
        openrouter["OpenRouter\n100+ models"]
    end

    %% User connections
    browser --> openwebui
    browser --> dashboard
    browser --> grafana
    voice --> openwebui
    openwebui --> voice

    %% Gateway routing
    browser --> caddy
    caddy --> authelia
    caddy --> openwebui
    caddy --> dashboard
    caddy --> grafana

    %% LLM routing
    openwebui --> litellm
    litellm --> llamiserver
    litellm --> anthropic
    litellm --> openai
    litellm --> minimax
    litellm --> openrouter

    %% Agents
    litellm --> hermes
    hermes --> searxng
    hermes --> n8n
    hermes --> llamiserver
    litellm --> dreamforge
    dreamforge --> llamiserver
    dreamforge --> n8n
    ape --> hermes

    %% Voice
    openwebui --> whisper
    whisper --> litellm
    kokoro --> openwebui
    litellm --> kokoro

    %% Image
    openwebui --> comfyui

    %% RAG pipeline
    docling --> embeddings
    embeddings --> qdrant
    n8n --> docling
    n8n --> qdrant
    openwebui --> qdrant

    %% Automation
    n8n --> searxng
    n8n --> llamiserver
    langfuse -.-> n8n

    %% Search
    openwebui --> searxng

    %% Observability collection
    llamiserver --> prometheus
    litellm --> prometheus
    hermes --> prometheus
    n8n --> prometheus
    cadvisor --> prometheus
    grafana_dash -.-> prometheus
    langfuse -.-> prometheus

    uptimekuma -.-> llamiserver
    uptimekuma -.-> openwebui
    uptimekuma -.-> hermes
    uptimekuma -.-> n8n
    uptimekuma -.-> qdrant

    nodeexp --> prometheus
    langfuse --> llamiserver
    langfuse --> litellm

    %% Infrastructure
    caddy --> vaultwarden
    forgejo --> n8n
```

## Layer Summary

| Layer | Services | Access |
|-------|----------|--------|
| User Interfaces | Open WebUI, Dashboard, Grafana | Via Caddy (+ Authelia) |
| LLM Gateway | LiteLLM (local + cloud routing) | Internal only |
| Agents | Hermes, DreamForge, APE | Internal / Bearer token |
| Voice I/O | Whisper, Kokoro | Via Open WebUI |
| Data & RAG | Qdrant, TEI, Docling, Baserow | Internal only |
| Automation | n8n | Via Authelia |
| Search | SearXNG | Internal only |
| Observability | Prometheus, Grafana, Langfuse, Uptime Kuma | Via Authelia |
| Infrastructure | Vaultwarden, Forgejo | Self-managed |
| Image Gen | ComfyUI | Internal only |
