#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting production deployment...${NC}"

# The .env file should already have the production settings

# Deploy backend service
echo -e "${YELLOW}Deploying backend service with Docker Compose...${NC}"
docker compose -f docker-compose.prod.yml up -d --build backend

# Check deployment status
if [ $? -ne 0 ]; then
    echo -e "${RED}Backend deployment failed.${NC}"
    exit 1
fi

# Check if frontend/build/web directory exists
if [ -d "frontend/build/web" ]; then
    # Deploy frontend service
    echo -e "${YELLOW}Deploying frontend service with Docker Compose...${NC}"
    docker compose -f docker-compose.prod.yml up -d --build frontend
    
    # Check deployment status
    if [ $? -ne 0 ]; then
        echo -e "${RED}Frontend deployment failed.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${YELLOW}You can access the application at:${NC}"
    echo -e "${GREEN}Frontend: http://your-server-ip:8090${NC}"
    echo -e "${GREEN}Backend API: http://your-server-ip:${SERVER_PORT}${NC}"
else
    echo -e "${GREEN}Backend deployed successfully!${NC}"
    echo -e "${YELLOW}Flutter web app build not found. Only the backend was deployed.${NC}"
    echo -e "${YELLOW}To deploy the frontend, build the Flutter web app locally and upload the build files using:${NC}"
    echo -e "${GREEN}./deploy-flutter-web.sh${NC}"
    echo -e "${YELLOW}Then on the server, run:${NC}"
    echo -e "${GREEN}./deploy-frontend.sh${NC}"
    echo -e "${YELLOW}You can access the backend API at:${NC}"
    echo -e "${GREEN}http://your-server-ip:${SERVER_PORT}${NC}"
fi