# SIH26090 — Project Roadmap
**AI-Driven Market Linkage & Smart Cataloging App for Marginalized Artisans**
Milestone-driven plan · 3-service architecture (backend-service, ml-service, mobile) + design

This roadmap operationalizes the charter (`Srijan.pdf`) and the two OpenAPI contracts into a task-level, dependency-aware plan. It exists so that at any point, anyone can answer: *what should I be doing right now, what am I blocked on, and what breaks if I slip.* Progress is tracked by **milestones and checkpoints, not a countdown clock** — a hackathon-style hour budget was dropped deliberately (see §0a) because it was pushing scope decisions ("is there time for this?") ahead of correctness decisions ("does this actually satisfy the PS?"). Sequencing and dependency order below are unchanged; only the artificial deadline framing is gone.

**Architecture change log:** the original plan split the backend into 3 services (Spring Boot core API + Node.js realtime/messaging + Python ML) matching 3 dedicated backend developers. Actual headcount settled at 2 backend developers, so Spring Boot was dropped entirely and its responsibilities (auth, catalog/order CRUD, admin, orchestration) merged into the Node.js service, renamed `backend-service`. `ml-service` (Python) is unchanged in scope. This is a strict consolidation, not a scope cut — every endpoint from the old `springboot-api-contract.yaml` still exists, now inside `backend-service-contract.yaml`.

---

## 0. Alignment check against the official SIH26090 problem statement

Cross-checked against the official MoSJE problem statement text (not just the internal charter). The charter and contracts already match it closely — mandatory features, impact goals, and the cross-platform + scalable-backend framing all line up. Two things the official text calls out get dedicated treatment rather than living as footnotes:

1. **"Connect directly with larger B2B buyers or government e-marketplaces" is in the official *Expected Solution* section, not just an impact goal.** This is no longer a deprioritized stretch item — it has a concrete design in `ARCHITECTURE.md` §5 (a structurally honest ONDC/Beckn connector reusing the existing `Order` pipeline) and its own phase below (Phase 2b). **Still-open team decision:** whether ONDC alone satisfies "government e-marketplace," or whether GeM needs a separate thin connector — see `ARCHITECTURE.md` §5. Flag this at the next standup rather than deciding unilaterally.
2. **UI/UX language from the official PS is more specific than our internal brief captured:** *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)."* This is a slightly different bar than just "usable for low-literacy users" — it also signals judges will score visual polish and modern design language, not only accessibility. Feed this quote directly to the UI/UX designer (see Phase 0).
3. **"Increasing the average annual income of the target demographic" is an impact goal the platform currently has no way to demonstrate.** `ARCHITECTURE.md` §6 specifies a cheap, concrete artisan-facing impact summary (listings published, revenue through the platform, price uplift vs. artisan-reported baseline) built from data the platform already captures. This is now a scheduled deliverable (Phase 3), not an afterthought for the pitch deck.

### 0a. Why the hour-based timeline was removed

The original plan boxed work into a 36-48 hour hackathon sprint. That framing optimized for "ship something that runs" over "ship something that actually satisfies a high-bar PS" — visible in how ONDC and impact measurement had been pushed to the bottom of a stretch-goal queue purely because the clock was the primary constraint, not because they mattered less. Removing the clock doesn't remove urgency or sequencing — the phase order, dependency chains, and checkpoint definitions below are the same discipline as before. It just means a phase finishes when its checkpoint's definition-of-done is actually met, not when an hour counter says to move on.

---

## 1. Guiding principles

