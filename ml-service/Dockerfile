FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
# Render (and most PaaS hosts) assign the actual listening port via $PORT at
# runtime and route traffic there - a hardcoded --port ignores that and the
# platform's proxy waits forever for a container that isn't actually
# listening where it expects. Fall back to 8000 for local/docker-compose use.
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
