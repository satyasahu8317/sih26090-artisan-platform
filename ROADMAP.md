# SIH26090 — Project Roadmap
**AI-Driven Market Linkage & Smart Cataloging App for Marginalized Artisans**
Build window: 36–48 hours · 4-service architecture (backend-service, ml-service, mobile, + design)

This roadmap operationalizes the charter (`Srijan.pdf`) and the two OpenAPI contracts into a task-level, dependency-aware plan. It exists so that at any hour, anyone can answer: *what should I be doing right now, what am I blocked on, and what breaks if I slip.*

**Architecture change log:** the original plan split the backend into 3 services (Spring Boot core API + Node.js realtime/messaging + Python ML) matching 3 dedicated backend developers. Actual headcount settled at 2 backend developers, so Spring Boot was dropped entirely and its responsibilities (auth, catalog/order CRUD, admin, orchestration) merged into the Node.js service, renamed `backend-service`. `ml-service` (Python) is unchanged in scope. This is a strict consolidation, not a scope cut — every endpoint from the old `springboot-api-contract.yaml` still exists, now inside `backend-service-contract.yaml`.

---

## 0. Alignment check against the official SIH26090 problem statement

Cross-checked against the official MoSJE problem statement text (not just the internal charter). The charter and contracts already match it closely — mandatory features, impact goals, and the cross-platform + scalable-backend framing all line up. Two things the official text calls out that deserve explicit attention rather than assumption:

1. **"Connect directly with larger B2B buyers or government e-marketplaces" is in the official *Expected Solution* section, not just an impact goal.** In our plan this maps to ONDC integration, currently filed under Section 2's stretch goals — lower priority than the WhatsApp bot and offline-first differentiators. Because this phrase is in the *expected solution* of the actual PS, judges may specifically look for it. **Open decision for the team:** does at least a mocked/minimal ONDC or B2B-buyer-facing connector need to move up in priority, even a thin version, rather than staying last in the stretch-goal queue? Buyer-side catalog browse/orders already covers generic "connect to buyers" — what's not covered yet is the specific government e-marketplace (ONDC) angle the PS names. Flag this at the next standup rather than deciding unilaterally.
2. **UI/UX language from the official PS is more specific than our internal brief captured:** *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)."* This is a slightly different bar than just "usable for low-literacy users" — it also signals judges will score visual polish and modern design language, not only accessibility. Feed this quote directly to the UI/UX designer (see Section 3, Phase 0).

---

## 1. Guiding principles

1. **Contracts before code.** Nobody writes business logic against a guessed shape of another service's API. The two YAML contracts (`backend-service-contract.yaml`, `ml-service-contract.yaml`) are frozen after sign-off; changes go through a standup flag, not a silent edit.
2. **Vertical slice first, breadth second.** Get one photo + one voice note through the *entire* pipeline (Flutter → backend-service → ml-service → back → backend-service notifies) before polishing any single stage. A thin end-to-end path that works beats several polished stages that don't connect.
3. **Every service is independently runnable from Hour 20.** Mocked-but-correctly-shaped responses count as done for Checkpoint A. Nobody should be blocked waiting on a teammate's real implementation.
4. **Status field is the contract for failure.** `PENDING → PROCESSING → READY → PUBLISHED` (+ `FAILED`) is how partial ML failures surface to the artisan. No silent drops.
5. **WhatsApp bot is the demo's spine.** The backend-service developer's WhatsApp work is sequenced to have a working sandbox number by Hour 10 — this has the longest external-dependency lead time (Meta app review/setup) and the highest risk of blowing the whole differentiator if started late.

---

## 2. Critical path

```
Hour 0-6   Contracts frozen + repos scaffolded
              │
Hour 6-20  Parallel build (each service standalone, mocked neighbors)
              │
Hour 20-32 Real integration — mocks swapped for live calls
              │  ⚑ Checkpoint B: photo+voice → real reviewable listing
Hour 32-40 Differentiators — WhatsApp E2E, offline polish, pricing tuning
              │  ⚑ Checkpoint C: WhatsApp demo works unattended
Hour 40-48 Hardening, deploy, pitch rehearsal
```

The single riskiest dependency chain in the whole project:

**WhatsApp sandbox approval (external/Meta) → whatsapp webhook (backend-service) → `/internal/ingestion/whatsapp` (backend-service, internal call) → ML pipeline (ml-service) → `/internal/ml-callback` (backend-service) → notification dispatch (backend-service) → artisan sees "listing ready" on WhatsApp.**

Consolidating to 2 backend services shortens this chain meaningfully — what used to cross 3 services and 3 people (Node → Spring Boot → Python → Spring Boot → Node) now only crosses the backend/ML boundary once. The remaining real risk is entirely external: Meta's sandbox approval latency, which is why that registration still starts at Hour 0, not later.

---

## 3. Phase-by-phase plan

### Phase 0 — Hours 0–6: Contracts & Scaffolding

