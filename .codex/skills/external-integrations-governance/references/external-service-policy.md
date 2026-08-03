# StockApp External Service Policy

Apply these rules to PandaAI, SiliconFlow, Qlib, TimesFM, news data providers, and any future third-party service.

## 1. Unified Integration Location

- Put all external-service access under `app/integrations/`.
- Keep exactly one formal implementation per external platform.
- Do not duplicate provider URLs, authentication logic, SDK setup, request parameters, or raw response parsing inside business modules.

## 2. Standard Call Graph

Use these call paths:

```text
Router -> Service -> Integration -> External Service
Router -> Service -> Database
Router -> Service -> Integration
```

Layer responsibilities:

- `Router`: receive requests, validate inputs, call service, return response.
- `Service`: orchestrate business flow, combine data, reuse integrations or repositories.
- `Integration`: own authentication, timeout, retries, response parsing, provider error mapping, and internal field mapping.
- `Repository` or `Database`: own persistence access only.

Forbidden:

- router calling database directly
- router calling SDK/API/model directly
- service duplicating provider client implementations across modules

## 3. Shared Reuse

- Reuse one shared integration or shared service across modules.
- If `Home`, `AI`, and `Quant` all need market data, they must reuse the same integration path instead of reimplementing the provider request separately.
- Reuse already-fetched data within the same business flow. Do not request the same external data repeatedly in one request lifecycle.

## 4. Performance Requirements

- Prefer batch endpoints when available.
- If the provider has no batch endpoint, handle concurrency limits, fan-out, and caching on the backend.
- Do not rely on Flutter to fire many repeated requests to assemble one page.

Every network integration must define:

1. explicit timeout
2. bounded retry policy
3. short-term cache when useful
4. logging for request count and latency

Retry rule:

- retry in one layer only
- do not stack retries in router, service, and integration together

## 5. Configuration and Safety

- Read API keys, tokens, model names, and base URLs through `app/core/config.py` from environment variables.
- Keep real secrets only in `.env`.
- Never commit real secrets to Git.
- Never place secrets in Flutter, routers, services, tests, or README files.
- Keep `.env.example` limited to variable names and placeholder values.
- Never return raw upstream errors, secrets, tokens, provider query strings, or internal stack traces to frontend clients.

## 6. Internal Data Contracts

- Business modules must not depend on raw provider fields.
- Integrations must map provider responses into project-internal data structures first.
- Keep provider-specific field names and response quirks inside the integration layer.
- This isolation is required so provider swaps only touch `app/integrations/` and possibly mapping code.

## 7. Change Review and Testing

Before changing a shared integration, check:

1. which modules consume it
2. whether returned internal fields change
3. whether request volume changes
4. whether exception types or error semantics change
5. whether cache behavior, tests, or frontend APIs are affected

Testing rules:

- avoid routine real calls to paid APIs in normal business tests
- prefer mock or stub based service tests
- run real integration tests separately and sparingly

## Core Principle

Business modules define what must be accomplished.

Integrations define how external capabilities are connected.

The same external capability is integrated once and reused everywhere.
