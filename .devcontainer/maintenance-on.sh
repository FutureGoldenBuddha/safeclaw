#!/bin/bash
set -e  # Para se qualquer comando falhar

# Encontra automaticamente a pasta do docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export LD_LIBRARY_PATH="/app:$LD_LIBRARY_PATH"
export PROXY_MODE=OPEN
export HTTP_PROXY=http://open_proxy_temp:3128
export HTTPS_PROXY=http://open_proxy_temp:3128

echo "🔓 INICIANDO MODO DE MANUTENÇÃO"
echo "1. Iniciando o container do proxy aberto..."
docker-compose --profile maintenance up -d --build open_proxy_temp

echo "2. Reconfigurando o agente para usar o proxy aberto..."
docker-compose exec -e PROXY_MODE -e HTTP_PROXY -e HTTPS_PROXY openclaw /bin/sh -c 'echo "Variáveis atualizadas. Agora em modo ABERTO."'

echo "✅ Pronto! O agente agora tem acesso à internet aberta via open_proxy_temp."
echo "   Execute seus comandos (ex: docker exec openclaw pnpm install)"
