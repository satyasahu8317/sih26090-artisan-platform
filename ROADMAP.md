# SIH26090 — Project Roadmap
**AI-Driven Market Linkage & Smart Cataloging App for Marginalized Artisans**
Build window: 36–48 hours · 6 team members · 5-service architecture

This roadmap operationalizes the charter (`Srijan.pdf`) and the three OpenAPI contracts into a task-level, dependency-aware plan. It exists so that at any hour, anyone can answer: *what should I be doing right now, what am I blocked on, and what breaks if I slip.*

---

## 0. Alignment check against the official SIH26090 problem statement

Cross-checked against the official MoSJE problem statement text (not just the internal charter). The charter and contracts already match it closely — mandatory features, impact goals, and the cross-platform + scalable-backend framing all line up. Two things the official text calls out that deserve explicit attention rather than assumption:

1. **"Connect directly with larger B2B buyers or government e-marketplaces" is in the official *Expected Solution* section, not just an impact goal.** In our plan this maps to ONDC integration, currently filed under Section 2's stretch goals — lower priority than the WhatsApp bot and offline-first differentiators. Because this phrase is in the *expected solution* of the actual PS, judges may specifically look for it. **Open decision for the team:** does at least a mocked/minimal ONDC or B2B-buyer-facing connector need to move up in priority, even a thin version, rather than staying last in the stretch-goal queue? Buyer-side catalog browse/orders already covers generic "connect to buyers" — what's not covered yet is the specific government e-marketplace (ONDC) angle the PS names. Flag this at the next standup rather than deciding unilaterally.
2. **UI/UX language from the official PS is more specific than our internal brief captured:** *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)."* This is a slightly different bar than just "usable for low-literacy users" — it also signals judges will score visual polish and modern design language, not only accessibility. Feed this quote directly to the UI/UX designer (see Section 3, Phase 0).

---

## 1. Guiding principles

1. **Contracts before code.** Nobody writes business logic against a guessed shape of another service's API. The three YAML contracts are frozen after Hour 6 sign-off; changes go through a standup flag, not a silent edit.
2. **Vertical slice first, breadth second.** Get one photo + one voice note through the *entire* pipeline (Flutter → Spring Boot → Python → back → Node notify) before polishing any single stage. A thin end-to-end path that works beats five polished stages that don't connect.
3. **Every service is independently runnable from Hour 20.** Mocked-but-correctly-shaped responses count as done for Checkpoint A. Nobody should be blocked waiting on a teammate's real implementation.
4. **Status field is the contract for failure.** `PENDING → PROCESSING → READY → PUBLISHED` (+ `FAILED`) is how partial ML failures surface to the artisan. No silent drops.
5. **WhatsApp bot is the demo's spine.** Everything in the Node.js track is sequenced to have a working sandbox number by Hour 10 — this has the longest external-dependency lead time (Meta app review/setup) and the highest risk of blowing the whole differentiator if started late.

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

**WhatsApp sandbox approval (Node.js, external/Meta) → whatsapp webhook → `/internal/ingestion/whatsapp` (Spring Boot) → ML pipeline (Python) → `/internal/ml-callback` (Spring Boot) → `/notifications/dispatch` (Node.js) → artisan sees "listing ready" on WhatsApp.**

Every link in that chain is owned by a different person. This is why WhatsApp sandbox setup starts at Hour 0, not Hour 32.

---

## 3. Phase-by-phase plan

### Phase 0 — Hours 0–6: Contracts & Scaffolding

