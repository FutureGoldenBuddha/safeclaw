#!/bin/bash
# post-start.sh - Automatic environment setup
#
set -e
#
echo "🚀 Setting up OpenClaw environment..."
#
# 1. Clone OpenClaw if the folder is empty
if [ ! -f "/workspace/.openclaw_install/package.json" ]; then
    echo "📦 Cloning OpenClaw repository..."
    git clone https://github.com/openclaw/openclaw.git /workspace/.openclaw_install
    # mv /openclaw-temp/* /openclaw-temp/.[!.]* /openclaw/ 2>/dev/null || true
    # rm -rf /openclaw-temp
    echo "✅ OpenClaw cloned to /.openclaw_install"
else
    echo "✅ OpenClaw already installed at /.openclaw_install"
fi
#
# 2. Configure git in the OpenClaw repository
cd /workspace/.openclaw_install
if [ ! -f ".git/config" ]; then
    echo "🔧 Configuring git in the OpenClaw repository..."
    git init
    git config user.email "dev@email.com"
    git config user.name "dev"
fi
#
# 2.5 Install git hooks to avoid failures when installing openclaw
# Configure OpenClaw Git hooks
echo "🔗 Configuring OpenClaw Git hooks..."

HOOKS_SOURCE="/workspace/.openclaw_install/git-hooks"
HOOKS_DEST=".git/hooks"

if [ -d "$HOOKS_SOURCE" ]; then
    echo "📁 Contents of git-hooks:"
    ls -la "$HOOKS_SOURCE/"

    # If a precommit file (without hyphen) exists, copy it to pre-commit (with hyphen)
    if [ -f "$HOOKS_SOURCE/pre-commit" ]; then
        echo "📋 Copying pre-commit to $HOOKS_DEST/pre-commit..."
        cp "$HOOKS_SOURCE/pre-commit" "$HOOKS_DEST/pre-commit"
        chmod +x "$HOOKS_DEST/pre-commit"
        echo "✅ pre-commit hook installed."
    fi

    # Copy any other hooks as well
    for hook in "$HOOKS_SOURCE"/*; do
        hook_name=$(basename "$hook")
        # Ignore pre-commit already handled
        if [ "$hook_name" != "pre-commit" ] && [ -f "$hook" ]; then
            echo "📋 Copying $hook_name..."
            cp "$HOOKS_SOURCE/$hook" "$HOOKS_DEST/$hook_name"
            chmod +x "$HOOKS_DEST/$hook_name"
        fi
    done

    # Configure hooksPath to the git-hooks folder (optional, but may be needed)
    # git config core.hooksPath "$HOOKS_SOURCE"
    # echo "✅ Git hooks configured from $HOOKS_SOURCE"
else
    echo "⚠️  git-hooks folder not found."
fi

# 3. Install OpenClaw dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing OpenClaw dependencies..."
    # Configure pnpm to allow scripts (optional, can be done globally)
    pnpm config set ignore-scripts false 2>/dev/null || true
    pnpm install
    # If there are blocked scripts, try to approve them automatically
    echo "🛠️  Approving blocked build scripts..."
    pnpm approve-builds --all 2>/dev/null || true
    echo "✅ Dependencies installed"
fi
#
# 4. Build OpenClaw
if [ ! -d "dist" ]; then
    echo "🔨 Building OpenClaw..."
    pnpm ui:build
    pnpm build
    echo "✅ OpenClaw built"
fi
#
# 5. Create workspace directory structure
# mkdir -p /openclaw_workspace/{skills,files,logs,config}
# #
# 6. Permissions
# chown -R developer:developer /openclaw_workspace 2>/dev/null || true
#
echo ""
echo "✨ Environment successfully configured!"
echo ""
echo "📁 Directory structure:"
echo "   /openclaw           - OpenClaw source code"
echo "   /openclaw_workspace - OpenClaw workspace and data"
echo "   /projetos           - Your personal projects"
echo ""
echo "🚀 Useful commands:"
echo "   cd /openclaw && pnpm gateway:watch"
echo "   cd /projetos          # To work on your personal projects"
echo ""
#