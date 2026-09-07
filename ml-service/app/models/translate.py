"""Translate transcribed/raw text into English, Hindi, or any requested
language via an LLM call.

This uses the Anthropic API rather than hosting NLLB-200/IndicTrans2 locally -
ANTHROPIC_API_KEY is already wired for the description-generation step, so
this avoids a second multi-gigabyte model stack for a hackathon-scale
deployment. Swap for a local model later if offline/no-API-cost operation
becomes a requirement.
"""
from app.llm import call_json

SUPPORTED_LANGUAGE_NAMES = {
    "en": "English",
    "hi": "Hindi",
}


def translate_text(text: str, source_language: str, target_languages: list[str]) -> dict:
    """
    Translate `text` (already transcribed, in `source_language`) into each of
    `target_languages`.

    Matches TranslateResult from contracts/ml-service-contract.yaml.
    Raises ValueError for empty input, RuntimeError if the LLM call fails.
    """
    if not text or not text.strip():
        raise ValueError("text is empty - nothing to translate")
    if not target_languages:
        raise ValueError("target_languages must be non-empty")

    target_names = [SUPPORTED_LANGUAGE_NAMES.get(lang, lang) for lang in target_languages]
    system = (
        "You are a precise translator for an e-commerce product catalog. "
        "Translate faithfully - do not add, remove, or embellish details that "
        "aren't in the source text. Respond with ONLY a JSON object mapping "
        "each requested language code to its translation, nothing else."
    )
    user = (
        f"Source language: {source_language}\n"
        f"Source text: {text}\n"
        f"Translate into: {', '.join(f'{c} ({n})' for c, n in zip(target_languages, target_names))}\n"
        'Respond as JSON: {"lang_code": "translation", ...}'
    )

    translations = call_json(system, user)
    missing = [lang for lang in target_languages if lang not in translations]
    if missing:
        raise RuntimeError(f"LLM response missing translations for: {missing}")

    return {"translations": {lang: translations[lang] for lang in target_languages}}


if __name__ == "__main__":
    import json
    import sys

    text = sys.argv[1] if len(sys.argv) > 1 else "यह एक हस्तनिर्मित मिट्टी का बर्तन है"
    source = sys.argv[2] if len(sys.argv) > 2 else "hi"
    targets = sys.argv[3].split(",") if len(sys.argv) > 3 else ["en", "hi"]
    print(json.dumps(translate_text(text, source, targets), indent=2, ensure_ascii=False))