1. **Contracts before code.** Nobody writes business logic against a guessed shape of another service's API. The two YAML contracts (`backend-service-contract.yaml`, `ml-service-contract.yaml`) are frozen after sign-off; changes go through a standup flag, not a silent edit.
2. **Vertical slice first, breadth second.** Get one photo + one voice note through the *entire* pipeline (Flutter → backend-service → ml-service → back → backend-service notifies) before polishing any single stage. A thin end-to-end path that works beats several polished stages that don't connect.
3. **Every service is independently runnable from Checkpoint A.** Mocked-but-correctly-shaped responses count as done for Checkpoint A. Nobody should be blocked waiting on a teammate's real implementation.
4. **Status field is the contract for failure.** `PENDING → PROCESSING → READY → PUBLISHED` (+ `FAILED`) is how partial ML failures surface to the artisan. No silent drops.
5. **WhatsApp bot is the demo's spine, and its external dependency starts immediately.** The backend-service developer's WhatsApp work has the longest external-dependency lead time (Meta app review/setup) of anything in the plan, so registration starts in Phase 0, not whenever that track gets around to it.
6. **Robustness is a designed property, not a cleanup pass.** Observability, security/privacy, rate limiting, and the async job pattern (`ARCHITECTURE.md` §9) are scheduled work with owners and checkpoints below — not implicitly "Phase 4 hardening" busywork squeezed in at the end.

---

## 2. Build sequence

```
Phase 0   Contracts frozen + repos scaffolded
              │
Phase 1   Parallel build (each service standalone, mocked neighbors)
              │  ⚑ Checkpoint A: every service runs standalone, correctly-shaped responses
Phase 2   Real integration — mocks swapped for live calls
              │  ⚑ Checkpoint B: photo+voice → real reviewable listing
Phase 2b  B2B / government e-marketplace connector (ONDC)
              │  ⚑ Checkpoint B2: a real ONDC search hits our catalog and gets a correct on_search response
Phase 3   Differentiators — WhatsApp E2E, offline polish, impact dashboard, pricing tuning
              │  ⚑ Checkpoint C: WhatsApp demo works unattended; impact summary shows real numbers
Phase 4   Hardening, deploy, pitch rehearsal
```

The single riskiest dependency chain in the whole project:

**WhatsApp sandbox approval (external/Meta) → whatsapp webhook (backend-service) → `/internal/ingestion/whatsapp` (backend-service, internal call) → ML pipeline (ml-service) → `/internal/ml-callback` (backend-service) → notification dispatch (backend-service) → artisan sees "listing ready" on WhatsApp.**

Consolidating to 2 backend services shortens this chain meaningfully — what used to cross 3 services and 3 people (Node → Spring Boot → Python → Spring Boot → Node) now only crosses the backend/ML boundary once. The remaining real risk is entirely external: Meta's sandbox approval latency, which is why that registration still starts in Phase 0, not later.

---

## 3. Phase-by-phase plan

### Phase 0 — Contracts & Scaffolding

| Owner | Tasks |
|---|---|
| All | Review both OpenAPI contracts together. Sign off or flag changes live — this is the only point where contract edits are cheap. |
| Node.js (backend-service) | Scaffold the unified backend: Express, JWT auth, Postgres connection, entity shapes for `User`, `ArtisanProfile`, `Listing` (including `artisanBaselinePrice`, `sourceChannel` — see `ARCHITECTURE.md` §6-7), `Order`, `Asset`. **Start Meta WhatsApp Business sandbox registration now** — this has unpredictable external latency and must not be the long pole later. Stub `/health` (reporting real DB connectivity per `ARCHITECTURE.md` §9.1), `/notifications/register-device`. |
| Flutter | Scaffold app (Riverpod/Bloc, routing). Stub API client against the frozen `backend-service-contract.yaml` using a local JSON mock server (e.g. `json-server` or hand-rolled mock interceptor). |
| Python/ML | Scaffold FastAPI project. Stub all 5 endpoints (`/image/enhance`, `/audio/transcribe`, `/text/translate`, `/text/generate-description`, `/price/suggest`) returning hardcoded-but-schema-correct responses. Pull and smoke-test `rembg`, Whisper (or IndicWhisper), IndicTrans2/NLLB locally — confirm they run on available hardware before committing to them in the demo. |
| UI/UX | Deliver low-fi wireframes for: onboarding, capture flow, review-and-publish screen, WhatsApp bot script, and the impact-summary screen (`ARCHITECTURE.md` §6). Design brief per the official PS wording: *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)"* — treat modern/clean visual polish as a real scoring criterion, not secondary to accessibility. |

