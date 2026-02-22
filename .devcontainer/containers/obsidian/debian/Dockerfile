# https://github.com/natesena/obsidian-filesystem-mcp
FROM node:20-slim

# 1. Install Git (Mandatory for your hooks and OpenClaw audit)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# 2. Install MCP Filesystem server and the Supergateway wrapper
RUN npm install -g \
    @modelcontextprotocol/server-filesystem \
    supergateway

WORKDIR /app

# 3. Copy your audit hook into the image
# (Assumes you have a ./hooks/pre-commit file locally)
COPY ./hooks/pre-commit /app/pre-commit
COPY ./hooks/commit-msg /app/commit-msg
RUN chmod +x /app/pre-commit
RUN chmod +x /app/commit-msg 

# 4. Create the Entrypoint Script
# This script injects the hook into your vault BEFORE starting the gateway
RUN echo '#!/bin/bash\n\
# Ensure Git treats the mounted volume as safe\n\
git config --global --add safe.directory /vault\n\
\n\
# Inject the Pre-commit Hook into the vault filesystem\n\
mkdir -p /vault/.git/hooks\n\
cp /app/pre-commit /vault/.git/hooks/pre-commit\n\
cp /app/commit-msg /vault/.git/hooks/commit-msg\n\
chmod +x /vault/.git/hooks/pre-commit\n\
chmod +x /vault/.git/hooks/commit-msg\n\
\n\
echo "🛡️ Audit Guard Injected into /vault"\n\
echo "🚀 Starting Supergateway on port 3101..."\n\
\n\
# Execute Supergateway\n\
exec supergateway \
    --stdio "mcp-server-filesystem /vault" \
    --outputTransport streamableHttp \
    --streamableHttpPath "/mcp" \
    --port 3101 \
    --cors' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# The gateway will listen on 3101
EXPOSE 3101

ENTRYPOINT ["/app/entrypoint.sh"]