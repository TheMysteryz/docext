FROM pytorch/pytorch:2.1.0-cuda11.8-cudnn8-devel AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV GRADIO_SERVER_PORT=7860
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    software-properties-common \
    poppler-utils \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3.11-distutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure Python 3.11 is default
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python

# Install uv for faster package management (as recommended in README)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /app

# Create virtual environment with Python 3.11 (following README instructions)
RUN /root/.local/bin/uv venv --python=3.11 .venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy requirements and setup files
COPY requirements.txt setup.py README.md MANIFEST.in /app/
COPY docext /app/docext

# Install dependencies using uv (as per README)
RUN /root/.local/bin/uv pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /root/.local/bin/uv pip install --no-cache-dir -r requirements.txt

# Install docext package
RUN /root/.local/bin/uv pip install --no-cache-dir -e .

# Expose the default port
EXPOSE 7860
EXPOSE 8000

# Set default command to run docext with recommended model
ENTRYPOINT ["/app/.venv/bin/python", "-m", "docext.app.app"]
CMD ["--model_name", "hosted_vllm/nanonets/Nanonets-OCR-s", "--no-share", "--vlm_server_host", "0.0.0.0", "--vlm_server_port", "8000"]