**Exit criteria:** Both contracts committed to repo, including the `Listing` schema additions from `ARCHITECTURE.md` §6-7. Every service has a `/health` endpoint returning 200 with real dependency status.

---

### Phase 1 — Parallel Build → Checkpoint A

Each service builds against **mocks of its neighbor**, not against real neighbor code.

**Backend-service** (`backend-service-contract.yaml`) — Node.js
- `/auth/register`, `/auth/login`, `/auth/otp/request`, `/auth/otp/verify` with JWT issuance.
- `/artisans/me` GET/PUT.
- `/uploads/init` + `/uploads/{assetId}/complete` — signed URL generation against S3/Firebase.
- `/catalog/listings` POST (creates PENDING listing, stubs the async call to ml-service) + GET (browse).
- `/catalog/listings/{listingId}` GET/PATCH.
- `/orders` POST/GET, `/orders/{orderId}/status` PATCH.
- `/internal/ingestion/whatsapp` and `/internal/ml-callback/{listingId}` — stub bodies that just persist and log; wire real orchestration in Phase 2.
- Internal API key middleware for the `internal/*` routes (protecting the boundary to ml-service).
- Basic rate limiting on public unauthenticated routes (`GET /catalog/listings`) per `ARCHITECTURE.md` §9.3.
- WhatsApp webhook: GET verification handshake working against the real Meta sandbox.
- POST webhook: parse Meta's nested payload down to `WhatsAppInboundPayload` shape; call `/internal/ingestion/whatsapp` internally (same process — no network hop needed).
- `/notifications/dispatch`, `/notifications/register-device`, FCM wiring.
- Socket.IO server skeleton for `order:{orderId}` channel (if chat is in scope this cycle).

**Flutter**
- Onboarding + OTP login flow against backend-service auth.
- Camera capture + voice recording UI, writing to local Hive/SQLite queue.
- Offline queue → background sync worker (stubbed target endpoint).
- Catalog list/detail screens driven by mock listing data.
- Review-and-publish screen (edit description/price before publish), including the optional "what would you normally sell this for?" baseline-price field.

**ml-service** (Python)
- Real image enhancement: `rembg` background removal + basic lighting/crop normalization behind `/image/enhance`.
- Real ASR: Whisper/`faster-whisper` behind `/audio/transcribe`.
- Real translation: LLM-based or IndicTrans2/NLLB behind `/text/translate`.
- `/text/generate-description`: prompt-engineered LLM call, constrained to source text only.
- `/price/suggest`: baseline explainable arithmetic (category range × material/region signals) — ship this before anything fancier.
- **Async job pattern (`202` + `/{jobId}` poll) for `/image/enhance` and `/audio/transcribe`**, per `ARCHITECTURE.md` §9.4 — these are the two calls with meaningfully variable latency, and the pattern needs to actually be built here, not deferred as a "nice to have."
- Model pre-warming at service startup (load once, not per-request) per `ARCHITECTURE.md` §9.4.

**⚑ Checkpoint A — Definition of Done**
- Both backend services run standalone and return dummy-but-correctly-shaped responses for every endpoint in their contract.
- backend-service's WhatsApp sandbox number can receive a test message and the webhook logs it.
- `ml-service`'s `/image/enhance` and `/audio/transcribe` return real `202`/poll behavior even against stub processing logic.
- Standup: each owner demos their service in isolation via curl/Postman.

---

### Phase 2 — Real Integration → Checkpoint B

This is where mocks get torn out. Sequence matters — build the chain in this order so nobody is blocked waiting on someone else's real endpoint:

1. **backend-service ↔ ml-service first.** backend-service's listing-creation orchestration starts calling the *real* ml-service endpoints (not mocks) for image enhance → transcribe → translate → describe → price, correctly handling the async (202/poll) cases for the first two.
2. **backend-service's `/internal/ml-callback/{listingId}` goes live**, persisting real ML results and flipping listing status to `READY`.
3. **Flutter switches from mock API client to live backend-service.** Full loop: capture → upload → create listing → poll/observe status → see real enhanced image, description, price on review screen.
4. **Offline sync test**: toggle airplane mode mid-capture, confirm queued items sync correctly once backend-service is reachable.
5. **Notification dispatch wired internally** on listing `READY` (even if channel selection is still simple/single-path at this point) — this is an in-process call, not a cross-service one.