| Owner | Tasks |
|---|---|
| All | Review all 3 OpenAPI contracts together. Sign off or flag changes live — this is the only point where contract edits are cheap. |
| Spring Boot | Scaffold project (Spring Initializr: Web, Security, Data JPA, PostgreSQL driver, Validation). Stand up Swagger UI serving the frozen contract. Define entity skeletons: `User`, `ArtisanProfile`, `Listing`, `Order`, `Asset`. |
| Flutter | Scaffold app (Riverpod/Bloc, routing). Stub API client against the frozen contract using a local JSON mock server (e.g. `json-server` or hand-rolled mock interceptor). |
| Python | Scaffold FastAPI project. Stub all 5 endpoints (`/image/enhance`, `/audio/transcribe`, `/text/translate`, `/text/generate-description`, `/price/suggest`) returning hardcoded-but-schema-correct responses. |
| Node.js | Scaffold Express project. **Start Meta WhatsApp Business sandbox registration now** — this has unpredictable external latency and must not be the long pole later. Stub `/health`, `/notifications/register-device`. |
| ML Developer | Pull and smoke-test `rembg`, Whisper (or IndicWhisper), IndicTrans2/NLLB locally. Confirm they run on available hardware before committing to them in the demo. |
| UI/UX | Deliver low-fi wireframes for: onboarding, capture flow, review-and-publish screen, WhatsApp bot script. Design brief per the official PS wording: *"a highly responsive, minimalist UI/UX design (incorporating modern, clean visual hierarchies and accessible layouts)"* — treat modern/clean visual polish as a real scoring criterion, not secondary to accessibility. |

**Exit criteria:** All 3 contracts committed to repo. Every service has a `/health` endpoint returning 200.

---

### Phase 1 — Hours 6–20: Parallel Build → Checkpoint A

Each service builds against **mocks of its neighbors**, not against real neighbor code.

**Spring Boot** (`springboot-api-contract.yaml`)
- `/auth/register`, `/auth/login`, `/auth/otp/request`, `/auth/otp/verify` with JWT issuance.
- `/artisans/me` GET/PUT.
- `/uploads/init` + `/uploads/{assetId}/complete` — signed URL generation against S3/Firebase.
- `/catalog/listings` POST (creates PENDING listing, stubs the async dispatch call) + GET (browse).
- `/catalog/listings/{listingId}` GET/PATCH.
- `/orders` POST/GET, `/orders/{orderId}/status` PATCH.
- `/internal/ingestion/whatsapp` and `/internal/ml-callback/{listingId}` — stub bodies that just persist and log; wire real orchestration in Phase 2.
- Internal API key middleware for the two `internal/*` routes.

**Flutter**
- Onboarding + OTP login flow against Spring Boot auth.
- Camera capture + voice recording UI, writing to local Hive/SQLite queue.
- Offline queue → background sync worker (stubbed target endpoint).
- Catalog list/detail screens driven by mock listing data.
- Review-and-publish screen (edit description/price before publish).

**Python (ML)**
- Real image enhancement: `rembg` background removal + basic lighting/crop normalization behind `/image/enhance`.
- Real ASR: Whisper/IndicWhisper behind `/audio/transcribe`.
- Real translation: IndicTrans2/NLLB behind `/text/translate`.
- `/text/generate-description`: prompt-engineered LLM call, constrained to source text only.
- `/price/suggest`: baseline explainable regression (4–6 features) — ship this before anything fancier.
- Async job pattern (`202` + `/{jobId}` poll) for anything that won't reliably finish inside a request timeout.

**Node.js**
- WhatsApp webhook: GET verification handshake working against the real Meta sandbox.
- POST webhook: parse Meta's nested payload down to `WhatsAppInboundPayload` shape; stub the relay call to Spring Boot for now.
- `/notifications/dispatch`, `/notifications/register-device`, FCM wiring.
- Socket.IO server skeleton for `order:{orderId}` channel (if chat is in scope this cycle).

**⚑ Checkpoint A (≈Hour 20) — Definition of Done**
- Every service runs standalone and returns dummy-but-correctly-shaped responses for every endpoint in its contract.
- Spring Boot's Swagger UI is live and matches the frozen YAML.
- Node.js WhatsApp sandbox number can receive a test message and the webhook logs it.
- Standup: each owner demos their service in isolation via curl/Postman.

---

### Phase 2 — Hours 20–32: Real Integration → Checkpoint B

This is where mocks get torn out. Sequence matters — build the chain in this order so nobody is blocked waiting on someone else's real endpoint:

