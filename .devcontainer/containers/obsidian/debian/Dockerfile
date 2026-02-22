# Base Image: Python 3.12 on Bookworm Slim
FROM python:3.12-slim-bookworm

WORKDIR /app

# 1. Install System Dependencies: Git is vital for your hooks
RUN apt-get update && apt-get install -y \
    git \
    sqlite3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone the repository
RUN git clone https://github.com/that0n3guy/ObsidianPilot.git .

# Set up Python environment as per docs
RUN python -m venv venv

ENV PATH="/app/venv/bin:$PATH"

# 3. Install Python dependencies
# Ensure we are using the venv for the pip install
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# COPY THE HOOKS FROM YOUR LOCAL MACHINE TO THE IMAGE
# We store them in a temporary folder to move them to the vault on startup
COPY ./hooks/pre-commit /app/hooks/pre-commit
COPY ./hooks/commit-msg /app/hooks/commit-msg
RUN chmod +x /app/hooks/pre-commit
RUN chmod +x /app/hooks/commit-msg 

# Environment Variables
ENV OBSIDIAN_LOG_LEVEL=DEBUG
ENV OBSIDIAN_VAULT_PATH=/vault
ENV PYTHONUNBUFFERED=1

# Entrypoint script to ensure hooks are installed in the mounted vault
RUN echo '#!/bin/bash\n\
echo "a confirmar diretorio atual"\n\
ls\n\
mkdir -p /vault/.git/hooks\n\
cp /app/hooks/pre-commit /vault/.git/hooks/pre-commit\n\
cp /app/hooks/commit-msg /vault/.git/hooks/commit-msg\n\
chmod +x /vault/.git/hooks/pre-commit\n\
chmod +x /vault/.git/hooks/commit-msg\n\
echo "✅ Git Hooks injected. Starting ObsidianPilot..."\n\
# Git might complain about ownership\n\
git config --global --add safe.directory /vault\n\
python -m obsidianpilot.server' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]