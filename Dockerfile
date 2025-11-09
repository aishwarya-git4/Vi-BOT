FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Prevent Python from writing pyc files and buffer logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install essential system deps (tiny set to keep image small)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirement files first (for caching)
COPY api/requirements-base.txt /app/api/requirements-base.txt
COPY api/requirements-ml.txt /app/api/requirements-ml.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /app/api/requirements-base.txt && \
    pip install --no-cache-dir -r /app/api/requirements-ml.txt -f https://download.pytorch.org/whl/cpu/torch_stable.html

# Copy entire project into container
COPY . /app

# Change working directory to where main.py lives
WORKDIR /app/api

# Expose the FastAPI port
EXPOSE 8080

# Run the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
