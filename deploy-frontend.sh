#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deploying frontend...${NC}"

# Check if web_build.tar.gz exists
if [ -f "frontend/web_build.tar.gz" ]; then
    echo -e "${YELLOW}Extracting web build archive...${NC}"
    cd frontend
    tar -xzf web_build.tar.gz
    rm web_build.tar.gz
    cd ..
    echo -e "${GREEN}Web build extracted successfully!${NC}"
else
    # If the web build archive doesn't exist, check if build/web directory exists
    if [ ! -d "frontend/build/web" ]; then
        echo -e "${RED}Flutter web build not found in frontend/build/web directory.${NC}"
        echo -e "${YELLOW}Please build the Flutter web app locally and upload the build files first.${NC}"
        exit 1
    fi
fi

# Deploy only the frontend service
echo -e "${YELLOW}Deploying frontend service with Docker Compose...${NC}"
docker compose -f docker-compose.prod.yml up -d --build frontend

# Check deployment status
if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend deployment failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Frontend deployed successfully!${NC}"
echo -e "${YELLOW}You can access the frontend at:${NC}"
echo -e "${GREEN}http://your-server-ip:8090${NC}"