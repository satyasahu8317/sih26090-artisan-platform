from typing import Optional
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, HTTPException
from pydantic import BaseModel

from app.config import PUBLIC_BASE_URL
from app.jobs import create_job, get_job, run_job
from app.models.ars import transcribe_audio

router = APIRouter()


class TranscribeRequest(BaseModel):
    audioUrl: str
    listingId: Optional[UUID] = None
    hintLanguage: Optional[str] = None


class TranscribeResult(BaseModel):
    transcript: str
    detectedLanguage: str
    confidence: float


class JobAccepted(BaseModel):
    jobId: str
    statusUrl: str
    estimatedSeconds: int = 15


class TranscribeJobStatus(BaseModel):
    jobId: str
    status: str
    result: Optional[TranscribeResult] = None
    errorMessage: Optional[str] = None


@router.post("/audio/transcribe", response_model=JobAccepted, status_code=202)
def audio_transcribe(request: TranscribeRequest, background_tasks: BackgroundTasks) -> JobAccepted:
    # Always async - transcription time scales with clip length, so this
    # can't reliably finish inside a request timeout (see ARCHITECTURE.md 9.4).
    job_id = create_job()
    background_tasks.add_task(
        run_job, job_id, lambda: transcribe_audio(request.audioUrl, request.hintLanguage)
    )
    return JobAccepted(
        jobId=job_id,
        statusUrl=f"{PUBLIC_BASE_URL}/audio/transcribe/{job_id}",
        estimatedSeconds=15,
    )


@router.get("/audio/transcribe/{jobId}", response_model=TranscribeJobStatus)
def audio_transcribe_status(jobId: str) -> TranscribeJobStatus:
    job = get_job(jobId)
    if job is None:
        raise HTTPException(status_code=404, detail="job not found")
    result = TranscribeResult(**job["result"]) if job["result"] else None
    return TranscribeJobStatus(
        jobId=jobId,
        status=job["status"],
        result=result,
        errorMessage=job["errorMessage"],
    )
