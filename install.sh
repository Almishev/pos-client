#!/bin/bash

echo "========================================"
echo "   Supermarket POS System Installer"
echo "========================================"
echo

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root!"
    print_info "Run it as a regular user. The script will ask for sudo when needed."
    exit 1
fi

# Step 1: Checking and Installing Docker and Docker Compose
echo "Step 1: Checking and Installing Docker..."

if ! command -v docker &> /dev/null || ! command -v docker-compose &> /dev/null; then
    print_warning "Docker or Docker Compose not found! Installing..."
    
    # Clean APT cache to avoid corrupted files
    print_info "Cleaning APT cache..."
    sudo apt clean
    
    # Update package list
    print_info "Updating package list..."
    sudo apt update
    
    # Install Docker and Compose V1 together (most reliable)
    print_info "Installing Docker and Docker Compose..."
    sudo apt install docker.io docker-compose -y
    
    # Start Docker Service
    print_info "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add user to docker group
    print_info "Adding user to docker group..."
    sudo usermod -aG docker $USER
    
    print_warning "Docker and Compose installed successfully!"
    print_warning "IMPORTANT: Please log out and log back in, then run this script again."
    print_info "This is required for the docker group permissions to take effect."
    exit 1
fi

# Verify Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is installed but not running!"
    print_info "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

print_status "Docker and Compose are ready!"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.client.yml" ]; then
    print_error "docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Step 2: Downloading POS System images
echo "Step 2: Downloading POS System images..."
print_info "This may take a few minutes depending on your internet connection..."
docker-compose -f docker-compose.client.yml pull

if [ $? -ne 0 ]; then
    print_error "Failed to download images!"
    print_info "Please check your internet connection and try again."
    exit 1
fi

print_status "Images downloaded successfully!"

# Step 3: Starting POS System
echo "Step 3: Starting POS System..."
docker-compose -f docker-compose.client.yml up -d

if [ $? -ne 0 ]; then
    print_error "Failed to start the system!"
    print_info "Please check the logs: docker-compose -f docker-compose.client.yml logs"
    exit 1
fi

# Step 4: Waiting for services to be ready
echo "Step 4: Waiting for services to start..."
print_info "Please wait while the system initializes..."

# Wait longer for database initialization
sleep 15

# Check if services are running
echo "Step 5: Checking service status..."
if docker-compose -f docker-compose.client.yml ps | grep -q "Up"; then
    print_status "Services are running!"
    
    # Additional health check
    print_info "Performing health check..."
    sleep 5
    
    # Check if backend is responding
    if curl -f http://localhost:8087/api/v1.0/health &> /dev/null; then
        print_status "Backend is healthy!"
    else
        print_warning "Backend might still be starting..."
    fi
    
    # Check if frontend is responding
    if curl -f http://localhost:3001 &> /dev/null; then
        print_status "Frontend is accessible!"
    else
        print_warning "Frontend might still be starting..."
    fi
else
    print_warning "Some services might still be starting..."
    print_info "You can check the status with: ./status.sh"
fi

echo
echo "========================================"
echo "    Installation Complete!"
echo "========================================"
echo
print_status "Your Supermarket POS System is ready!"
echo
print_info "Access your POS system:"
echo "  🌐 Web Interface: http://localhost:3001"
echo "  🔧 API Endpoint: http://localhost:8087"
echo
print_info "Default Login Credentials:"
echo "  📧 Email: admin@supermarket.com"
echo "  🔑 Password: 123456"
echo
print_warning "Note: If the system is still starting, please wait 2-3 minutes"
print_warning "and refresh your browser. You can check status with: ./status.sh"
echo
echo "========================================"
echo "    Management Commands"
echo "========================================"
echo
echo "🛑 Stop the system:"
echo "  ./stop.sh"
echo
echo "▶️  Start the system:"
echo "  ./start.sh"
echo
echo "🔄 Restart the system:"
echo "  ./restart.sh"
echo
echo "📊 Check status:"
echo "  ./status.sh"
echo
echo "📋 View logs:"
echo "  docker-compose -f docker-compose.client.yml logs"
echo
echo "========================================"
echo "    Troubleshooting"
echo "========================================"
echo
echo "If you encounter issues:"
echo "1. Check system status: ./status.sh"
echo "2. View logs: docker-compose -f docker-compose.client.yml logs"
echo "3. Restart system: ./restart.sh"
echo "4. For support, contact your system administrator"
echo
print_info "Installation completed successfully! 🎉"
echo
read -p "Press Enter to continue..."
