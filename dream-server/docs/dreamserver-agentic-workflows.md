# DreamServer Agentic Workflows — Automation Opportunities

A reference list of workflows that can be fully or partially automated using the DreamServer stack (n8n + Hermes Agent + Langfuse + Baserow + Forgejo + Uptime Kuma + Docling). Organized by domain.

---

## 🏗️ Infrastructure & DevOps

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Nightly stack health report | Schedule (3am) | n8n → Uptime Kuma API → Telegram/Slack | Low |
| Auto-restart failed container | Uptime Kuma alert webhook | n8n → Docker CLI → notify | Low |
| Config backup to Forgejo | Schedule (daily) | n8n → `dream backup` → Forgejo API commit | Low |
| Alert when disk > 85% | Prometheus alert → n8n webhook | Prometheus → n8n → notify | Low |
| Prometheus target down alert | Prometheus alert | Prometheus Alertmanager → n8n → Telegram | Low |
| Rotate `.env` secrets | Manual trigger | n8n → generate secret → update `.env` → Vaultwarden sync | Medium |
| Docker image update checker | Schedule (weekly) | n8n → Docker Hub API → Forgejo issue | Medium |
| Multi-service restart orchestration | Webhook or schedule | n8n → sequential `dream restart` commands → health verify | Medium |
| Grafana dashboard snapshot email | Schedule (weekly) | n8n → Grafana API → email attachment | Medium |

---

## 🧠 Prompt & Model Management

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Sync Langfuse production prompts to Forgejo | Langfuse webhook (prompt.created) | Langfuse webhook → n8n → Forgejo commit | Low |
| Notify on prompt version promotion | Langfuse webhook (prompt.updated) | Langfuse webhook → n8n → Slack/Telegram | Low |
| Auto-tag Forgejo commit when prompt deployed | Langfuse webhook | n8n → Forgejo API → create tag | Low |
| Run eval suite after prompt update | Langfuse webhook | n8n → Langfuse evaluation API → compare results | Medium |
| Prompt A/B test result report | Schedule (weekly) | n8n → Langfuse API → generate markdown → Forgejo issue | Medium |
| Detect prompt regression (score drop) | Schedule (hourly) | n8n → Langfuse scores API → alert if < threshold | Medium |
| Archive deprecated prompt versions | Langfuse webhook (prompt.deleted) | n8n → archive to Forgejo `prompt-archive` repo | Low |
| Auto-generate prompt changelog | Forgejo push webhook | Forgejo → n8n → Hermes Agent → commit CHANGELOG.md | High |

---

## 📄 Document & RAG Pipelines

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Ingest uploaded PDF into Qdrant | File upload webhook / n8n watch folder | n8n → Docling API → chunk → Qdrant upsert | Medium |
| Batch ingest a folder of documents | Manual trigger | n8n → loop over files → Docling → Qdrant | Medium |
| Re-index all documents when model changes | Manual / schedule | n8n → Qdrant delete collection → re-ingest via Docling | Medium |
| Watch Baserow for new document records | Baserow row created webhook | Baserow → n8n → Docling → Qdrant → update Baserow status | Medium |
| Weekly RAG quality report | Schedule | n8n → Langfuse traces → score avg → Grafana annotation | High |
| Auto-summarize ingested documents | Post-ingest | n8n → Hermes Agent → summarize → Baserow update | Medium |
| OCR and classify incoming invoices | Watch folder or email | n8n → Docling (OCR) → Hermes Agent classify → Baserow row | High |
| Extract structured data from contracts | Manual trigger | n8n → Docling → Hermes Agent (JSON extraction) → Baserow | High |

---

## 🤖 Agent Task Automation

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Daily research digest | Schedule (6am) | n8n → SearXNG → Hermes Agent summarize → email/Telegram | Medium |
| Competitor monitoring report | Schedule (weekly) | n8n → SearXNG → Hermes Agent analyze → Forgejo issue | Medium |
| Lead research enrichment | Baserow row created | Baserow → n8n → Hermes Agent → SearXNG → update record | High |
| Auto-draft proposal from intake form | Webhook (form submit) | n8n → Hermes Agent → template → Forgejo → email draft | High |
| Slack/Telegram command interface | Incoming message webhook | Telegram → n8n → Hermes Agent → respond | Medium |
| Route support tickets to correct team | Email/webhook | n8n → Hermes Agent classify → Baserow ticket update | Medium |
| Summarize long email threads | Email webhook (n8n) | n8n → Hermes Agent → summarize → reply draft | Medium |
| Generate weekly status update | Schedule (Friday 4pm) | n8n → Baserow tasks → Hermes Agent → email | High |

