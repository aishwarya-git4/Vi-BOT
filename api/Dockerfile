# Use a stable Python version (avoid 3.13 for now)
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency file first
COPY requirements.txt .

# Install dependencies efficiently
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of your source code
COPY . .

# Expose FastAPI port
EXPOSE 8080

# Run the FastAPI app using uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
