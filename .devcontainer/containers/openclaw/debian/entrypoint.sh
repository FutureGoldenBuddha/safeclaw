#!/bin/sh
set -e

echo "debug user atual"

echo $(whoami)

echo $(id)

echo "permissoes da pasta /home/projeto, onde os diretorios vao ser criados.."

ls -ld /home/projeto

echo "A criar diretórios de instalação e projetos..."

# Usa o ID que passamos por variável, ou 1000 como padrão
echo "user do host"
USER_ID=${PUID:-1000}
GROUP_ID=${PGID:-1000}
echo $(USER_ID)
echo $(GROUP_ID)

# corrige permissoes do workspace pq pelos vistos o docker-compose.yml fode tudo
chown -R $USER_ID:$GROUP_ID /home/projeto

# Cria os diretórios caso não existam
mkdir -p /home/projeto/openclaw_install /home/projeto/projetos

# Ajusta as permissões para o utilizador (UID 1000)
# Nota: Se o volume for montado como root, isto garante que o app user consegue escrever
chown -R $USER_ID:$GROUP_ID /home/projeto/openclaw_install /home/projeto/projetos

echo "Diretórios prontos. A iniciar aplicação..."

# 3. EXECUTA O COMANDO COMO USER 1000 (Usando o comando 'su' ou 'runuser')
echo "Permissões ajustadas. A baixar para utilizador nao root..."
exec setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups "$@"

# Executa o comando principal do Dockerfile (o CMD)
# exec "$@"