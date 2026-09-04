from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.models.describe import generate_description
from app.models.translate import translate_text

router = APIRouter()


class TranslateRequest(BaseModel):
    text: str
    sourceLanguage: str
    targetLanguages: list[str]


class TranslateResult(BaseModel):
    translations: dict[str, str]


class DescriptionRequest(BaseModel):
    translatedTextEn: str
    category: str
    keywords: Optional[list[str]] = None


class DescriptionResult(BaseModel):
    descriptionEn: str
    descriptionHi: str
    seoKeywords: list[str]


@router.post("/text/translate", response_model=TranslateResult)
def text_translate(request: TranslateRequest) -> TranslateResult:
    # Fast enough to stay synchronous - unlike image/audio, no async job
    # pattern needed here (see ARCHITECTURE.md 9.4).
    try:
        result = translate_text(request.text, request.sourceLanguage, request.targetLanguages)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return TranslateResult(**result)


@router.post("/text/generate-description", response_model=DescriptionResult)
def text_generate_description(request: DescriptionRequest) -> DescriptionResult:
    try:
        result = generate_description(request.translatedTextEn, request.category, request.keywords)
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return DescriptionResult(**result)
