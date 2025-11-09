# ===== Stage 1: Builder =====
FROM python:3.11-slim AS builder

# Set working directory
WORKDIR /app

# Install minimal build tools for building wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements to leverage Docker cache
COPY api/requirements-base.txt ./requirements-base.txt
COPY api/requirements-ml.txt ./requirements-ml.txt

# Upgrade pip and build wheels for all Python packages except torch
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir -r requirements-base.txt -w /wheels && \
    pip wheel --no-cache-dir -r requirements-ml.txt -w /wheels

# ===== Stage 2: Final image =====
FROM python:3.11-slim

WORKDIR /app

# Install CPU-only PyTorch directly
RUN pip install --no-cache-dir torch==2.7.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Copy pre-built wheels from builder
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

# Copy only the minimal required files
COPY api /app/api
COPY api/requirements-base.txt ./requirements-base.txt
COPY api/requirements-ml.txt ./requirements-ml.txt

# Expose FastAPI port
EXPOSE 8080

# Run the FastAPI app
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
