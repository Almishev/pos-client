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
echo "   Fix Network Configuration"
echo "========================================"
echo

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
print_info "Detected server IP: $SERVER_IP"

# Update IP address in docker-compose.client.yml
print_info "Updating IP address in docker-compose.client.yml..."
sed -i "s/192.168.80.120/$SERVER_IP/g" docker-compose.client.yml

print_status "IP address updated to: $SERVER_IP"

# Stop current system
print_info "Stopping current system..."
docker-compose -f docker-compose.client.yml down

# Remove frontend container to force rebuild with new environment
print_info "Removing frontend container..."
docker rm -f pos-shop-frontend 2>/dev/null || true

# Start system with new configuration
print_info "Starting system with network configuration..."
docker-compose -f docker-compose.client.yml up -d

# Wait for services to start
print_info "Waiting for services to start..."
sleep 15

# Check status
print_info "Checking service status..."
docker-compose -f docker-compose.client.yml ps

echo
echo "========================================"
echo "   Network Configuration Fixed!"
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
print_warning "If you still have issues, try:"
echo "  1. Clear browser cache"
echo "  2. Try incognito/private mode"
echo "  3. Check firewall settings"
echo
read -p "Press Enter to continue..."
