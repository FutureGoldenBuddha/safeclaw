FROM node:22-bookworm-slim

# Instalar dependências de sistema
RUN apt-get update && apt-get install -y \
    git openssh-client \
    sqlite3 \
    curl wget ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# Instalar pnpm globalmente
RUN npm install -g pnpm

# Verificar se o grupo 1000 já existe e usar nome apropriado
RUN echo "a criar user non root = 1000"
RUN if getent group 1000 > /dev/null; then \
        EXISTING_GROUP=$(getent group 1000 | cut -d: -f1); \
        echo "Grupo GID 1000 já existe: $EXISTING_GROUP"; \
    else \
        groupadd --gid 1000 node; \
    fi

# Verificar se usuário 1000 já existe
RUN if getent passwd 1000 > /dev/null; then \
        EXISTING_USER=$(getent passwd 1000 | cut -d: -f1); \
        echo "Usuário UID 1000 já existe: $EXISTING_USER"; \
    else \
        useradd --uid 1000 --gid 1000 -m node; \
    fi

# # Criar estrutura de diretórios
# RUN echo "a criar diretorios de instalacao e projetos"
# RUN mkdir -p /home/projeto/openclaw_install /home/projeto/projetos \
#     && chown -R 1000:1000 /home/projeto/openclaw_install /home/projeto/projetos

# WORKDIR /openclaw
EXPOSE 18789 18790

# Copia ou cria o entrypoint.sh (se ainda não tiver feito)
# COPY entrypoint.sh /home/node/entrypoint.sh

# RUN chmod 755 /home/node/entrypoint.sh && \
#     chown 1000:1000 /home/node/entrypoint.sh

# 1. Criar pastas de sistema e de projeto
RUN mkdir -p /home/install /home/projeto/openclaw_install /home/projeto/projetos \
    && chown -R 1000:1000 /home/install /home/projeto

# 2. Copiar o entrypoint para a pasta de instalação
COPY --chown=1000:1000 entrypoint.sh /home/install/entrypoint.sh
RUN chmod +x /home/install/entrypoint.sh

# 3. Definir o ambiente de trabalho na pasta de projeto
# WORKDIR /home/projeto

# Muda para usuário não-root no entrypoint...
# USER 1000:1000

# Define o script como o entrypoint
ENTRYPOINT ["/home/install/entrypoint.sh"]
CMD ["sleep", "infinity"]
