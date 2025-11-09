FROM python:3.11-slim AS builder

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git \
    && rm -rf /var/lib/apt/lists/*

COPY api/requirements-base.txt api/requirements-ml.txt ./api/

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir -r ./api/requirements-base.txt -w /wheels && \
    pip install --no-cache-dir torch==2.7.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    pip wheel --no-cache-dir -r ./api/requirements-ml.txt -w /wheels

FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

COPY . .
EXPOSE 8080
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
