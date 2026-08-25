# core-api (Spring Boot)

Owns: auth, artisan/catalog/order CRUD, admin panel, orchestration of ML + realtime calls.
Only service that talks directly to the database.

Contract: [`../contracts/springboot-api-contract.yaml`](../contracts/springboot-api-contract.yaml)

## Run locally

```bash
./mvnw spring-boot:run
```

Requires: JDK 17+, PostgreSQL running locally (see `../docker-compose.yml` to start it via Docker).

## Structure

```
src/main/java/com/sih26090/coreapi/
├── auth/          # register, login, OTP
├── artisan/       # artisan profile CRUD
├── catalog/       # listing CRUD + orchestration
├── orders/        # order CRUD + status transitions
├── ingestion/     # internal endpoints called by Node.js and Python
└── admin/         # admin panel endpoints
```

## Environment

Copy `.env.example` to `.env` and fill in:
- `INTERNAL_API_KEY` — shared secret with `ml-service` and `realtime-service`
- `DB_URL`, `DB_USER`, `DB_PASSWORD`
