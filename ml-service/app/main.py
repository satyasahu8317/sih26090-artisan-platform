from fastapi import FastAPI

app = FastAPI(title="SIH26090 ML Inference Service")


@app.get("/health")
def health():
    return {"status": "ok", "modelsLoaded": []}
