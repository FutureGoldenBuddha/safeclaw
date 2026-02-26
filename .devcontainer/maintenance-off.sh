#!/bin/bash
set -e  # Stop if any command fails

# Automatically find the folder containing docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PROXY_MODE=RESTRICTED
export HTTP_PROXY=http://openclaw_egress_proxy:3128
export HTTPS_PROXY=http://openclaw_egress_proxy:3128

echo "🔒 RESTORING SECURE MODE"
echo "1. Stopping the open proxy container..."
docker-compose down open_proxy

echo "2. Reconfiguring the agent to use the restrictive proxy..."
docker-compose exec -e PROXY_MODE -e HTTP_PROXY -e HTTPS_PROXY openclaw /bin/sh -c 'echo "Variables updated. Now in SECURE (restrictive) mode."'

echo "✅ Done! The open proxy has been stopped and the agent is back to using the restrictive proxy."