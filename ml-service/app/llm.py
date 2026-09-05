"""Shared Gemini client + JSON-mode helper, used by translate.py and
describe.py so both text-processing steps share one client and one
JSON-parsing convention instead of duplicating it.
"""
import json
from functools import lru_cache

from google import genai
from google.genai import types

from app.config import GEMINI_API_KEY, LLM_MODEL


@lru_cache(maxsize=1)
def client() -> genai.Client:
    """Shared Gemini client - also reused by image_enhance.py for the
    generative retouch step, so the whole service only configures one
    Gemini client."""
    if not GEMINI_API_KEY:
        raise RuntimeError("GEMINI_API_KEY is not set")
    return genai.Client(api_key=GEMINI_API_KEY)


def call_json(system: str, user: str) -> dict:
    """Call the LLM and parse its reply as JSON."""
    try:
        response = client().models.generate_content(
            model=LLM_MODEL,
            contents=user,
            config=types.GenerateContentConfig(
                system_instruction=system,
                response_mime_type="application/json",
            ),
        )
    except genai.errors.APIError as exc:
        # Covers auth failures, rate limits, and transient upstream outages
        # (e.g. Gemini's own 503 "high demand") - callers (translate.py,
        # describe.py) only need to know this was an upstream failure, not a
        # bad-input one, so it maps to RuntimeError like every other
        # model-call failure in this service.
        raise RuntimeError(f"Gemini API call failed: {exc}") from exc

    try:
        return json.loads(response.text)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"LLM did not return valid JSON: {response.text[:200]}") from exc
