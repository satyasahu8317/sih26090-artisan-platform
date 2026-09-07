# ml-service (Python / FastAPI)

Owns: image enhancement, ASR transcription, translation, description generation, price suggestion.
Stateless — called only by `backend-service`. Never called directly by mobile.

Contract: [`../contracts/ml-service-contract.yaml`](../contracts/ml-service-contract.yaml)
Architecture & non-functional stance: [`../ARCHITECTURE.md`](../ARCHITECTURE.md)

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate   # .venv\Scripts\activate on Windows
pip install -r requirements.txt
cp .env.example .env        # fill in GROQ_API_KEY, GEMINI_API_KEY, INTERNAL_API_KEY
uvicorn app.main:app --reload --port 8000
```

Run the test suite (only the pure-logic pieces — pricing arithmetic, job-store transitions — are covered; the actual model/API calls are meant to be verified manually, see below):

```bash
pip install -r requirements-dev.txt
pytest
```

## Structure

```
app/
├── main.py            # FastAPI app, router wiring, /health
├── config.py           # env var loading
├── middleware.py        # X-Internal-API-Key enforcement
├── jobs.py             # in-memory async job store (202 + poll pattern)
├── llm.py              # shared Gemini client + JSON-mode helper
├── models/              # standalone, independently-testable core logic
│   ├── image_enhance.py  # rembg background removal + lighting + crop
│   ├── ars.py             # Groq-hosted Whisper transcription
│   ├── translate.py        # Gemini translation
│   ├── describe.py          # Gemini SEO description generation
│   └── pricing.py            # explainable arithmetic pricing
└── routers/              # thin FastAPI wrappers matching the contract
    ├── image.py, audio.py  # async: POST returns 202+jobId, GET polls status
    ├── text.py               # sync: translate, generate-description
    └── pricing.py             # sync: price/suggest
```

Every `app/models/*.py` file is independently runnable and testable via its own `if __name__ == "__main__":` block, e.g.:

```bash
python -m app.models.pricing Pottery 300 Rajasthan
python -m app.models.image_enhance sample.jpg
python -m app.models.ars sample.ogg hi
python -m app.models.translate "यह एक हस्तनिर्मित मिट्टी का बर्तन है" hi en,hi
python -m app.models.describe "handmade clay pot" Pottery
```

## Environment

Copy `.env.example` to `.env`:

| Variable | Required for | Notes |
|---|---|---|
| `INTERNAL_API_KEY` | every request | Must match the value `backend-service` sends as `X-Internal-API-Key`; `/health` is exempt. |
| `GROQ_API_KEY` | `/audio/transcribe` | Free-tier key from [console.groq.com](https://console.groq.com) — used for Whisper-large-v3-turbo hosted transcription. |
| `GEMINI_API_KEY` | `/text/translate`, `/text/generate-description` | Free-tier key from [aistudio.google.com](https://aistudio.google.com) — used for both translation and description generation. |
| `LLM_MODEL` | text endpoints | Defaults to `gemini-3.6-flash`. |
| `ENABLE_GENERATIVE_RETOUCH` | `/image/enhance` | Defaults to `false`. See known limitations below before turning this on. |
| `PUBLIC_BASE_URL` | `/image/enhance` | Used to build the returned `enhancedImageUrl` and job `statusUrl`s. |
| `ENHANCED_IMAGE_DIR` | `/image/enhance` | Where processed images are written and served from (mounted at `/enhanced`). |

## Async pattern (image + audio)

`/image/enhance` and `/audio/transcribe` always return `202 Accepted` with a `jobId` immediately — the actual work (background removal, transcription) runs after the response via FastAPI `BackgroundTasks`, tracked in `app/jobs.py`'s in-memory store. Poll `GET {statusUrl}` until `status` is `SUCCESS` or `FAILED`. `/text/translate`, `/text/generate-description`, and `/price/suggest` are fast enough to stay synchronous. See `ARCHITECTURE.md` §9.4 for why — and note the job store is in-memory only (fine for a single dev instance; a real deployment should swap it for Redis without touching router code).

## Known limitations

- **Gemini's image-generation model has no free tier** (confirmed by testing: `limit: 0` on the free-tier quota, not just rate-limited) — it requires a Google Cloud project with billing enabled. `app/models/image_enhance.py`'s `_generative_retouch` step is fully built but gated behind `ENABLE_GENERATIVE_RETOUCH=false` by default for exactly this reason. `/image/enhance` instead uses a free deterministic pipeline: `rembg` background removal, CLAHE lighting correction, and OpenCV denoising for blemish/dust removal — genuinely better than a plain autocontrast, but it won't fully erase blemishes the way a generative retouch could, by design (denoising strength is kept conservative so real product texture isn't blurred away with it).
- **Job store is in-memory and per-process.** It does not survive a restart and won't work correctly across multiple `uvicorn` workers/replicas — fine for local dev and a single-instance deployment, not for horizontal scaling as-is (see `ARCHITECTURE.md` §9.4).
- **Translation/description quality depends on Gemini's language coverage**, which is strong for Hindi and English but untested here for less-common regional Indian languages.
- **ASR language detection (Groq/Whisper) returns full language names, not codes** — `app/models/ars.py` normalizes the common Indian languages it knows about; an unrecognized language name is passed through as-is rather than guessed at.
- **Pricing is deliberately simple, explainable arithmetic** (category base range × material-cost floor × regional multiplier) — not a trained model. This is intentional per the charter, not a shortcut.
- **No live sample media is bundled** — see `test_samples/README.md` for what to provide to smoke-test each module yourself.
