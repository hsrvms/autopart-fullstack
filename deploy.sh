#!/bin/bash

# Deploy both backend and frontend
echo "Deploying both backend and frontend..."

# Build and start all services
docker-compose up -d --build

echo "Deployment completed successfully!"