FROM node:22-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git openssh-client \
    sqlite3 \
    curl wget ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

# Check if group 1000 already exists and use appropriate name
RUN echo "Creating non‑root user with UID/GID 1000"
RUN if getent group 1000 > /dev/null; then \
        EXISTING_GROUP=$(getent group 1000 | cut -d: -f1); \
        echo "Group GID 1000 already exists: $EXISTING_GROUP"; \
    else \
        groupadd --gid 1000 node; \
    fi

# Check if user 1000 already exists
RUN if getent passwd 1000 > /dev/null; then \
        EXISTING_USER=$(getent passwd 1000 | cut -d: -f1); \
        echo "User UID 1000 already exists: $EXISTING_USER"; \
    else \
        useradd --uid 1000 --gid 1000 -m node; \
    fi

# Create system and project directories
RUN mkdir -p /temp /workspace/.openclaw_install /workspace/my_projects \
    && chown -R 1000:1000 /workspace

# Cpy README.md
COPY --chown=1000:1000 ../README.md /workspace


# Copy entrypoint script to a temp folder
COPY --chown=1000:1000 entrypoint.sh /temp/entrypoint.sh
RUN chmod +x /temp/entrypoint.sh

# Copy post-compose script to a temp folder
COPY --chown=1000:1000 post-compose.sh /temp/post-compose.sh
RUN chmod +x /temp/post-compose.sh

# Copy configuration file to a temp folder, and to the correct place @ post-compose
COPY --chown=1000:1000 ./config/openclaw.json /temp/openclaw.json

# Expose OpenClaw ports
EXPOSE 18789 18790

# Set the entrypoint script
ENTRYPOINT ["/temp/entrypoint.sh"]

# Default command (keeps container alive)
CMD ["sleep", "infinity"]