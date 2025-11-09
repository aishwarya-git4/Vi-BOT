FROM python:3.11-slim

WORKDIR /app/EMILY/api

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirement files
COPY api/requirements-base.txt ./requirements-base.txt
COPY api/requirements-ml.txt ./requirements-ml.txt

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install torch with CPU wheels explicitly
RUN pip install --no-cache-dir torch==2.7.1 --index-url https://download.pytorch.org/whl/cpu

# Install rest of dependencies
RUN pip install --no-cache-dir -r requirements-base.txt -r requirements-ml.txt

# Copy rest of code
COPY . .

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
