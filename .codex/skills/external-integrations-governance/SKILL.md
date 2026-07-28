---
name: external-integrations-governance
description: Enforce the StockApp backend rules for third-party integrations, service layering, shared data reuse, and external API safety. Use when working on FastAPI backend code under `backend-main`, especially for `app/integrations`, `service.py`, `router.py`, external SDKs or APIs, market/news/AI/quant data flows, retry/cache/timeout behavior, or any change that might duplicate third-party calls or leak provider-specific fields into business modules.
---

# External Integrations Governance

Follow this skill whenever a task touches backend integrations, shared backend services, or service-layer design in the StockApp workspace.

## Required Workflow

1. Identify whether the task touches `backend-main` and any of these areas:
   - `app/integrations`
   - module `service.py`
   - module `router.py`
   - external APIs, SDKs, models, or quant frameworks
   - retry, timeout, caching, batching, or request fan-out
2. Read [references/external-service-policy.md](references/external-service-policy.md) before making substantial changes.
3. Keep the call chain consistent:

```text
Router -> Service -> Integration -> External Service
Router -> Service -> Repository/Database
```

4. Reject designs where routers call third-party services directly, modules duplicate provider clients, or business modules depend on raw third-party response fields.
5. If adding or changing a shared integration, explicitly check:
   - which modules use it
   - whether returned internal fields change
   - whether request count, retry behavior, or cache behavior changes
   - whether new secrets or provider details could leak to frontend responses or logs

## Non-Negotiable Rules

- Keep one formal integration implementation per external capability under `app/integrations/`.
- Reuse shared integrations and shared services across modules; do not duplicate provider access in `ai`, `quant`, `market`, `news`, or other modules.
- Put API keys, base URLs, model names, and tokens in `app/core/config.py` and environment variables only.
- Convert provider responses into project-internal schemas before returning them to services.
- Set explicit timeouts for network integrations and keep retries bounded in one layer only.
- Prefer batching, server-side concurrency control, and short-lived caching over repeated frontend-triggered fan-out.
- Avoid real paid API calls in routine unit tests; prefer mocks or stubs.

## Review Checklist

Before finishing work, verify:

- no repeated provider client implementation was introduced
- no router calls an SDK, model, or database directly
- no raw provider fields escaped the integration layer
- no duplicate requests were added in one business flow
- no secret, token, stack trace, or raw upstream error is returned to frontend
