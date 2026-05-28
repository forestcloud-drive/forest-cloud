#!/bin/bash

# Forest Cloud - Installation Script
# This script automates the setup of Forest Cloud.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌲 Starting Forest Cloud Installation...${NC}"

# 1. Check if we are in the forest-cloud directory, if not, clone it
REPO_URL="https://github.com/forestcloud-drive/forest-cloud.git"
REPO_DIR="forest-cloud"

if [ ! -f "compose.yml" ]; then
    echo -e "${BLUE}📂 Cloning Forest Cloud repository...${NC}"
    if [ -d "$REPO_DIR" ]; then
        echo "Found existing $REPO_DIR directory, moving into it..."
        cd "$REPO_DIR"
    else
        git clone "$REPO_URL" "$REPO_DIR"
        cd "$REPO_DIR"
    fi
fi

# 2. Initialize and update submodules
echo -e "${BLUE}📦 Initializing git submodules...${NC}"
if [ -d ".git" ]; then
    git submodule update --init --recursive
else
    echo "⚠️  Not a git repository, skipping submodule update."
fi

# 2. Create environment files
echo -e "${BLUE}🔑 Setting up environment variables...${NC}"

if [ ! -f "server/.env" ]; then
    echo "Creating server/.env from template..."
    cp server/.env.example server/.env
    # Generate a random JWT secret if it's still the default
    RANDOM_SECRET=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 || echo "default_secret_$(date +%s)")
    sed -i '' "s/JWT_SECRET=replace_me_with_a_random_string/JWT_SECRET=${RANDOM_SECRET}/" server/.env 2>/dev/null || \
    sed -i "s/JWT_SECRET=replace_me_with_a_random_string/JWT_SECRET=${RANDOM_SECRET}/" server/.env
else
    echo "✅ server/.env already exists."
fi

if [ ! -f "client/.env" ]; then
    echo "Creating client/.env from template..."
    cp client/.env.example client/.env
else
    echo "✅ client/.env already exists."
fi

# 3. Start Docker Compose
echo -e "${BLUE}🐳 Starting Forest Cloud with Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
    docker-compose up -d --build
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    docker compose up -d --build
else
    echo "❌ Error: Docker Compose is not installed."
    exit 1
fi

echo -e "${GREEN}✨ Installation complete!${NC}"
echo -e "Forest Cloud is now running."
echo -e "Frontend: ${BLUE}http://localhost:7180${NC}"
echo -e "Backend API: ${BLUE}http://localhost:9180/api${NC}"
