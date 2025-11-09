# ===== Minimal Dockerfile for Railway =====
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install minimal system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirement files
COPY api/requirements-base.txt ./requirements-base.txt
COPY api/requirements-ml.txt ./requirements-ml.txt

# Upgrade pip and install all Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    # Install CPU-only PyTorch first
    pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu && \
    # Install the rest of the dependencies
    pip install --no-cache-dir -r requirements-base.txt -r requirements-ml.txt

# Copy project code
COPY api /app/api

# Expose FastAPI port
EXPOSE 8080

# Run FastAPI
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
