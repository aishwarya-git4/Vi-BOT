FROM python:3.11-slim AS builder
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git \
    build-essential \
    curl \
    git \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

COPY api/requirements-base.txt api/requirements-ml.txt ./api/
# Copy requirement files
COPY api/requirements-base.txt ./requirements-base.txt
COPY api/requirements-ml.txt ./requirements-ml.txt

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir -r ./api/requirements-base.txt -w /wheels && \
    pip install --no-cache-dir torch==2.7.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    pip wheel --no-cache-dir -r ./api/requirements-ml.txt -w /wheels
# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

FROM python:3.11-slim
# Install torch with CPU wheels explicitly
RUN pip install --no-cache-dir torch==2.7.1 --index-url https://download.pytorch.org/whl/cpu

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels
# Install rest of dependencies
RUN pip install --no-cache-dir -r requirements-base.txt -r requirements-ml.txt

# Copy rest of code
COPY . .

EXPOSE 8080

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]