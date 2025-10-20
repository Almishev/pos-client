#!/bin/bash

echo "========================================"
echo "   Supermarket POS System Installer"
echo "========================================"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Docker is installed
echo "Step 1: Checking Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo
    print_warning "Docker installed! Please log out and log back in, then run this script again."
    exit 1
fi

print_status "Docker is installed!"

# Check if docker-compose is available
echo "Step 2: Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose not found, trying 'docker compose'..."
    if ! docker compose version &> /dev/null; then
        print_error "Neither 'docker-compose' nor 'docker compose' is available!"
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        # Use 'docker compose' instead of 'docker-compose'
        alias docker-compose='docker compose'
    fi
fi

print_status "Docker Compose is ready!"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.client.yml" ]; then
    print_error "docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Download and start the system
echo "Step 3: Downloading POS System images..."
docker-compose -f docker-compose.client.yml pull

echo "Step 4: Starting POS System..."
docker-compose -f docker-compose.client.yml up -d

# Wait for services to be ready
echo "Step 5: Waiting for services to start..."
sleep 10

# Check if services are running
echo "Step 6: Checking service status..."
if docker-compose -f docker-compose.client.yml ps | grep -q "Up"; then
    print_status "Services are running!"
else
    print_warning "Some services might still be starting..."
fi

echo
echo "========================================"
echo "    Installation Complete!"
echo "========================================"
echo
echo "Your Supermarket POS System is starting..."
echo "Please wait 2-3 minutes for full initialization, then:"
echo
echo "1. Open your web browser"
echo "2. Go to: http://localhost:3001"
echo "3. Login with:"
echo "   Email: admin@supermarket.com"
echo "   Password: 123456"
echo
echo "========================================"
echo "    Management Commands"
echo "========================================"
echo
echo "To stop the system:"
echo "  ./stop.sh"
echo
echo "To start the system:"
echo "  ./start.sh"
echo
echo "To restart the system:"
echo "  ./restart.sh"
echo
echo "To check status:"
echo "  ./status.sh"
echo
echo "To view logs:"
echo "  docker-compose -f docker-compose.client.yml logs"
echo
read -p "Press Enter to continue..."
