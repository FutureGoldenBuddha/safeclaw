#!/bin/bash

# Git add all
git add .

# Perguntar mensagem
echo "Write commit message please:"
read commit_message

# Commit
git commit -m "$commit_message"

# Push
git push origin main