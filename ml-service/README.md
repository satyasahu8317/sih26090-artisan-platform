# ml-service (Python / FastAPI)

Owns: image enhancement, ASR transcription, translation, description generation, price suggestion.
Stateless — called only by `backend-service`. Never called directly by mobile.

Contract: [`../contracts/ml-service-contract.yaml`](../contracts/ml-service-contract.yaml)

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate   # .venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

## Structure

```
app/
├── main.py
├── image/       # /image/enhance
├── audio/       # /audio/transcribe
├── text/        # /text/translate, /text/generate-description
├── pricing/     # /price/suggest
└── common/      # shared schemas, job-status store
```

## Environment

Copy `.env.example` to `.env`. Each capability should degrade gracefully (partial result, not a crash) if its underlying model call fails or times out.
