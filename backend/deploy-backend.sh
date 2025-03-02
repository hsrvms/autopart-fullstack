#!/bin/bash
set -e

# Check if .env.production exists
if [ ! -f .env.production ]; then
  echo "Error: .env.production file not found."
  echo "Please create it based on the .env.production.example template."
  exit 1
fi

# Export environment variables
export $(cat .env.production | grep -v '^#' | xargs)

# Check for required database variables
REQUIRED_VARS=("DB_HOST" "DB_USER" "DB_PASSWORD" "DB_NAME")
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Required environment variable $var is not set in .env.production"
    exit 1
  fi
done

# Build and start the Docker containers
echo "Building and starting Go backend container..."
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache
docker compose -f docker-compose.prod.yml --env-file .env.production up -d

echo "Deployment completed successfully."
echo "API server running on port 8080"

# Display logs to check for any startup issues
echo "Showing container logs (press Ctrl+C to exit):"
docker compose -f docker-compose.prod.yml logs -f
