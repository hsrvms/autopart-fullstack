#!/bin/bash

# Deploy only the backend
echo "Deploying backend only..."

# Build and start backend services
docker-compose up -d --build

echo "Backend deployment completed successfully!"