# Dream Server — Observability Stack

```mermaid
flowchart LR
    subgraph sources["Service Metrics / Traces"]
        llama["llama-server\n:8080"]
        litellm["litellm\n:4000"]
        hermes["hermes-agent\n:8642"]
        n8n["n8n\n:5678"]
        whisper["whisper\n:9000"]
        kokoro["kokoro TTS\n:8880"]
        comfyui["comfyui\n:8188"]
        openwebui["open-webui\n:3000"]
        dreamforge["dreamforge\n:3010"]
    end

    subgraph metrics_path["Metrics Pipeline"]
        direction TB
        cadvisor["cAdvisor\n:8083\n\nContainer-level\nCPU/mem/disk I/O"]
        nodeexp["Node Exporter\n:9100\n\nHost-level\nCPU/mem/disk/net\nGPU temp/hwmon"]
        prometheus["Prometheus\n:9090\n\nScrape → Store\nTime-series DB"]
    end

    subgraph traces_path["Traces Pipeline"]
        direction TB
        langfuse["Langfuse\n:3006\n\nLLM traces\nPrompt management\nCost analytics"]
    end

    subgraph uptime_path["Uptime Pipeline"]
        direction TB
        uptimekuma["Uptime Kuma\n:3008\n\nHTTP/TCP/ping\nUptime history\nAlert notifications"]
    end

    subgraph visualize["Visualization & Alerting"]
        grafana["Grafana\n:3007\n\nDashboards\nAlert rules"]
        n8n_alerts["n8n\nAlert workflows"]
        notification["Notification\nChannels"]
    end

    %% Metrics flow
    llama -->|"/metrics"| prometheus
    litellm -->|"/metrics"| prometheus
    hermes -->|"/metrics"| prometheus
    n8n -->|"/metrics"| prometheus

    llama --> cadvisor
    cadvisor --> prometheus
    nodeexp --> prometheus

    %% Traces flow
    llama -->|"Langfuse SDK"| langfuse
    litellm -->|"success_callback\nlangfuse"| langfuse

    %% Uptime flow
    uptimekuma -->|"webhook"| n8n_alerts

    %% Prometheus → Grafana
    prometheus -->|"query"| grafana
    langfuse -->|"langfuse webhook"| n8n_alerts

    %% Grafana → Alerting
    grafana -->|"alert fired"| n8n_alerts
    grafana -->|"alert fired"| notification

    %% n8n alert routing
    n8n_alerts -->|"slack/email/telegram"| notification

    style prometheus fill:#1b5e20,color:#fff
    style grafana fill:#1b5e20,color:#fff
    style langfuse fill:#0d47a1,color:#fff
    style cadvisor fill:#4e342e,color:#fff
    style nodeexp fill:#4e342e,color:#fff
    style uptimekuma fill:#006064,color:#fff
```

## Scrape Targets — Prometheus

| Target | Endpoint | Interval | Labels |
|--------|----------|----------|--------|
| llama-server | `llama-server:8080/metrics` | 30s | `job=dream-llama-server` |
| litellm | `litellm:4000/metrics` | 30s | `job=dream-litellm` |
| hermes-agent | `hermes-agent:8642/metrics` | 30s | `job=dream-hermes-agent` |
| n8n | `n8n:5678/metrics` | 30s | `job=dream-n8n` |
| cAdvisor | `cadvisor:8080/metrics` | 15s | `job=cadvisor` |
| Node Exporter | `host.docker.internal:9100` | 15s | `job=node-exporter` |
| Uptime Kuma | `uptime-kuma:3001/metrics` | 60s | `job=uptime-kuma` |
| Grafana | `grafana:3007/metrics` | 60s | `job=grafana` |

## Grafana Dashboards

| Dashboard | Source | Panels |
|-----------|--------|--------|
| LLM Observability | Prometheus | Request rate, error rate, p95 latency, token usage by model, container CPU/mem |
| cAdvisor Containers | Prometheus (cAdvisor) | Per-container CPU, memory, network I/O, disk I/O |
| Node Exporter Full | Prometheus (Node Exporter) | CPU, memory, disk, network, filesystem, loadavg, hwmon |
| Docker Monitoring | Prometheus (cAdvisor) | Container resource usage, network, filesystem |

## Alert Rules

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| LLM Server Down | `up{job="dream-llama-server"} == 0` | critical | 2m |
| GPU Memory > 90% | `container_memory_usage / container_spec_memory_limit > 0.9` | warning | 5m |
| Disk Usage > 90% | `node_filesystem_free / node_filesystem_size < 0.1` | warning | 5m |