---

## 📊 Business & Client Workflows

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| New client onboarding automation | Manual trigger | n8n → Baserow create client record → Forgejo create client repo → email sequence | High |
| Project status dashboard update | Schedule (daily) | n8n → Baserow → Grafana annotation → Slack post | Medium |
| Invoice generation from Baserow | Manual / schedule | n8n → Baserow query → Hermes Agent format → PDF → email | High |
| Client RAG pipeline deployment | Manual trigger | n8n → Qdrant create collection → ingest client docs → test query | High |
| SLA uptime report for clients | Schedule (monthly) | n8n → Uptime Kuma API → generate PDF → email | Medium |
| Automated follow-up sequencing | Baserow row trigger | Baserow status change → n8n → timed email sequence | Medium |
| CRM data deduplication | Schedule (weekly) | n8n → Baserow query → Hermes Agent identify dupes → flag | High |

---

## 🔐 Security & Compliance

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Scan `.env` for plaintext secrets | Forgejo push webhook | Forgejo → n8n → secret pattern check → block/alert | Medium |
| Vaultwarden vault activity audit | Schedule (weekly) | n8n → Vaultwarden API → check for shared credentials → report | Medium |
| Auto-rotate Hermes API token | Schedule (monthly) | n8n → generate token → update `.env` → restart service → update Vaultwarden | High |
| Alert on unusual LLM query volume | Prometheus alert | Prometheus → Alertmanager → n8n → investigate | Medium |
| PII audit of Langfuse traces | Schedule (weekly) | n8n → Langfuse trace export → Hermes Agent scan → report | High |
| Failed login attempt alerting | Authelia log webhook | Authelia → n8n → Telegram alert with IP | Medium |

---

## 🔄 Git & Version Control (Forgejo)

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Auto-export n8n workflows to Git | Schedule (nightly) | n8n → export all → Forgejo commit | Low |
| Auto-tag release when version bumped | Forgejo push webhook | Forgejo → n8n → check version → create tag | Low |
| PR review summary | Forgejo PR opened | Forgejo webhook → n8n → Hermes Agent review → comment | High |
| Changelog generation | Forgejo tag created | Forgejo → n8n → Hermes Agent → generate CHANGELOG.md commit | High |
| Stale branch cleanup reminder | Schedule (weekly) | n8n → Forgejo API → find stale branches → Telegram notify | Low |
| Sync prompt templates repo on deploy | Manual trigger | n8n → Langfuse API → export → Forgejo push | Medium |

---

## 📡 Integrations & External Services

| Workflow | Trigger | Tools | Complexity |
|---|---|---|---|
| Google Calendar → daily brief | Schedule (8am) | n8n → Google Calendar API → Hermes Agent → Telegram | Medium |
| Webhook-to-Baserow data collector | Any inbound webhook | Generic webhook → n8n → Baserow row | Low |
| n8n error alerting | n8n error trigger | n8n → format error → Telegram/Slack | Low |
| RSS feed → RAG ingestion | Schedule (hourly) | n8n → RSS → Docling → Qdrant (for research contexts) | Medium |
| GitHub Issues → Baserow sync | GitHub webhook | GitHub → n8n → Baserow create/update ticket | Medium |
| Forgejo → external GitHub mirror | Forgejo push webhook | Forgejo → n8n → GitHub API push | Medium |
| Email → structured Baserow record | n8n email trigger | Email → n8n → Hermes Agent extract → Baserow | High |

---

## Complexity Key

| Level | Description |
|---|---|
| **Low** | Single tool, 1–3 n8n nodes, no agent reasoning needed |
| **Medium** | 2–3 tools, conditional logic, may use Hermes Agent for classification or generation |
| **High** | Multi-step, agent reasoning required, stateful, may require error handling and retries |

---

## Recommended Starting Point

For maximum ROI per hour invested, build in this order:

1. **Nightly stack health report** → proves end-to-end stack connectivity immediately
2. **Sync Langfuse prompts to Forgejo** → activates the Langfuse webhook you just configured
3. **Ingest uploaded PDF into Qdrant** → activates Docling and proves the RAG pipeline
4. **Auto-restart failed container** → critical operational resilience, low effort
5. **New client onboarding automation** → highest business value for AI consulting work
6. **Daily research digest** → personal productivity, demonstrates Hermes + SearXNG to clients
