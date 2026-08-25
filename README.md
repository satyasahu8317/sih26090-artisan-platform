# SIH26090 — AI-Driven Market Linkage & Smart Cataloging App

Monorepo for the artisan market-linkage platform (Ministry of Social Justice and Empowerment / SIH26090).

See [`ROADMAP.md`](ROADMAP.md) for the full build plan, checkpoints, and risk register.

## Layout

```
contracts/            # OpenAPI contracts — single source of truth, shared by all services
core-api/              # Spring Boot — auth, catalog/order CRUD, orchestration
ml-service/             # Python/FastAPI — image enhance, ASR, translation, description, pricing
realtime-service/       # Node.js — WhatsApp relay, push notifications, realtime chat
mobile/                # Flutter — artisan + buyer facing app
docker-compose.yml     # spins up all services + Postgres + Redis together for local integration testing
```

Each service folder is a standalone project — its own toolchain, its own `README.md` with run instructions. The monorepo is a shared wrapper for coordination, not a merged build.

## Getting started

1. Clone the repo.
2. Each service: `cp <service>/.env.example <service>/.env` and fill in secrets (never commit `.env`).
3. Run everything together: `docker compose up --build`
4. Or run a single service standalone per its own `README.md` — see each folder.

## Workflow

- `main` is protected — no direct pushes, PRs only, CI must pass, at least one review required.
- Branch per feature: `feat/<short-description>`, e.g. `feat/catalog-crud`, `feat/whatsapp-webhook`.
- Changes to `contracts/` require review from every service owner (`.github/CODEOWNERS`) since they can ripple across services.
- CI (`.github/workflows/`) is scoped per service via path filters — a mobile-only change never runs or blocks on backend test suites, and vice versa.

## Contracts

- [`contracts/springboot-api-contract.yaml`](contracts/springboot-api-contract.yaml)
- [`contracts/ml-service-contract.yaml`](contracts/ml-service-contract.yaml)
- [`contracts/nodejs-service-contract.yaml`](contracts/nodejs-service-contract.yaml)

Treat these as frozen once agreed — flag proposed changes in standup, don't silently edit.
