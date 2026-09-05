import os


INTERNAL_API_KEY = os.environ.get("INTERNAL_API_KEY", "")
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
LLM_MODEL = os.getenv("LLM_MODEL", "gemini-3.6-flash")
GEMINI_IMAGE_MODEL = os.getenv("GEMINI_IMAGE_MODEL", "gemini-2.5-flash-image")
ENABLE_GENERATIVE_RETOUCH = os.getenv("ENABLE_GENERATIVE_RETOUCH", "false").lower() == "true"
PUBLIC_BASE_URL = os.getenv("PUBLIC_BASE_URL", "http://localhost:8000")
ENHANCED_IMAGE_DIR = os.getenv("ENHANCED_IMAGE_DIR", "/tmp/enhanced")
