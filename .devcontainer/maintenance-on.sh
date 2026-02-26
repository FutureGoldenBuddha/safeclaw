#!/bin/bash
set -e  # Stop on any error

# Automatically find the folder containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export LD_LIBRARY_PATH="/app:$LD_LIBRARY_PATH"
export PROXY_MODE=OPEN
export HTTP_PROXY=http://open_proxy_temp:3128
export HTTPS_PROXY=http://open_proxy_temp:3128

echo "🔓 STARTING MAINTENANCE MODE"
echo "1. Starting the open proxy container..."
docker-compose --profile maintenance up -d --build open_proxy

echo "2. Reconfiguring the agent to use the open proxy..."
docker-compose exec -e PROXY_MODE -e HTTP_PROXY -e HTTPS_PROXY openclaw /bin/sh -c 'echo "Variables updated. Now in OPEN mode."'

echo "✅ Done! The agent now has open internet access via open_proxy_temp."
echo "   Run your commands (e.g., docker exec openclaw pnpm install)"