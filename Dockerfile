# Start from a lightweight but compatible base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install only minimal system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements (for better caching)
COPY api/requirements-base.txt /app/api/requirements-base.txt
COPY api/requirements-ml.txt /app/api/requirements-ml.txt

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /app/api/requirements-base.txt && \
    pip install --no-cache-dir -r /app/api/requirements-ml.txt \
        -f https://download.pytorch.org/whl/cpu/torch_stable.html && \
    # cleanup unnecessary build tools and caches
    apt-get purge -y gcc && apt-get autoremove -y && \
    rm -rf /root/.cache /var/lib/apt/lists/*

# Copy project
COPY . /app

# Move to backend folder
WORKDIR /app/emily/api

# Expose FastAPI port
EXPOSE 8080

# Run backend
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
