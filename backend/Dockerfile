FROM golang:1.21-alpine

# Install necessary development tools
RUN apk add --no-cache gcc musl-dev git

# Set working directory
WORKDIR /app

# Copy Go module files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Install air for live reloading
RUN go install github.com/cosmtrek/air@latest

# Copy application files
COPY cmd/ ./cmd/
COPY internal/ ./internal/
COPY pkg/ ./pkg/

# Copy Air configuration
COPY .air.toml ./

# Expose application port
EXPOSE 8080

# Run in development mode with live reloading
CMD ["air", "-c", ".air.toml"]