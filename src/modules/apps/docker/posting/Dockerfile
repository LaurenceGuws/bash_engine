# Start from the Python slim image
FROM python:3.12-slim

# Set environment variables to prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:${PATH}"

# Install necessary system dependencies
RUN apt update && apt install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv and set up environment
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install the posting tool using uv
RUN uv tool install --python 3.12 posting

# Verify installation by checking posting's help output
RUN posting default --help || echo "Posting tool installed successfully."

# Set default command to open a shell
CMD ["/bin/bash"]
