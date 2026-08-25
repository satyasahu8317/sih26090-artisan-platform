# realtime-service (Node.js)

Owns: WhatsApp webhook relay, push notifications, realtime chat events, ONDC adapter (stretch).
Stateless — owns no core business data. Thin relay into `core-api`.

Contract: [`../contracts/nodejs-service-contract.yaml`](../contracts/nodejs-service-contract.yaml)

## Run locally

```bash
npm install
npm run dev
```

## Structure

```
src/
├── index.js
├── whatsapp/       # webhook verify + inbound relay + outbound send
├── notifications/  # dispatch + device registration
├── realtime/        # Socket.IO chat channel
└── ondc/            # stretch goal webhook adapter
```

## Environment

Copy `.env.example` to `.env` and fill in Meta WhatsApp Business Cloud API credentials.