| Owner | Tasks |
|---|---|
| All | Review both OpenAPI contracts together. Sign off or flag changes live — this is the only point where contract edits are cheap. |
| Node.js (backend-service) | Scaffold the unified backend: Express, JWT auth, Postgres connection, entity shapes for `User`, `ArtisanProfile`, `Listing`, `Order`, `Asset`. **Start Meta WhatsApp Business sandbox registration now** — this has unpredictable external latency and must not be the long pole later. Stub `/health`, `/notifications/register-device`. |
| Flutter | Scaffold app (Riverpod/Bloc, routing). Stub API client against the frozen `backend-service-contract.yaml` using a local JSON mock server (e.g. `json-server` or hand-rolled mock interceptor). |
| Python/ML | Scaffold FastAPI project. Stub all 5 endpoints (`/image/enhance`, `/audio/transcribe`, `/text/translate`, `/text/generate-description`, `/price/suggest`) returning hardcoded-but-schema-correct responses. Pull and smoke-test `rembg`, Whisper (or IndicWhisper), IndicTrans2/NLLB locally — confirm they run on available hardware before committing to them in the demo. |
| UI/UX | Deliver low-fi wireframes for: onboarding, capture flow, review-and-publish screen, WhatsApp bot script. Design brief per the official PS wording: *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)"* — treat modern/clean visual polish as a real scoring criterion, not secondary to accessibility. |

**Exit criteria:** Both contracts committed to repo. Every service has a `/health` endpoint returning 200.

---

### Phase 1 — Hours 6–20: Parallel Build → Checkpoint A

Each service builds against **mocks of its neighbor**, not against real neighbor code.

**Backend-service** (`backend-service-contract.yaml`) — Node.js
- `/auth/register`, `/auth/login`, `/auth/otp/request`, `/auth/otp/verify` with JWT issuance.
- `/artisans/me` GET/PUT.
- `/uploads/init` + `/uploads/{assetId}/complete` — signed URL generation against S3/Firebase.
- `/catalog/listings` POST (creates PENDING listing, stubs the async call to ml-service) + GET (browse).
- `/catalog/listings/{listingId}` GET/PATCH.
- `/orders` POST/GET, `/orders/{orderId}/status` PATCH.
- `/internal/ingestion/whatsapp` and `/internal/ml-callback/{listingId}` — stub bodies that just persist and log; wire real orchestration in Phase 2.
- Internal API key middleware for the `internal/*` routes (now protecting the boundary to ml-service, not another internal service).
- WhatsApp webhook: GET verification handshake working against the real Meta sandbox.
- POST webhook: parse Meta's nested payload down to `WhatsAppInboundPayload` shape; call `/internal/ingestion/whatsapp` internally (same process — no network hop needed anymore).
- `/notifications/dispatch`, `/notifications/register-device`, FCM wiring.
- Socket.IO server skeleton for `order:{orderId}` channel (if chat is in scope this cycle).

**Flutter**
- Onboarding + OTP login flow against backend-service auth.
- Camera capture + voice recording UI, writing to local Hive/SQLite queue.
- Offline queue → background sync worker (stubbed target endpoint).
- Catalog list/detail screens driven by mock listing data.
- Review-and-publish screen (edit description/price before publish).

**ml-service** (Python)
- Real image enhancement: `rembg` background removal + basic lighting/crop normalization behind `/image/enhance`.
- Real ASR: Whisper/IndicWhisper behind `/audio/transcribe`.
- Real translation: IndicTrans2/NLLB behind `/text/translate`.
- `/text/generate-description`: prompt-engineered LLM call, constrained to source text only.
- `/price/suggest`: baseline explainable regression (4–6 features) — ship this before anything fancier.
- Async job pattern (`202` + `/{jobId}` poll) for anything that won't reliably finish inside a request timeout.

**⚑ Checkpoint A (≈Hour 20) — Definition of Done**
- Both services run standalone and return dummy-but-correctly-shaped responses for every endpoint in their contract.
- backend-service's WhatsApp sandbox number can receive a test message and the webhook logs it.
- Standup: each owner demos their service in isolation via curl/Postman.

---

### Phase 2 — Hours 20–32: Real Integration → Checkpoint B

This is where mocks get torn out. Sequence matters — build the chain in this order so nobody is blocked waiting on someone else's real endpoint:

1. **backend-service ↔ ml-service first.** backend-service's listing-creation orchestration starts calling the *real* ml-service endpoints (not mocks) for image enhance → transcribe → translate → describe → price. Handle the async (202/poll) cases.
2. **backend-service's `/internal/ml-callback/{listingId}` goes live**, persisting real ML results and flipping listing status to `READY`.
3. **Flutter switches from mock API client to live backend-service.** Full loop: capture → upload → create listing → poll/observe status → see real enhanced image, description, price on review screen.
4. **Offline sync test**: toggle airplane mode mid-capture, confirm queued items sync correctly once backend-service is reachable.
5. **Notification dispatch wired internally** on listing `READY` (even if channel selection is still simple/single-path at this point) — this is now an in-process call, not a cross-service one.

