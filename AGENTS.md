# StockApp Workspace Instructions

When a task touches `D:\stockapp\backend-main`, backend architecture, FastAPI modules, service layering, external APIs, SDKs, models, quant frameworks, or shared data-fetch flows, read and follow this skill before making substantial changes:

- `D:\stockapp\.codex\skills\external-integrations-governance\SKILL.md`

For backend integration work, also read the detailed policy reference linked from that skill.

Do not bypass the skill for changes in:

- `app/integrations/`
- any module `router.py`
- any module `service.py`
- retry, caching, batching, timeout, or provider-mapping logic