**⚑ Checkpoint B — Definition of Done**
- A real photo + real voice note captured in the Flutter app produces a real, reviewable catalog listing with actual (not placeholder) enhanced image, bilingual description, and suggested price range.
- Listing status correctly reflects `PENDING → PROCESSING → READY` as the pipeline progresses, including through the async job-polling path.
- A forced Python-side failure (e.g. kill one ML endpoint) results in `FAILED` or `PARTIAL` status with an `errorMessage`, not a stuck listing.

---

### Phase 2b — B2B / Government e-Marketplace Connector (ONDC)

Promoted out of the stretch-goal queue per §0 — this satisfies a named *Expected Solution* line item, not just an impact goal, so it's sequenced alongside core integration rather than after every other feature.

**backend-service (Node.js dev)**
- `POST /ondc/webhook` — parse an inbound Beckn `search` action.
- Map an internal `GET /catalog/listings?query=...` result into a correctly-shaped `on_search` Beckn response — see the sequence diagram and honesty framing in `ARCHITECTURE.md` §5.
- Wire `select`/`init`/`confirm` into the *existing* `Order` entity and status machine, tagging `sourceChannel = ONDC` — no parallel order system.
- No gateway registration or request signing in this phase (that requires real network membership, out of scope) — this phase proves the integration seam, not live network participation.

**⚑ Checkpoint B2 — Definition of Done**
- A simulated Beckn `search` request (via curl/Postman, shaped like a real gateway call) produces a correct `on_search` response built from real catalog data, not a hardcoded fixture.
- A simulated `select → init → confirm` sequence produces a real `Order` row with `sourceChannel = ONDC`, visible in the same admin/catalog views as any other order.
- Team has made and documented the GeM decision from §0/`ARCHITECTURE.md` §5.

---

### Phase 3 — Differentiators → Checkpoint C

- **backend-service (Node.js dev)**: complete the WhatsApp relay end-to-end — real inbound message → download media from Meta's Graph API → store via the internal `/uploads/init` flow → call `/internal/ingestion/whatsapp` → on `READY`, send the artisan a WhatsApp message via `/whatsapp/send` ("Your listing is ready — reply REVIEW to see it"). Harden orchestration error paths. Build the impact-summary aggregation endpoint from `ARCHITECTURE.md` §6 (listings published, revenue, price uplift vs. `artisanBaselinePrice`, channel breakdown). Add scheme-matching rules engine *only if the two ★ priorities and the impact endpoint are already solid* (this remains the one true stretch goal — do not let it displace WhatsApp/offline/impact work).
- **Flutter**: offline-mode polish — retry/backoff on sync failure, clear "queued, will sync" UI state, low-literacy-friendly progress indicators during ML processing. Build the impact-summary screen consuming the new endpoint.
- **ml-service (Python/ML dev)**: refine pricing model using any real sample product data gathered; tune ASR language hints; validate description generation doesn't fabricate details.
- **UI/UX**: finalize "waiting for AI" states, price range slider, description edit view, impact-summary screen visuals; hand off any last design tokens.

**⚑ Checkpoint C — Definition of Done**
- Send a photo + voice note to the WhatsApp sandbox number with zero developer intervention → artisan receives a "your listing is ready" reply with a reviewable link/summary.
- Offline capture → airplane mode → reconnect → sync → listing appears, with no data loss or duplicate submission.
- The impact-summary screen shows real, non-fabricated numbers computed from actual listings/orders created during testing.

---

### Phase 4 — Hardening & Demo Readiness

