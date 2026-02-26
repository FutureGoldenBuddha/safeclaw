FROM node:22-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git openssh-client \
    sqlite3 \
    curl wget ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# (create and) change to .openclaw directory

# Install pnpm globally
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
# RUN mkdir -p /workspace/.openclaw_install /workspace/projetos \
#     && chown -R 1000:1000 /workspace/.openclaw_install /workspace/projetos

# WORKDIR /openclaw
EXPOSE 18789 18790

# Copia ou cria o entrypoint.sh (se ainda não tiver feito)
# COPY entrypoint.sh /home/node/entrypoint.sh

# RUN chmod 755 /home/node/entrypoint.sh && \
#     chown 1000:1000 /home/node/entrypoint.sh

# 1. Criar pastas de sistema e de projeto
RUN mkdir -p /home/install /workspace/.openclaw_install /workspace/my_projects \
    && chown -R 1000:1000 /workspace

# 2. Copiar o entrypoint para a pasta de instalação
COPY --chown=1000:1000 entrypoint.sh /workspace/.openclaw_install/entrypoint.sh
RUN chmod +x /workspace/.openclaw_install/entrypoint.sh
# = config
COPY --chown=1000:1000 ./config/openclaw.json /workspace/.openclaw_install/openclaw.json

# 3. Definir o ambiente de trabalho na pasta de projeto
# WORKDIR /workspace

# Muda para usuário não-root no entrypoint...
# USER 1000:1000

# Define o script como o entrypoint
ENTRYPOINT ["/workspace/.openclaw_install/entrypoint.sh"]
CMD ["sleep", "infinity"]
