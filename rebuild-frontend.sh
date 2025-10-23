#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo "========================================"
echo "   Rebuild Frontend for Network Access"
echo "========================================"
echo

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
print_info "Detected server IP: $SERVER_IP"

# Stop current system
print_info "Stopping current system..."
docker-compose -f docker-compose.client.yml down

# Remove frontend container and image
print_info "Removing frontend container and image..."
docker rm -f pos-shop-frontend 2>/dev/null || true
docker rmi antonalmishev/supermarket-pos-frontend:latest 2>/dev/null || true

# Create temporary environment file
print_info "Creating network environment file..."
cat > env.network << EOF
VITE_API_BASE_URL=http://$SERVER_IP:8087/api/v1.0
EOF

# Build frontend with network configuration
print_info "Building frontend with network configuration..."
print_warning "This may take a few minutes..."

# Create temporary Dockerfile for network build
cat > Dockerfile.network << 'EOF'
# Multi-stage build for React application
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Copy environment file for network access
COPY env.network .env

# Build the application
RUN npm run build

# Production stage with nginx
FROM nginx:alpine

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build the image
docker build -f Dockerfile.network -t antonalmishev/supermarket-pos-frontend:latest .

if [ $? -eq 0 ]; then
    print_status "Frontend built successfully!"
else
    print_error "Failed to build frontend!"
    exit 1
fi

# Clean up temporary files
rm -f env.network Dockerfile.network

# Update docker-compose to use local image
print_info "Updating docker-compose configuration..."
sed -i "s|image: antonalmishev/supermarket-pos-frontend:latest|image: antonalmishev/supermarket-pos-frontend:latest|g" docker-compose.client.yml

# Remove environment variable from docker-compose (not needed anymore)
sed -i '/VITE_API_BASE_URL/d' docker-compose.client.yml

# Start system
print_info "Starting system with rebuilt frontend..."
docker-compose -f docker-compose.client.yml up -d

# Wait for services to start
print_info "Waiting for services to start..."
sleep 20

# Check status
print_info "Checking service status..."
docker-compose -f docker-compose.client.yml ps

echo
echo "========================================"
echo "   Frontend Rebuilt Successfully!"
echo "========================================"
echo
print_status "System is now configured for network access!"
echo
print_info "Access URLs:"
echo "  🖥️  Server: http://localhost:3001"
echo "  💻 Cash Register: http://$SERVER_IP:3001"
echo
print_info "Login credentials:"
echo "  📧 Email: admin@abv.com"
echo "  🔑 Password: 123456"
echo
print_warning "The frontend is now hardcoded to use: http://$SERVER_IP:8087/api/v1.0"
print_warning "If you change the server IP, you'll need to rebuild the frontend again."
echo
read -p "Press Enter to continue..."
