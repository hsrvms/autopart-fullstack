#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables
SERVER_IP="your-server-ip"  # Replace with your actual server IP
SERVER_USER="ubuntu"        # Replace with your actual server username
REMOTE_PATH="/home/ubuntu/repos/autoparts/frontend"

echo -e "${YELLOW}Building Flutter web app...${NC}"

# Go to the frontend directory
cd frontend

# Make sure Flutter is installed and in PATH
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter not found. Make sure Flutter is installed and in your PATH.${NC}"
    exit 1
fi

# Build Flutter web app
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.autoparts.com \
  --dart-define=API_URL=https://api.autoparts.com/api \
  --dart-define=FLUTTER_DEV=false

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Flutter build failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Flutter web app built successfully!${NC}"

# Create a tarball of the build
echo -e "${YELLOW}Creating tarball of build files...${NC}"
cd build
tar -czf ../web_build.tar.gz web/
cd ..

echo -e "${YELLOW}Uploading build files to server...${NC}"
echo -e "${YELLOW}Run this command to upload the build files to your server:${NC}"
echo -e "${GREEN}scp frontend/web_build.tar.gz ${SERVER_USER}@${SERVER_IP}:${REMOTE_PATH}/${NC}"

echo -e "${YELLOW}After uploading, run these commands on the server:${NC}"
echo -e "${GREEN}cd ${REMOTE_PATH} && tar -xzf web_build.tar.gz && rm web_build.tar.gz${NC}"
echo -e "${GREEN}cd /home/ubuntu/repos/autoparts && docker compose -f docker-compose.prod.yml up -d --build frontend${NC}"