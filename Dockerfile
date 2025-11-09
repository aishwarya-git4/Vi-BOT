FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies
COPY api/requirements-base.txt ./api/requirements-base.txt
COPY api/requirements-ml.txt ./api/requirements-ml.txt

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r ./api/requirements-base.txt && \
    pip install --no-cache-dir -r ./api/requirements-ml.txt -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Copy entire project
COPY . .

# Set working directory to the API folder
WORKDIR /app/emily/api

# Expose FastAPI port
EXPOSE 8080

# Run FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
