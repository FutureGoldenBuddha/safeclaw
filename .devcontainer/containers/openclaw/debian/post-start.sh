#!/bin/bash
# post-start.sh - Configuração automática do ambiente
#
set -e
#
echo "🚀 Configurando ambiente OpenClaw..."
#
# 1. Clonar OpenClaw se a pasta estiver vazia
if [ ! -f "/home/projeto/openclaw_install/package.json" ]; then
    echo "📦 Clonando repositório OpenClaw..."
    git clone https://github.com/openclaw/openclaw.git /home/projeto/openclaw_install
    # mv /openclaw-temp/* /openclaw-temp/.[!.]* /openclaw/ 2>/dev/null || true
    # rm -rf /openclaw-temp
    echo "✅ OpenClaw clonado para /openclaw_install"
else
    echo "✅ OpenClaw já instalado em /openclaw_install"
fi
#
# 2. Configurar git no repositório OpenClaw
cd /home/projeto/openclaw_install
if [ ! -f ".git/config" ]; then
    echo "🔧 Configurando git no repositório OpenClaw..."
    git init
    git config user.email "dev@email.com"
    git config user.name "dev"
fi
#
# 2.5 Instala git hooks para poder instalar openclaw sem falhas
# Configurar Git hooks do OpenClaw
echo "🔗 Configurando Git hooks do OpenClaw..."

HOOKS_SOURCE="/home/projeto/openclaw_install/git-hooks"
HOOKS_DEST=".git/hooks"

if [ -d "$HOOKS_SOURCE" ]; then
    echo "📁 Conteúdo de git-hooks:"
    ls -la "$HOOKS_SOURCE/"

    # Se existir um ficheiro precommit (sem hífen), copiar para pre-commit (com hífen)
    if [ -f "$HOOKS_SOURCE/pre-commit" ]; then
        echo "📋 Copiando pre-commit para $HOOKS_DEST/pre-commit..."
        cp "$HOOKS_SOURCE/pre-commit" "$HOOKS_DEST/pre-commit"
        chmod +x "$HOOKS_DEST/pre-commit"
        echo "✅ Hook pre-commit instalado."
    fi

    # Se existirem outros hooks, copiá-los também
    for hook in "$HOOKS_SOURCE"/*; do
        hook_name=$(basename "$hook")
        # Ignorar precommit já tratado
        if [ "$hook_name" != "pre-commit" ] && [ -f "$hook" ]; then
            echo "📋 Copiando $hook_name..."
            cp "$HOOKS_SOURCE/$hook" "$HOOKS_DEST/$hook_name"
            chmod +x "$HOOKS_DEST/$hook_name"
        fi
    done

    # Configurar o hooksPath para a pasta git-hooks (opcional, mas pode ser necessário)
    # git config core.hooksPath "$HOOKS_SOURCE"
    # echo "✅ Git hooks configurados a partir de $HOOKS_SOURCE"
else
    echo "⚠️  Pasta git-hooks não encontrada."
fi

# 3. Instalar dependências do OpenClaw
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependências do OpenClaw..."
    # Configurar pnpm para permitir scripts (opcional, pode ser feito globalmente)
    pnpm config set ignore-scripts false 2>/dev/null || true
    pnpm install
    # Se houver scripts bloqueados, tente aprová-los automaticamente
    echo "🛠️  Aprovando scripts de build bloqueados..."
    pnpm approve-builds --all 2>/dev/null || true
    echo "✅ Dependências instaladas"
fi
#
# 4. Construir OpenClaw
if [ ! -d "dist" ]; then
    echo "🔨 Construindo OpenClaw..."
    pnpm ui:build
    pnpm build
    echo "✅ OpenClaw construído"
fi
#
# 5. Configuração inicial do OpenClaw
if [ ! -f "/home/projeto/openclaw_install/config/openclaw.json" ]; then
    echo "⚙️ Criando configuração inicial do OpenClaw..."
    
    mkdir -p /home/projeto/openclaw_install/config
    cp /home/projeto/.devcontainer/containers/openclaw/debian/openclaw.json /home/projeto/openclaw_install/config

    echo "✅ Configuração criada em /home/projeto/openclaw_install/config/openclaw.json"
    echo "🔑 Token: ${OPENCLAW_GATEWAY_TOKEN}"
fi
#
# 6. Criar estrutura de diretórios do workspace
# mkdir -p /openclaw_workspace/{skills,files,logs,config}
# #
# # 7. Permissões
# chown -R developer:developer /openclaw_workspace 2>/dev/null || true
#
echo ""
echo "✨ Ambiente configurado com sucesso!"
echo ""
echo "📁 Estrutura de diretórios:"
echo "   /openclaw           - Código fonte do OpenClaw"
echo "   /openclaw_workspace - Workspace e dados do OpenClaw"
echo "   /projetos           - Teus projetos pessoais"
echo ""
echo "🚀 Comandos úteis:"
echo "   cd /openclaw && pnpm gateway:watch"
echo "   cd /projetos          # Para trabalhar nos teus projetos"
echo ""
#


