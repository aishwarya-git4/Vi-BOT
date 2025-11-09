# Use a smaller base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install minimal build tools only when needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements first (for caching)
COPY api/requirements-base.txt /app/api/requirements-base.txt
COPY api/requirements-ml.txt /app/api/requirements-ml.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /app/api/requirements-base.txt && \
    pip install --no-cache-dir -r /app/api/requirements-ml.txt \
        -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Remove build tools and clean caches to reduce image size
RUN apt-get purge -y gcc git curl && apt-get autoremove -y && \
    rm -rf /root/.cache /var/lib/apt/lists/*

# Copy only what’s needed
COPY api /app/api
COPY Dockerfile /app/Dockerfile
COPY .dockerignore /app/.dockerignore

# Expose FastAPI port
EXPOSE 8080

# Run backend
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
