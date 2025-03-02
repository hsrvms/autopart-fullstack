#!/bin/bash

# Deploy only the frontend
echo "Deploying frontend only..."

# Build and start frontend services
docker-compose up -d --build

echo "Frontend deployment completed successfully!"