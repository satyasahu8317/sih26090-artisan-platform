# Test samples

This folder isn't tracked with real media (product photos and voice notes are
too specific/large to fake usefully) — drop your own files here to manually
verify the two endpoints that can't be checked without real input:

- **A product photo** (`sample.jpg` or similar) — a textile, pottery, or
  jewelry photo, ideally with some background clutter and imperfect lighting,
  since that's exactly the case `/image/enhance` is meant to fix.
- **A voice note** (`sample.ogg`/`.mp3`/`.wav`, 5-30 seconds) — ideally in
  Hindi or a regional Indian language, describing a handmade product, since
  that's the real use case for `/audio/transcribe`.

## Testing directly against the running server

```bash
# from ml-service/, with the server running (uvicorn app.main:app --port 8000)
# and INTERNAL_API_KEY loaded from .env

curl -s -X POST http://localhost:8000/image/enhance \
  -H "Content-Type: application/json" \
  -H "X-Internal-API-Key: $INTERNAL_API_KEY" \
  -d '{"imageUrl": "file:///absolute/path/to/test_samples/sample.jpg"}'
# -> 202 + jobId; poll GET /image/enhance/{jobId} until status is SUCCESS
```

Note: `app/models/image_enhance.py`'s `_load_image` only handles `http(s)://`
URLs or a plain local filesystem path directly (no `file://` scheme) - for a
quick manual test, it's easiest to call the module directly instead of going
through the HTTP layer:

```bash
python -m app.models.image_enhance test_samples/sample.jpg
python -m app.models.ars test_samples/sample.ogg hi
```

Both print the resulting JSON to stdout, matching what the HTTP endpoints
return.
