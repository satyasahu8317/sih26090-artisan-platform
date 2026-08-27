# SIH26090 — AI-Driven Market Linkage & Smart Cataloging App

Monorepo for the artisan market-linkage platform (Ministry of Social Justice and Empowerment / SIH26090).

See [`ROADMAP.md`](ROADMAP.md) for the full build plan, checkpoints, and risk register.

## Layout

```
contracts/            # OpenAPI contracts — single source of truth, shared by all services
backend-service/      # Node.js — auth, catalog/order CRUD, admin, WhatsApp, notifications, orchestration
ml-service/           # Python/FastAPI — image enhance, ASR, translation, description, pricing
mobile/               # Flutter — artisan + buyer facing app
docker-compose.yml    # spins up all services + Postgres + Redis together for local integration testing
```

**Two backend services, matching two backend developers** — `backend-service` (Node.js) is the only service that talks to the database and owns everything except ML inference; `ml-service` (Python) is a stateless worker it calls into. This was originally a 3-service backend split (Spring Boot + Node.js + Python), consolidated once the team settled at two backend developers rather than three — no orphaned service without a dedicated owner.

Each service folder is a standalone project — its own toolchain, its own `README.md` with run instructions. The monorepo is a shared wrapper for coordination, not a merged build.

## Getting started

1. Clone the repo.
2. Each service: `cp <service>/.env.example <service>/.env` and fill in secrets (never commit `.env`).
3. Run everything together: `docker compose up --build`
4. Or run a single service standalone per its own `README.md` — see each folder.

## Workflow

- `master` is protected — no direct pushes, PRs only, CI must pass, at least one review required.
- Branch per feature: `feat/<short-description>`, e.g. `feat/catalog-crud`, `feat/whatsapp-webhook`.
- Changes to `contracts/` require review from every service owner (`.github/CODEOWNERS`) since they can ripple across services.
- CI (`.github/workflows/`) is scoped per service via path filters — a mobile-only change never runs or blocks on backend test suites, and vice versa.

## Contracts

- [`contracts/backend-service-contract.yaml`](contracts/backend-service-contract.yaml)
- [`contracts/ml-service-contract.yaml`](contracts/ml-service-contract.yaml)

Treat these as frozen once agreed — flag proposed changes in standup, don't silently edit.
