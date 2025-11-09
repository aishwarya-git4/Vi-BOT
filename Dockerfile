FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Prevent Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy and install base dependencies first (for caching)
COPY api/requirements-base.txt ./api/requirements-base.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r ./api/requirements-base.txt

# Copy and install heavy ML dependencies with pre-built wheels
COPY api/requirements-ml.txt ./api/requirements-ml.txt
RUN pip install --no-cache-dir -r ./api/requirements-ml.txt -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Copy the rest of your code
COPY . .

# Expose FastAPI port
EXPOSE 8080

# Run FastAPI with uvicorn
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
