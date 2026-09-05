import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import ENHANCED_IMAGE_DIR
from app.middleware import require_internal_api_key
from app.routers.audio import router as audio_router
from app.routers.image import router as image_router
from app.routers.pricing import router as pricing_router
from app.routers.text import router as text_router

app = FastAPI(title="SIH26090 ML Inference Service")
# CORS is effectively moot here since ml-service should only ever be called
# server-to-server by backend-service, never directly by a browser — but
# kept permissive for now since this service isn't meant to be internet-facing
# in the first place (see ARCHITECTURE.md's network boundary note).

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

app.middleware("http")(require_internal_api_key)

os.makedirs(ENHANCED_IMAGE_DIR, exist_ok=True)
app.mount("/enhanced", StaticFiles(directory=ENHANCED_IMAGE_DIR), name="enhanced")
app.include_router(pricing_router)
app.include_router(image_router)
app.include_router(audio_router)
app.include_router(text_router)


@app.get("/health")
def health():
    return {
        "status": "ok",
        "modelsLoaded": ["image_enhance_rembg", "asr_groq_whisper", "llm_gemini_translate", "llm_gemini_describe", "pricing_arithmetic"],
    }
