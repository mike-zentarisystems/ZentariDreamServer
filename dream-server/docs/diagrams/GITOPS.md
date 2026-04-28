# Dream Server — GitOps & Automation Workflow

```mermaid
flowchart TB
    subgraph forgejo["Forgejo (:3009)"]
        repo_config["dreamserver-config\nCaddyfile, prometheus.yml,\nauthelia config"]
        repo_n8n["n8n-workflows\nExported workflow JSON"]
        repo_prompts["prompt-library\nVersioned prompt templates"]
        repo_schemas["baserow-schemas\nTable exports"]
    end

    subgraph github_actions["GitHub Actions CI"]
        ci_health["Stack Health Check\nEvery 30 min / on push"]
        ci_backup["Nightly Backup Check\nDaily 3am"]
        ci_sync_prompts["Prompt Sync\nDaily 2am: Langfuse → Git"]
    end

    subgraph n8n["n8n (:5678) — Automation"]
        wf_backup["Nightly Backup\n→ dream backup API"]
        wf_langfuse["Langfuse Webhook\n→ HMAC verify → route by event"]
        wf_notify["Alert Handler\n→ Slack / Email / Telegram"]
        wf_github_push["Workflow Exporter\n→ Forgejo commit nightly"]
    end

    subgraph observability["Observability"]
        prometheus["Prometheus (:9090)"]
        grafana["Grafana (:3007)"]
        langfuse["Langfuse (:3006)"]
        uptimekuma["Uptime Kuma (:3008)"]
    end

    subgraph dreamserver["DreamServer Stack"]
        llama["llama-server"]
        litellm["litellm"]
        hermes["hermes-agent"]
        dashboard_api["dashboard-api"]
    end

    %% CI flows
    ci_health -->|"curl health checks"| dreamserver
    ci_health -->|"/api/v1/targets"| prometheus
    ci_backup -->|"POST /api/backups"| dashboard_api
    ci_sync_prompts -->|"fetch prompts API"| langfuse
    ci_sync_prompts -->|"git push"| repo_prompts

    %% n8n flows
    uptimekuma -->|"webhook POST"| wf_langfuse
    wf_langfuse -->|"route by event_type"| wf_notify
    wf_langfuse -->|"prompt_version.created"| wf_langfuse
    langfuse -->|"webhook POST"| wf_langfuse

    wf_github_push -->|"git commit"| repo_n8n
    wf_notify -->|"slack/email"| notify["Slack / Email\n/ Telegram"]

    %% Git → deploy
    repo_config -->|"git pull / docker compose"| dreamserver

    style forgejo fill:#1b5e20,color:#fff
    style n8n fill:#0d47a1,color:#fff
    style github_actions fill:#6a1b9a,color:#fff
    style langfuse fill:#00838f,color:#fff
    style uptimekuma fill:#006064,color:#fff
```

## Nightly GitOps Schedule

| Time | Job | What Happens |
|------|-----|-------------|
| 02:00 | Prompt sync | Langfuse → fetch production prompts → commit to `prompt-library` repo |
| 02:00 | Workflow export | n8n → export all workflows → commit to `n8n-workflows` repo |
| 03:00 | Backup check | Verify last backup age → alert if >25h → trigger new backup |
| Every 30min | Stack health | curl all service endpoints → alert if any fail |
| On push | Manifest validation | Validate all `manifest.yaml` schemas + compose syntax |

## Recommended Forgejo Repos

| Repo | Contents | Access |
|------|----------|--------|
| `dreamserver-config` | `.env.example`, Caddyfile, prometheus.yml, authelia config, alert rules | Shared team |
| `n8n-workflows` | Exported n8n workflow JSON files (nightly auto-commit) | Shared team |
| `hermes-agents` | Hermes agent configs, system prompts, tool definitions | Shared team |
| `prompt-library` | Versioned prompt templates synced with Langfuse | Shared team |
| `baserow-schemas` | Baserow table exports and API definitions | Shared team |
| `client-automations` | Per-client workflow configs (e.g. for agencies) | Private per repo |

## Langfuse Webhook → n8n Integration

```mermaid
sequenceDiagram
    participant Langfuse
    participant n8n
    participant Forgejo
    participant Slack

    Langfuse->>n8n: POST /webhook/langfuse-events
    Note over n8n: HMAC SHA-256 signature verify
    alt prompt_version.created
        n8n->>Slack: Notify: "New production prompt deployed"
        n8n->>Forgejo: Tag commit in prompt-library repo
    else prompt_version.updated
        n8n->>Slack: Notify: "Prompt updated — retest recommended"
    else prompt_version.deleted
        n8n->>Slack: Alert: "Production prompt deleted"
    end
```

## Secret Management — Vaultwarden

```mermaid
flowchart LR
    vault["Vaultwarden (:8222)\n\nCollection: DreamServer Infrastructure\n  - LITELLM_KEY\n  - ANTHROPIC_API_KEY\n  - HERMES_API_KEY\n  - DREAM_AGENT_KEY\n  - OpenAI / MiniMax / OpenRouter keys\n  - Grafana admin password\n  - Database passwords"]
```

Vaultwarden collections for different teams/members — rotate keys quarterly, use org-level sharing to distribute credentials without plaintext `.env` spread across Slack/email.
