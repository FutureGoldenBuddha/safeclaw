#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PROXY_MODE=RESTRICTED
export HTTP_PROXY=http://openclaw_egress_proxy:3128
export HTTPS_PROXY=http://openclaw_egress_proxy:3128

echo "🔒 RESTAURANDO MODO SEGURO"
echo "1. Parando o container do proxy aberto..."
docker-compose --profile maintenance down open_proxy_temp

echo "2. Reconfigurando o agente para usar o proxy restritivo..."
docker-compose exec -e PROXY_MODE -e HTTP_PROXY -e HTTPS_PROXY openclaw /bin/sh -c 'echo "Variáveis atualizadas. Agora em modo SEGURO (restritivo)."'

echo "✅ Pronto! O proxy aberto foi parado e o agente voltou ao proxy restritivo."
