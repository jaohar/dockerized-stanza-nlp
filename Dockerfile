# Use Python 3.11 slim base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app/stanza

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    git \
    vim \
    libev-dev \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip install --upgrade pip setuptools wheel

# Install Stanza and Python dependencies
RUN git clone https://github.com/stanfordnlp/stanza.git /tmp/stanza && \
    pip install -e /tmp/stanza Flask bjoern gunicorn

# Copy your application code into the container
COPY . /app/stanza

# Pre-download English model into container so it starts immediately
RUN python -c "import stanza; stanza.download('en', model_dir='/app/stanza_resources')"

# Expose the port your API will run on
EXPOSE 5000

# Environment variable so your script uses the pre-downloaded models
ENV STANZA_RESOURCES_DIR=/app/stanza_resources

# Start the service using Gunicorn
CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "--timeout", "0", "-k", "sync", "script:app"]
