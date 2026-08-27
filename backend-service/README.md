# backend-service (Node.js)

Owns: auth, artisan/catalog/order CRUD, admin panel, WhatsApp webhook + outbound messaging, push notifications, realtime chat events, ONDC adapter (stretch), and orchestration of `ml-service` calls. The only service that talks directly to the database.

This service was originally split into a separate Spring Boot core API and a thin Node.js realtime/messaging service. The team consolidated to one backend codebase to match actual headcount — one Node.js developer, one Python/ML developer, one service each.

Contract: [`../contracts/backend-service-contract.yaml`](../contracts/backend-service-contract.yaml)

## Run locally

```bash
npm install
npm run dev
```

## Structure

```
src/
├── app.js           # Express app definition (importable, testable without binding a port)
├── index.js         # entry point — starts the server
├── auth/            # register, login, OTP
├── artisans/        # artisan profile CRUD
├── uploads/         # signed upload URL flow
├── catalog/         # listing CRUD + orchestration of ml-service calls
├── orders/          # order CRUD + status transitions
├── admin/           # admin panel endpoints
├── whatsapp/        # webhook verify + inbound ingestion + outbound send
├── notifications/   # dispatch + device registration
├── realtime/        # Socket.IO chat channel
└── ondc/            # stretch goal webhook adapter
```

## Environment

Copy `.env.example` to `.env` and fill in:
- `DB_URL`, `DB_USER`, `DB_PASSWORD` — PostgreSQL connection
- `INTERNAL_API_KEY` — shared secret with `ml-service`
- Meta WhatsApp Business Cloud API credentials
