from typing import Optional
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, HTTPException
from pydantic import BaseModel

from app.config import PUBLIC_BASE_URL
from app.jobs import create_job, get_job, run_job
from app.models.image_enhance import enhance_image

router = APIRouter()


class ImageEnhanceRequest(BaseModel):
    imageUrl: str
    listingId: Optional[UUID] = None


class ImageEnhanceResult(BaseModel):
    enhancedImageUrl: str
    confidence: float
    appliedSteps: list[str]


class JobAccepted(BaseModel):
    jobId: str
    statusUrl: str
    estimatedSeconds: int = 10


class ImageEnhanceJobStatus(BaseModel):
    jobId: str
    status: str
    result: Optional[ImageEnhanceResult] = None
    errorMessage: Optional[str] = None


@router.post("/image/enhance", response_model=JobAccepted, status_code=202)
def image_enhance(request: ImageEnhanceRequest, background_tasks: BackgroundTasks) -> JobAccepted:
    # Always async - background removal time scales with image size, so this
    # can't reliably finish inside a request timeout (see ARCHITECTURE.md 9.4).
    job_id = create_job()
    background_tasks.add_task(run_job, job_id, lambda: enhance_image(request.imageUrl))
    return JobAccepted(
        jobId=job_id,
        statusUrl=f"{PUBLIC_BASE_URL}/image/enhance/{job_id}",
        estimatedSeconds=10,
    )


@router.get("/image/enhance/{jobId}", response_model=ImageEnhanceJobStatus)
def image_enhance_status(jobId: str) -> ImageEnhanceJobStatus:
    job = get_job(jobId)
    if job is None:
        raise HTTPException(status_code=404, detail="job not found")
    result = ImageEnhanceResult(**job["result"]) if job["result"] else None
    return ImageEnhanceJobStatus(
        jobId=jobId,
        status=job["status"],
        result=result,
        errorMessage=job["errorMessage"],
    )