1. **Spring Boot ↔ Python first.** Spring Boot's listing-creation orchestration starts calling the *real* Python endpoints (not mocks) for image enhance → transcribe → translate → describe → price. Handle the async (202/poll) cases.
2. **Spring Boot `/internal/ml-callback/{listingId}` goes live**, persisting real ML results and flipping listing status to `READY`.
3. **Flutter switches from mock API client to live Spring Boot.** Full loop: capture → upload → create listing → poll/observe status → see real enhanced image, description, price on review screen.
4. **Offline sync test**: toggle airplane mode mid-capture, confirm queued items sync correctly once Spring Boot is reachable.
5. **Spring Boot → Node.js notification call wired** on listing `READY` (even if Node.js's *channel selection* is still simple/single-path at this point).

**⚑ Checkpoint B (≈Hour 32) — Definition of Done**
- A real photo + real voice note captured in the Flutter app produces a real, reviewable catalog listing with actual (not placeholder) enhanced image, bilingual description, and suggested price range.
- Listing status correctly reflects `PENDING → PROCESSING → READY` as the pipeline progresses.
- A forced Python-side failure (e.g. kill one ML endpoint) results in `FAILED` or `PARTIAL` status with an `errorMessage`, not a stuck listing.

---

### Phase 3 — Hours 32–40: Differentiators → Checkpoint C

- **Node.js**: complete the WhatsApp relay — real inbound message → download media from Meta's Graph API → re-upload via Spring Boot's `/uploads/init` flow → call `/internal/ingestion/whatsapp` → on `READY`, send the artisan a WhatsApp message via `/whatsapp/send` ("Your listing is ready — reply REVIEW to see it").
- **Flutter**: offline-mode polish — retry/backoff on sync failure, clear "queued, will sync" UI state, low-literacy-friendly progress indicators during ML processing.
- **ML Developer + Python**: refine pricing model using any real sample product data gathered; tune ASR language hints; validate description generation doesn't fabricate details.
- **UI/UX**: finalize "waiting for AI" states, price range slider, description edit view — hand off any last design tokens.
- **Spring Boot**: harden orchestration error paths; add scheme-matching rules engine *only if the two ★ priorities are already solid* (stretch goal, do not let it displace WhatsApp/offline work).

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
| Core API & orchestration | Spring Boot Dev | Flags contract drift in standup immediately, doesn't silently reinterpret |
| Mobile / offline capture | Flutter Dev | Falls back to mocked API longer rather than blocking on Spring Boot |
| ML inference serving | Python Dev | Ships graceful partial-result fallback rather than blocking whole listing on one model timeout |
| Model selection/tuning | ML Dev | Hands off working pretrained model early; doesn't chase architecture improvements under time pressure |
| Realtime/WhatsApp | Node.js Dev | De-risks Meta sandbox approval at Hour 0, not Hour 20 |
| Design system | UI/UX | Delivers clickable prototype by Checkpoint A so Flutter isn't guessing at spacing |

---

## 5. Top risks & mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Meta WhatsApp sandbox approval delayed | High | Start registration at Hour 0; have a "simulate incoming webhook via curl" fallback for demo if sandbox isn't ready |
| ML models too slow for live demo | Medium | Async job pattern (202 + poll) built in from Phase 1; pre-warm models before demo; have a pre-recorded fallback clip |
| Contract drift between services | Medium | Frozen contracts after Hour 6; any change flagged in standup, not silently made |
| Offline sync edge cases (dup submits, partial uploads) | Medium | Explicit airplane-mode test pass in Phase 2, not deferred to Phase 4 |
| Pricing model has no real market data | High (expected) | Ship explainable baseline early per charter guidance; refine only if time allows, never block on it |
| Scope creep into stretch goals before ★ priorities are solid | Medium | Hour 40 scope freeze; stretch goals explicitly sequenced after WhatsApp + offline |
| Missing the PS's explicit "B2B buyers / govt e-marketplace" ask because ONDC sits last in stretch goals | Medium | See Section 0, item 1 — needs an explicit team decision, not a default deprioritization |

---

## 6. Standup cadence

Mandatory for all 6 members at each checkpoint (≈Hour 20, ≈Hour 32, ≈Hour 40), even if your own track is on schedule — this is where contract drift and integration surprises get caught before they cost the final hours.