- Bug bash across all services — prioritize anything that would visibly break the demo path (Checkpoint B, B2, and C flows), not cosmetic issues elsewhere.
- Observability pass per `ARCHITECTURE.md` §9.1: structured logs with correlation ids threaded through backend-service → ml-service calls, so a live-demo failure is debuggable, not just visible.
- Security/privacy pass per `ARCHITECTURE.md` §9.2: confirm the retention policy for raw PII (photos, audio, phone numbers) is actually implemented, not just documented.
- Deploy all services (even to simple free-tier hosts — Render/Railway/Fly.io for backend, Firebase/S3 for storage) so the demo isn't running off someone's laptop hotspot.
- Full dry run of the demo script **at least twice**, timed, with the actual deployed stack — including the ONDC simulated-search moment and the impact-summary screen, since these are the two additions most likely to get skipped if the pitch reverts to a feature-tour habit.
- Pitch deck: lead with the impact narrative (income upliftment — backed by the real §6 numbers, not claimed ones — digital-literacy bridge, WhatsApp as a channel judges instantly understand, and an honest framing of the ONDC connector per `ARCHITECTURE.md` §5) — not a feature list.
- Scope freeze once Checkpoint C and B2 are both met. Anything not done by then is out — no last-minute feature additions.

---

## 4. Ownership & escalation map

| Track | Owner | Immediate escalation if blocked |
|---|---|---|
| Backend: auth, catalog/order CRUD, admin, orchestration, WhatsApp, ONDC connector, notifications | Node.js Dev (backend-service) | Flags contract drift in standup immediately, doesn't silently reinterpret; de-risks Meta sandbox approval in Phase 0, not later |
| Mobile / offline capture / impact dashboard UI | Flutter Dev | Falls back to mocked API longer rather than blocking on backend-service |
| ML inference serving + model selection/tuning + async job pattern | Python/ML Dev (ml-service) | Ships graceful partial-result fallback rather than blocking whole listing on one model timeout; hands off a working pretrained model early rather than chasing architecture improvements under time pressure |
| Design system | UI/UX | Delivers clickable prototype by Checkpoint A so Flutter isn't guessing at spacing |
| Non-functional requirements (observability, security/privacy, rate limiting) | Shared — backend-service dev leads, ml-service dev applies to its own service | Raised at every checkpoint standup, not deferred entirely to Phase 4 |

---

## 5. Top risks & mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Meta WhatsApp sandbox approval delayed | High | Start registration in Phase 0; have a "simulate incoming webhook via curl" fallback for demo if sandbox isn't ready |
| ML models too slow for live demo | Medium | Async job pattern (§9.4) built for real in Phase 1, not deferred; pre-warm models before demo; have a pre-recorded fallback clip |
| Contract drift between services | Medium (lower than before — only 2 backend services to keep in sync) | Frozen contracts after Phase 0; any change flagged in standup, not silently made |
| backend-service becomes a single point of failure — it now owns everything except ML | Medium (consolidation trade-off) | Keep the codebase modular internally (separate route files per domain: auth/, catalog/, whatsapp/, ondc/, etc.) even though it's one deployable, so a bug in one area doesn't require understanding the whole service to fix |
| Offline sync edge cases (dup submits, partial uploads) | Medium | Explicit airplane-mode test pass in Phase 2, not deferred to Phase 4 |
| Pricing model has no real market data | High (expected) | Ship explainable baseline early per charter guidance; refine only if time allows, never block on it |
| Scope creep into stretch goals before ★ priorities are solid | Medium | Scope freeze at Checkpoint C/B2; the scheme-matching rules engine is the one remaining true stretch goal and stays explicitly sequenced last |
| ONDC connector presented in the pitch as more real than it is | Medium (reputational, not technical) | `ARCHITECTURE.md` §5's honesty framing is mandatory pitch-deck language, not optional caveat — rehearse the exact phrasing in Phase 4 |
| Impact-summary numbers get faked/hardcoded under time pressure instead of computed | Medium | Scheduled as a real endpoint + query in Phase 3, checked explicitly at Checkpoint C, not left to a "we'll mock it for the demo" default |

---

## 6. Standup cadence

Mandatory for every developer at each checkpoint (A, B, B2, C), even if your own track is on schedule — this is where contract drift and integration surprises get caught before they cost the final push to demo readiness.
