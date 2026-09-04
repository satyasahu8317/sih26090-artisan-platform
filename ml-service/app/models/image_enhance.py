"""Background removal, lighting correction, and e-commerce standard formatting.

Model loading is lazy and cached (see _session()) so the rembg session loads
once per process, not per request - the FastAPI app just needs to call
enhance_image() per call, no explicit startup wiring required.
"""
import io
import os
import uuid
from functools import lru_cache

import cv2
import numpy as np
import requests
from google.genai import types
from PIL import Image
from rembg import new_session, remove

from app.config import (
    ENABLE_GENERATIVE_RETOUCH,
    ENHANCED_IMAGE_DIR,
    GEMINI_IMAGE_MODEL,
    PUBLIC_BASE_URL,
)
from app.llm import client as gemini_client

TARGET_SIZE = 1000

RETOUCH_PROMPT = (
    "This is an e-commerce product photo with the background already removed "
    "to white. Polish it into a clean studio product photo: even, soft "
    "lighting, a pure white seamless background, and remove dust or smudge "
    "marks from the product's surface. Do NOT change the product's shape, "
    "color, proportions, text, or logo in any way - only improve lighting "
    "and surface cleanliness, nothing else about the product itself."
)


@lru_cache(maxsize=1)
def _session():
    return new_session("u2net")


def _load_image(image_url: str) -> Image.Image:
    if image_url.startswith("http://") or image_url.startswith("https://"):
        resp = requests.get(image_url, timeout=30)
        resp.raise_for_status()
        return Image.open(io.BytesIO(resp.content)).convert("RGB")
    return Image.open(image_url).convert("RGB")


def _correct_lighting(image: Image.Image) -> Image.Image:
    # CLAHE (adaptive histogram equalization) on the lightness channel only -
    # evens out uneven/poor lighting far more effectively than a global
    # autocontrast, without shifting color balance (LAB separates lightness
    # from color, so only L gets touched).
    bgr = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
    lab = cv2.cvtColor(bgr, cv2.COLOR_BGR2LAB)
    l_channel, a_channel, b_channel = cv2.split(lab)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    l_channel = clahe.apply(l_channel)
    lab = cv2.merge((l_channel, a_channel, b_channel))
    bgr = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
    return Image.fromarray(cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB))


def _remove_background(image: Image.Image) -> Image.Image:
    cutout = remove(image, session=_session())  # RGBA, subject on transparent bg
    canvas = Image.new("RGB", cutout.size, (255, 255, 255))
    canvas.paste(cutout, mask=cutout.split()[3])
    return canvas


def _remove_blemishes(image: Image.Image) -> Image.Image:
    # Denoise dust/smudge marks on the product surface. Runs after
    # background removal (product isolated on white) so it only smooths the
    # product region, not the original photo's background texture, and uses
    # moderate strength so it doesn't erase real texture/detail along with
    # the noise.
    bgr = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
    denoised = cv2.fastNlMeansDenoisingColored(bgr, None, h=7, hColor=7, templateWindowSize=7, searchWindowSize=21)
    return Image.fromarray(cv2.cvtColor(denoised, cv2.COLOR_BGR2RGB))


def _crop_to_square(image: Image.Image, size: int = TARGET_SIZE) -> Image.Image:
    # Crop to the non-white bounding box so the product is centered, not the
    # original frame's empty space.
    mask = image.convert("L").point(lambda p: 255 if p < 250 else 0)
    bbox = mask.getbbox()
    if bbox:
        image = image.crop(bbox)
    w, h = image.size
    side = max(w, h)
    square = Image.new("RGB", (side, side), (255, 255, 255))
    square.paste(image, ((side - w) // 2, (side - h) // 2))
    return square.resize((size, size), Image.LANCZOS)


def _generative_retouch(image: Image.Image) -> Image.Image:
    """
    Polish background/lighting via Gemini's image model, on top of - not
    instead of - rembg's deterministic cutout. The cutout already fixed the
    product's exact shape/edges before this runs, so this step only touches
    presentation (studio background, even lighting, surface cleanliness);
    the prompt explicitly forbids it from re-drawing the product itself.

    Raises RuntimeError on any failure - callers should treat this step as
    optional and fall back to the rembg-only result rather than failing the
    whole request over a retouch-specific problem (rate limit, no image
    returned, etc).
    """
    buf = io.BytesIO()
    image.save(buf, format="PNG")

    try:
        response = gemini_client().models.generate_content(
            model=GEMINI_IMAGE_MODEL,
            contents=[
                RETOUCH_PROMPT,
                types.Part.from_bytes(data=buf.getvalue(), mime_type="image/png"),
            ],
        )
        for part in response.candidates[0].content.parts:
            if part.inline_data is not None:
                return Image.open(io.BytesIO(part.inline_data.data)).convert("RGB")
        raise RuntimeError("Gemini did not return an image")
    except Exception as exc:
        raise RuntimeError(f"generative retouch failed: {exc}") from exc


def enhance_image(image_url: str) -> dict:
    """
    Clean up a raw product photo: background removal, lighting correction,
    crop/resize to a centered TARGET_SIZE x TARGET_SIZE e-commerce square.

    Matches ImageEnhanceResult from contracts/ml-service-contract.yaml.
    Raises ValueError (bad input) or RuntimeError (processing failure) on
    failure - the router translates these into HTTP error responses rather
    than silently returning a broken image.
    """
    try:
        image = _load_image(image_url)
    except Exception as exc:
        raise ValueError(f"could not load image from '{image_url}': {exc}") from exc

    applied_steps = []
    try:
        image = _correct_lighting(image)
        applied_steps.append("lighting_correction")

        image = _remove_background(image)
        applied_steps.append("background_removal")

        image = _remove_blemishes(image)
        applied_steps.append("blemish_removal")

        image = _crop_to_square(image)
        applied_steps.append("crop_to_standard")
    except Exception as exc:
        raise RuntimeError(f"image enhancement failed after steps {applied_steps}: {exc}") from exc

    # Optional, off by default: Gemini's image-generation model has no free
    # tier (requires billing), unlike its text models - see ARCHITECTURE.md's
    # known-limitations note. The deterministic steps above already guarantee
    # a correct, faithful product photo, so this only runs when explicitly
    # enabled, and degrades gracefully (rather than failing the request) if
    # the call fails for any reason.
    if ENABLE_GENERATIVE_RETOUCH:
        try:
            image = _generative_retouch(image)
            applied_steps.append("generative_retouch")
        except RuntimeError:
            pass

    os.makedirs(ENHANCED_IMAGE_DIR, exist_ok=True)
    filename = f"{uuid.uuid4()}.jpg"
    output_path = os.path.join(ENHANCED_IMAGE_DIR, filename)
    image.save(output_path, "JPEG", quality=92)

    return {
        "enhancedImageUrl": f"{PUBLIC_BASE_URL}/enhanced/{filename}",
        "confidence": 0.92 if "generative_retouch" in applied_steps else 0.85,
        "appliedSteps": applied_steps,
    }


if __name__ == "__main__":
    import json
    import sys

    if len(sys.argv) < 2:
        print("usage: python image_enhance.py <image_path_or_url>")
        sys.exit(1)

    result = enhance_image(sys.argv[1])
    print(json.dumps(result, indent=2))
