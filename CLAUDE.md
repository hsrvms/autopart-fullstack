# AutoParts Flutter App Commands & Guidelines

## Project Structure
The project is organized into two main directories:
- `backend/` - Go backend API server
- `frontend/` - Flutter web and mobile application

## Build & Run Commands
```bash
# Development - Frontend (Flutter)
cd frontend && flutter run -d chrome # for web
cd frontend && flutter run # for mobile/desktop

# Development - Backend (Go)
cd backend && go run cmd/server/main.go

# Build frontend for production
cd frontend && flutter build web --release --dart-define=API_BASE_URL=<URL> --dart-define=API_URL=<URL> --dart-define=FLUTTER_DEV=false

# Docker - Full System
./deploy.sh

# Docker - Backend Only
cd backend && ./deploy.sh

# Docker - Frontend Only
cd frontend && ./deploy.sh
```

## Testing & Linting
```bash
# Flutter
cd frontend && flutter test
cd frontend && flutter analyze
cd frontend && flutter pub run build_runner build # Generate code

# Go
cd backend && go test ./...
```

## Code Style Guidelines
- **Architecture**: Feature-first organization, repository pattern, clean architecture
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Imports**: Group by package type (Dart, Flutter, third-party, project)
- **Error Handling**: Use try/catch with meaningful error messages
- **Types**: Use strong typing with nullability annotations
- **State Management**: GetX for routes and dependency injection
- **Backend**: Module-based organization with repositories, services, handlers