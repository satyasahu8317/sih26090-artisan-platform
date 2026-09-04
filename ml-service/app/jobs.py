"""In-memory job store backing the async 202+poll pattern for slow ml-service
calls (image enhance, audio transcribe) - see ARCHITECTURE.md Section 9.4.

Swap for Redis in production without changing router code: this module is the
only thing that would need to change, since routers only call
create_job/get_job/run_job.
"""
import uuid
from enum import Enum
from threading import Lock
from typing import Callable, Optional


class JobStatus(str, Enum):
    QUEUED = "QUEUED"
    PROCESSING = "PROCESSING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"


_jobs: dict[str, dict] = {}
_lock = Lock()


def create_job() -> str:
    job_id = str(uuid.uuid4())
    with _lock:
        _jobs[job_id] = {"status": JobStatus.QUEUED, "result": None, "errorMessage": None}
    return job_id


def get_job(job_id: str) -> Optional[dict]:
    with _lock:
        job = _jobs.get(job_id)
        return dict(job) if job else None


def run_job(job_id: str, fn: Callable[[], dict]) -> None:
    """
    Run `fn`, recording its result or failure against `job_id`.

    Intended to be scheduled via FastAPI's BackgroundTasks so the request
    handler can return 202 immediately while this runs after the response
    is sent.
    """
    with _lock:
        _jobs[job_id]["status"] = JobStatus.PROCESSING
    try:
        result = fn()
        with _lock:
            _jobs[job_id]["status"] = JobStatus.SUCCESS
            _jobs[job_id]["result"] = result
    except Exception as exc:
        with _lock:
            _jobs[job_id]["status"] = JobStatus.FAILED
            _jobs[job_id]["errorMessage"] = str(exc)
