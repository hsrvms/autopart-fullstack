# AutoParts Flutter App

A multi-platform inventory management system for auto parts stores with Flutter frontend and Go backend.

## Project Structure

- **Frontend**: Flutter application with web, Android, and iOS support
- **Backend**: Go API server with PostgreSQL database
- **Deployment**: Docker and Docker Compose configuration for easy deployment

## Development Setup

### Prerequisites

- Flutter SDK 3.2.3 or higher
- Go 1.21 or higher
- Docker and Docker Compose
- PostgreSQL

### Running Locally

1. Clone the repository
2. Start the database:
   ```bash
   docker-compose up db
   ```
3. Run the backend:
   ```bash
   go run cmd/server/main.go
   ```
4. Run the Flutter app:
   ```bash
   flutter run -d chrome
   ```

## Production Deployment

### Deployment to VPS or EC2

1. Copy `.env.production.example` to `.env.production` and adjust variables:
   ```bash
   cp .env.production.example .env.production
   nano .env.production
   ```

2. Make sure to update these settings:
   - `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` - Database credentials
   - `API_DOMAIN` - API server domain name (e.g., api.yourdomain.com)
   - `WEB_DOMAIN` - Web app domain name (e.g., yourdomain.com)

3. Prepare SSL certificates:
   - Create an `ssl` directory
   - Add your SSL certificates as:
     - `ssl/<API_DOMAIN>.crt` and `ssl/<API_DOMAIN>.key`
     - `ssl/<WEB_DOMAIN>.crt` and `ssl/<WEB_DOMAIN>.key`
   - For Let's Encrypt, follow instructions at the end of deployment

4. Deploy with the automated script:
   ```bash
   ./deploy.sh
   ```

### AWS EC2 Specific Configuration

For AWS EC2 deployment:

1. Open ports 80 and 443 in your security group
2. Set your EC2 instance's Elastic IP or public DNS as the domain
3. For proper domain usage, point your domain's DNS records to the EC2 instance

## System Features

- Inventory management for auto parts
- Vehicle compatibility checking
- Order and sales tracking
- Customer management
- Barcode printing and scanning
- Supplier information
- Stock alerts and dashboard

## Environment Variables

See `.env.production.example` for all available configuration options.

## Troubleshooting

If you encounter issues:
- Check logs: `docker-compose -f docker-compose.prod.yml logs`
- Verify SSL certificates are correctly named and valid
- Ensure ports 80 and 443 are not blocked by firewall
- Validate database connectivity