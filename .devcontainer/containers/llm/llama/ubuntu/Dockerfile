# 1. Use the official llama.cpp image pre‑compiled for CUDA
# This image is based on Ubuntu and includes all necessary libraries.
FROM ghcr.io/ggml-org/llama.cpp:server-cuda

# Switch back to root to install administrative utilities
USER root

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# 2. Install only essential tools: git (for hooks) and gosu (for user management)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    sudo \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# With CUDA, we do not need to manually map the 'render' group (992)
# as we did for Intel/Vulkan. The NVIDIA driver handles this.

# Ensure the 'ubuntu' user exists (UID 1000); the official image usually has it.
RUN id -u ubuntu >/dev/null 2>&1 || useradd -m -u 1000 ubuntu

# Copy the custom entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the server port
EXPOSE 8080/tcp

# Set the custom script as the entrypoint
ENTRYPOINT ["/entrypoint.sh"]