# Use a stable Python version (3.11.8 fixes your build issues)
FROM python:3.11.8-slim

# Prevents Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system-level dependencies for scientific + NLP packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    libatlas-base-dev \
    liblapack-dev \
    libblas-dev \
    libffi-dev \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies separately for Docker layer caching
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy your app files into the image
COPY . .

# Expose your app port (Render uses PORT env variable)
EXPOSE 10000

# Default command to start your app

CMD ["bash", "start.sh"]