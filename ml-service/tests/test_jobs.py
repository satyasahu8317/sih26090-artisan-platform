from app.jobs import JobStatus, create_job, get_job, run_job


def test_job_lifecycle_success():
    job_id = create_job()
    assert get_job(job_id)["status"] == JobStatus.QUEUED

    run_job(job_id, lambda: {"ok": True})

    job = get_job(job_id)
    assert job["status"] == JobStatus.SUCCESS
    assert job["result"] == {"ok": True}
    assert job["errorMessage"] is None


def test_job_lifecycle_failure():
    job_id = create_job()

    def boom():
        raise ValueError("bad input")

    run_job(job_id, boom)

    job = get_job(job_id)
    assert job["status"] == JobStatus.FAILED
    assert job["result"] is None
    assert "bad input" in job["errorMessage"]


def test_get_job_missing_returns_none():
    assert get_job("does-not-exist") is None