**⚑ Checkpoint B (≈Hour 32) — Definition of Done**
- A real photo + real voice note captured in the Flutter app produces a real, reviewable catalog listing with actual (not placeholder) enhanced image, bilingual description, and suggested price range.
- Listing status correctly reflects `PENDING → PROCESSING → READY` as the pipeline progresses.
- A forced Python-side failure (e.g. kill one ML endpoint) results in `FAILED` or `PARTIAL` status with an `errorMessage`, not a stuck listing.

---

### Phase 3 — Hours 32–40: Differentiators → Checkpoint C

- **backend-service (Node.js dev)**: complete the WhatsApp relay end-to-end — real inbound message → download media from Meta's Graph API → store via the internal `/uploads/init` flow → call `/internal/ingestion/whatsapp` → on `READY`, send the artisan a WhatsApp message via `/whatsapp/send` ("Your listing is ready — reply REVIEW to see it"). Harden orchestration error paths; add scheme-matching rules engine *only if the two ★ priorities are already solid* (stretch goal, do not let it displace WhatsApp/offline work).
- **Flutter**: offline-mode polish — retry/backoff on sync failure, clear "queued, will sync" UI state, low-literacy-friendly progress indicators during ML processing.
- **ml-service (Python/ML dev)**: refine pricing model using any real sample product data gathered; tune ASR language hints; validate description generation doesn't fabricate details.
- **UI/UX**: finalize "waiting for AI" states, price range slider, description edit view — hand off any last design tokens.

**⚑ Checkpoint C (≈Hour 40) — Definition of Done**
- Send a photo + voice note to the WhatsApp sandbox number with zero developer intervention → artisan receives a "your listing is ready" reply with a reviewable link/summary.
- Offline capture → airplane mode → reconnect → sync → listing appears, with no data loss or duplicate submission.

---

### Phase 4 — Hours 40–48: Hardening & Demo Readiness

- Bug bash across all services — prioritize anything that would visibly break the demo path (Checkpoint B and C flows), not cosmetic issues elsewhere.
- Deploy all services (even to simple free-tier hosts — Render/Railway/Fly.io for backend, Firebase/S3 for storage) so the demo isn't running off someone's laptop hotspot.
- Full dry run of the demo script **at least twice**, timed, with the actual deployed stack.
- Pitch deck: lead with the impact narrative (income upliftment, digital-literacy bridge, WhatsApp as a channel judges instantly understand) — not a feature list.
- Freeze scope. Anything not done by Hour 44 is out — no last-hour feature additions.

---

## 4. Ownership & escalation map

| Track | Owner | Immediate escalation if blocked |
|---|---|---|
| Backend: auth, catalog/order CRUD, admin, orchestration, WhatsApp, notifications | Node.js Dev (backend-service) | Flags contract drift in standup immediately, doesn't silently reinterpret; de-risks Meta sandbox approval at Hour 0, not Hour 20 |
| Mobile / offline capture | Flutter Dev | Falls back to mocked API longer rather than blocking on backend-service |
| ML inference serving + model selection/tuning | Python/ML Dev (ml-service) | Ships graceful partial-result fallback rather than blocking whole listing on one model timeout; hands off a working pretrained model early rather than chasing architecture improvements under time pressure |
| Design system | UI/UX | Delivers clickable prototype by Checkpoint A so Flutter isn't guessing at spacing |

---

## 5. Top risks & mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Meta WhatsApp sandbox approval delayed | High | Start registration at Hour 0; have a "simulate incoming webhook via curl" fallback for demo if sandbox isn't ready |
| ML models too slow for live demo | Medium | Async job pattern (202 + poll) built in from Phase 1; pre-warm models before demo; have a pre-recorded fallback clip |
| Contract drift between services | Medium (lower than before — only 2 services to keep in sync now) | Frozen contracts after Hour 6; any change flagged in standup, not silently made |
| backend-service becomes a single point of failure — it now owns everything except ML | Medium (new risk from consolidation) | Keep the codebase modular internally (separate route files per domain: auth/, catalog/, whatsapp/, etc.) even though it's one deployable, so a bug in one area doesn't require understanding the whole service to fix |
| Offline sync edge cases (dup submits, partial uploads) | Medium | Explicit airplane-mode test pass in Phase 2, not deferred to Phase 4 |
| Pricing model has no real market data | High (expected) | Ship explainable baseline early per charter guidance; refine only if time allows, never block on it |
| Scope creep into stretch goals before ★ priorities are solid | Medium | Hour 40 scope freeze; stretch goals explicitly sequenced after WhatsApp + offline |
| Missing the PS's explicit "B2B buyers / govt e-marketplace" ask because ONDC sits last in stretch goals | Medium | See Section 0, item 1 — needs an explicit team decision, not a default deprioritization |

---

## 6. Standup cadence

Mandatory for every developer at each checkpoint (≈Hour 20, ≈Hour 32, ≈Hour 40), even if your own track is on schedule — this is where contract drift and integration surprises get caught before they cost the final hours.
