from app.models.pricing import suggest_price


def test_suggest_price_uses_category_reference_range():
    result = suggest_price("Pottery")
    assert result["currency"] == "INR"
    assert result["suggestedPriceMin"] <= result["suggestedPriceMax"]
    assert "category_avg_price" in result["featuresUsed"]


def test_suggest_price_unknown_category_falls_back_to_default():
    result = suggest_price("NotARealCategory")
    assert result["suggestedPriceMin"] > 0


def test_suggest_price_material_cost_raises_floor():
    baseline = suggest_price("Pottery")
    with_cost = suggest_price("Pottery", material_cost=2000)
    assert with_cost["suggestedPriceMin"] > baseline["suggestedPriceMin"]
    assert "material_cost" in with_cost["featuresUsed"]


def test_suggest_price_region_adds_feature():
    result = suggest_price("Pottery", region="Rajasthan")
    assert "regional_demand_index" in result["featuresUsed"]
