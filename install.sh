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

if [ -d "$REPO_DIR" ] && [ ! -d ".git" ]; then
    echo -e "${BLUE}📂 Moving into existing $REPO_DIR directory...${NC}"
    cd "$REPO_DIR"
fi

if [ -d ".git" ]; then
    echo -e "${BLUE}🔄 Checking for updates...${NC}"
    git pull
else
    if [ ! -f "compose.yml" ]; then
        echo -e "${BLUE}📂 Cloning Forest Cloud repository...${NC}"
        git clone "$REPO_URL" "$REPO_DIR"
        cd "$REPO_DIR"
    else
        echo -e "${BLUE}ℹ️ Already in Forest Cloud directory, but Git metadata is missing.${NC}"
        echo -e "To force an update, please delete this directory and run the script again."
    fi
fi

# 2. Initialize and update submodules
echo -e "${BLUE}📦 Initializing git submodules...${NC}"
if [ -d ".git" ]; then
    git submodule update --init --recursive
    
    # 3. Detach from Git (Remove repository metadata)
    if [[ "$*" == *"--keep-git"* ]]; then
        echo -e "${BLUE}ℹ️ Keeping Git metadata as requested.${NC}"
    else
        echo -e "${BLUE}🧹 Removing Git metadata to create a clean installation...${NC}"
        # Remove all .git directories and files recursively (including submodules)
        find . -name ".git" -exec rm -rf {} +
        # Remove .gitmodules and .github directories
        find . -name ".gitmodules" -delete
        find . -name ".github" -exec rm -rf {} +
        echo -e "✅ Git metadata removed."
    fi
else
    echo "⚠️  Not a git repository, skipping submodule update and detachment."
fi

# 4. Create data directories and set permissions
echo -e "${BLUE}📂 Creating data directories...${NC}"
mkdir -p data/db data/uploads
# Ensure directories are writable by the Docker container
chmod -R 777 data
echo -e "✅ Data directories prepared."

# 5. Create environment files
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
    # Ensure HOST is 0.0.0.0 for Docker even if file existed
    if grep -q "HOST=localhost" server/.env; then
        echo "Updating HOST to 0.0.0.0 in server/.env for Docker compatibility..."
        sed -i '' "s/HOST=localhost/HOST=0.0.0.0/" server/.env 2>/dev/null || \
        sed -i "s/HOST=localhost/HOST=0.0.0.0/" server/.env
    fi
fi

if [ ! -f "client/.env" ]; then
    echo "Creating client/.env from template..."
    cp client/.env.example client/.env
else
    echo "✅ client/.env already exists."
fi

# 6. Start Docker Compose
echo -e "${BLUE}🐳 Starting Forest Cloud unified stack...${NC}"
PROJECT_NAME="forest-cloud"
if command -v docker-compose &> /dev/null; then
    docker-compose -p "$PROJECT_NAME" up -d --build
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    docker compose -p "$PROJECT_NAME" up -d --build
else
    echo "❌ Error: Docker Compose is not installed."
    exit 1
fi

echo -e "${GREEN}✨ Installation complete!${NC}"
echo -e "Forest Cloud is now running."
echo -e "Frontend: ${BLUE}http://localhost:7180${NC}"
echo -e "Backend API: ${BLUE}http://localhost:9180/api${NC}"
