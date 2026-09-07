"""Explainable arithmetic pricing: base category price x material/size multipliers.

No trained model, no live scraping - deliberately simple so the reasoning is
easy to demo and justify. Reference data lives in data/market_reference_prices.json,
a per-category list of observed market prices (used to derive a base range).
"""
import json
import os
from functools import lru_cache

_REFERENCE_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "market_reference_prices.json")

REGION_MULTIPLIERS = {
    # Small demand-weighting nudge; unlisted regions fall back to 1.0.
    "Rajasthan": 1.05,
    "West Bengal": 1.0,
    "Kerala": 1.05,
    "Uttar Pradesh": 0.95,
}


@lru_cache(maxsize=1)
def _reference_prices() -> dict:
    with open(_REFERENCE_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def _base_range(category: str) -> tuple[float, float]:
    prices = _reference_prices()
    series = prices.get(category, prices["default"])
    return min(series), max(series)


def suggest_price(
    category: str,
    material_cost: float | None = None,
    region: str | None = None,
) -> dict:
    """
    Suggest a price range for a listing using transparent arithmetic:
    base category range (from market reference data) adjusted by a material-cost
    signal and a small regional multiplier.

    Matches PriceSuggestResult from contracts/ml-service-contract.yaml.
    """
    base_min, base_max = _base_range(category)
    features_used = ["category_avg_price"]

    region_multiplier = 1.0
    if region:
        region_multiplier = REGION_MULTIPLIERS.get(region, 1.0)
        features_used.append("regional_demand_index")

    material_multiplier = 1.0
    if material_cost is not None and material_cost > 0:
        # Material cost anchors the floor: never suggest below ~90% of raw cost.
        base_min = max(base_min, material_cost * 0.9)
        base_max = max(base_max, material_cost * 1.6)
        material_multiplier = 1.0
        features_used.append("material_cost")

    suggested_min = round(base_min * region_multiplier * material_multiplier, 2)
    suggested_max = round(base_max * region_multiplier * material_multiplier, 2)

    reasoning_parts = [f"Base range for '{category}' from market reference data: ₹{base_min:.0f}-₹{base_max:.0f}."]
    if material_cost is not None and material_cost > 0:
        reasoning_parts.append(f"Floor raised to respect a ₹{material_cost:.0f} material cost input.")
    if region:
        reasoning_parts.append(f"Adjusted by regional demand index for {region} (x{region_multiplier}).")

    return {
        "suggestedPriceMin": suggested_min,
        "suggestedPriceMax": suggested_max,
        "currency": "INR",
        "explanation": " ".join(reasoning_parts),
        "featuresUsed": features_used,
    }


if __name__ == "__main__":
    import sys

    category = sys.argv[1] if len(sys.argv) > 1 else "Pottery"
    material_cost = float(sys.argv[2]) if len(sys.argv) > 2 else None
    region = sys.argv[3] if len(sys.argv) > 3 else None
    print(json.dumps(suggest_price(category, material_cost, region), indent=2, ensure_ascii=False))
