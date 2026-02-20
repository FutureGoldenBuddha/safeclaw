#!/bin/sh
set -e

echo "Starting squid..."

USER_ID=node
GROUP_ID=node

# Criar diretórios necessários (como root)
mkdir -p /var/cache/squid /var/log/squid /var/run/squid

# CRÍTICO: Dar permissões aos dispositivos de output ANTES de mudar de user
chmod 666 /dev/stdout /dev/stderr 2>/dev/null || true

# Ajustar permissões se necessário (como root)
chown -R $USER_ID:$GROUP_ID /var/log/squid /var/cache/squid /var/run/squid 2>/dev/null || true

# Inicializar cache (como root, mas com diretórios já owned pelo node)
if [ ! -d /var/cache/squid/00 ]; then
    echo "Inicializando cache do Squid como user node..."
    su-exec $USER_ID:$GROUP_ID /usr/sbin/squid -z -f /etc/squid/squid.conf
fi

echo "A baixar para utilizador não root..."
exec su-exec $USER_ID:$GROUP_ID /usr/sbin/squid -f /etc/squid/squid.conf -NYCd 1
