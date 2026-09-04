from fastapi import Request
from fastapi.responses import JSONResponse

from app.config import INTERNAL_API_KEY

EXEMPT_PATHS = {"/health", "/docs", "/openapi.json"}



async def require_internal_api_key(request: Request, call_next):
    if request.url.path in EXEMPT_PATHS:
        return await call_next(request)
      
    provided_key = request.headers.get("X-Internal-API-Key")
    if not INTERNAL_API_KEY or provided_key != INTERNAL_API_KEY:
        return JSONResponse(
          status_code=401, content={"detail": "Missing or invalid X-Internal-API-Key "}
        )
    return await call_next(request)