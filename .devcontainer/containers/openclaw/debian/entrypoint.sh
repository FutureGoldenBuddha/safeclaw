#!/bin/sh
set -e

echo "debug current user"

echo $(whoami)

echo $(id)

echo "permissions of the /workspace folder, where directories will be created..."

ls -ld /workspace

echo "Creating installation and projects directories..."

# Uses the ID passed via variable, or defaults to 1000
echo "host user"
USER_ID=${PUID:-1000}
GROUP_ID=${PGID:-1000}
echo $(USER_ID)
echo $(GROUP_ID)

# Fixes workspace permissions because apparently docker-compose.yml messes everything up
chown -R $USER_ID:$GROUP_ID /workspace

# Creates the directories if they don't exist
mkdir -p /workspace/.openclaw_install /workspace/my_projects

# Adjusts permissions for the user (UID 1000)
# Note: If the volume is mounted as root, this ensures the app user can write
chown -R $USER_ID:$GROUP_ID /workspace/.openclaw_install /workspace/my_projects

echo "Directories ready. Starting application..."

# 3. EXECUTES THE COMMAND AS USER 1000 (Using 'su' or 'runuser')
echo "Permissions adjusted. Dropping to non-root user..."
exec setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups "$@"

# Executes the main command from the Dockerfile (the CMD)
# exec "$@"