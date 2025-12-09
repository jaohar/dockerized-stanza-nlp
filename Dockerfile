FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    git \
    libev-dev \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Copy your code first
COPY . /app

# Install Python dependencies
RUN pip install -e ./stanza
RUN pip install Flask bjoern gunicorn

# Pre-download English model
RUN python -c "import stanza; stanza.download('en', model_dir='/app/stanza_resources')"

# Environment variable so script uses pre-downloaded models
ENV STANZA_RESOURCES_DIR=/app/stanza_resources

# Expose API port
EXPOSE 5000

# Run Gunicorn
CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "--timeout", "0", "-k", "sync", "script:app"]
