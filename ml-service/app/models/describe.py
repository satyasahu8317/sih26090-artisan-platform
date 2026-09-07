"""Turn a rough, spoken-style product description into a polished,
SEO-friendly, bilingual (English + Hindi) e-commerce listing.

Constrained to the facts already present in the source text - the prompt
explicitly forbids inventing materials, techniques, or claims not present in
the artisan's own words, per ARCHITECTURE.md's "the system drafts, the
artisan decides" principle.
"""
from app.llm import call_json


def generate_description(translated_text_en: str, category: str, keywords: list[str] | None = None) -> dict:
    """
    Generate descriptionEn, descriptionHi, and seoKeywords from an English
    translation of the artisan's voice note plus basic product metadata.

    Matches DescriptionResult from contracts/ml-service-contract.yaml.
    Raises ValueError for empty input, RuntimeError if the LLM call fails.
    """
    if not translated_text_en or not translated_text_en.strip():
        raise ValueError("translatedTextEn is empty - nothing to describe")

    keywords = keywords or []
    system = (
        "You are an e-commerce copywriter for handmade Indian handicrafts. "
        "Write a short, factual, SEO-friendly product description in both "
        "English and Hindi, based ONLY on the facts given - never invent "
        "materials, techniques, origin claims, or measurements not present "
        "in the source text. Respond with ONLY a JSON object, no prose "
        "outside it."
    )
    user = (
        f"Category: {category}\n"
        f"Source description (English): {translated_text_en}\n"
        f"Extra keywords to weave in naturally if relevant: {', '.join(keywords) or 'none'}\n"
        'Respond as JSON: {"descriptionEn": "...", "descriptionHi": "...", "seoKeywords": ["...", ...]}'
    )

    result = call_json(system, user)
    for field in ("descriptionEn", "descriptionHi", "seoKeywords"):
        if field not in result:
            raise RuntimeError(f"LLM response missing '{field}'")

    return {
        "descriptionEn": result["descriptionEn"],
        "descriptionHi": result["descriptionHi"],
        "seoKeywords": result["seoKeywords"],
    }


if __name__ == "__main__":
    import json
    import sys

    text = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "This is a handmade clay pot, made using traditional wheel-thrown pottery techniques."
    )
    category = sys.argv[2] if len(sys.argv) > 2 else "Pottery"
    print(json.dumps(generate_description(text, category), indent=2, ensure_ascii=False))
