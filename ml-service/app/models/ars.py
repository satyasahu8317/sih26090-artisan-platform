"""ASR: transcribe an artisan's voice note and detect its spoken language.

Uses Groq's hosted Whisper-large-v3-turbo API rather than a local model -
Groq's inference hardware returns even multi-minute clips in roughly 1-2
seconds, which is the difference between "wait a minute" and "feels instant"
for the artisan, and its free tier means this costs nothing to run. No local
model weights, no local compute burden.
"""
import os
from functools import lru_cache

import requests
from groq import Groq

from app.config import GROQ_API_KEY

MIN_AUDIO_SECONDS = 1.0
MODEL = "whisper-large-v3-turbo"

# Groq's Whisper API returns full language names, not ISO codes - normalize
# the ones this project cares about; fall back to the raw name for anything
# else rather than guessing.
LANGUAGE_NAME_TO_CODE = {
    "english": "en",
    "hindi": "hi",
    "bengali": "bn",
    "tamil": "ta",
    "telugu": "te",
    "marathi": "mr",
    "gujarati": "gu",
    "punjabi": "pa",
    "kannada": "kn",
    "malayalam": "ml",
    "odia": "or",
    "urdu": "ur",
}


@lru_cache(maxsize=1)
def _client() -> Groq:
    if not GROQ_API_KEY:
        raise RuntimeError("GROQ_API_KEY is not set")
    return Groq(api_key=GROQ_API_KEY)


def _load_audio_bytes(audio_url: str) -> bytes:
    if audio_url.startswith("http://") or audio_url.startswith("https://"):
        resp = requests.get(audio_url, timeout=60)
        resp.raise_for_status()
        return resp.content
    if not os.path.exists(audio_url):
        raise ValueError(f"audio file not found: {audio_url}")
    with open(audio_url, "rb") as f:
        return f.read()


def transcribe_audio(audio_url: str, hint_language: str | None = None) -> dict:
    """
    Transcribe a regional-language voice note to text, auto-detecting the
    spoken language unless hint_language is given.

    Matches TranscribeResult from contracts/ml-service-contract.yaml.
    Raises ValueError for bad/empty input, RuntimeError for API failures.
    """
    try:
        audio_bytes = _load_audio_bytes(audio_url)
    except Exception as exc:
        raise ValueError(f"could not load audio from '{audio_url}': {exc}") from exc

    filename = os.path.basename(audio_url.split("?")[0]) or "audio.ogg"

    try:
        response = _client().audio.transcriptions.create(
            file=(filename, audio_bytes),
            model=MODEL,
            language=hint_language,
            response_format="verbose_json",
        )
    except Exception as exc:
        raise RuntimeError(f"transcription failed: {exc}") from exc

    duration = getattr(response, "duration", None)
    if duration is not None and duration < MIN_AUDIO_SECONDS:
        raise ValueError(f"audio is too short to transcribe reliably ({duration:.1f}s)")

    transcript = (response.text or "").strip()
    if not transcript:
        raise ValueError("no speech detected in audio (silent or unrecognized)")

    raw_language = (getattr(response, "language", None) or hint_language or "unknown").lower()
    detected_language = LANGUAGE_NAME_TO_CODE.get(raw_language, raw_language)

    # Groq's API doesn't expose a direct language-detection confidence score -
    # approximate one from segment-level no_speech_prob when available.
    segments = getattr(response, "segments", None) or []
    if segments:
        no_speech_probs = [seg.get("no_speech_prob", 0.0) for seg in segments]
        confidence = round(max(0.0, 1.0 - (sum(no_speech_probs) / len(no_speech_probs))), 3)
    else:
        confidence = 0.9

    return {
        "transcript": transcript,
        "detectedLanguage": detected_language,
        "confidence": confidence,
    }


if __name__ == "__main__":
    import json
    import sys

    if len(sys.argv) < 2:
        print("usage: python ars.py <audio_path_or_url> [hint_language]")
        sys.exit(1)

    hint = sys.argv[2] if len(sys.argv) > 2 else None
    result = transcribe_audio(sys.argv[1], hint)
    print(json.dumps(result, indent=2, ensure_ascii=False))
