from typing import Optional
from uuid import UUID

from fastapi import APIRouter
from pydantic import BaseModel

from app.models.pricing import suggest_price

router = APIRouter()


class PriceSuggestRequest(BaseModel):
    listingId: Optional[UUID] = None
    category: str
    enhancedImageUrl: Optional[str] = None
    descriptionEn: Optional[str] = None
    materialCost: Optional[float] = None
    region: Optional[str] = None


class PriceSuggestResult(BaseModel):
    suggestedPriceMin: float
    suggestedPriceMax: float
    currency: str = "INR"
    explanation: str
    featuresUsed: list[str]


@router.post("/price/suggest", response_model=PriceSuggestResult)
def price_suggest(request: PriceSuggestRequest) -> PriceSuggestResult:
    result = suggest_price(request.category, request.materialCost, request.region)
    return PriceSuggestResult(**result)
