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

has_compose() {
    docker compose version &> /dev/null || command -v docker-compose &> /dev/null
}

if ! command -v docker &> /dev/null || ! has_compose; then
    print_warning "Docker or Docker Compose not found! Installing..."
    
    # Clean APT cache to avoid corrupted files
    print_info "Cleaning APT cache..."
    sudo apt clean
    
    # Update package list
    print_info "Updating package list..."
    sudo apt update
    
    # Install Docker and Compose V1 together (most reliable on Mint/Ubuntu)
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

# Step 2: Setting up environment configuration
echo "Step 2: Setting up environment configuration..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found! Creating from template..."
    
    if [ -f "env.example" ]; then
        cp env.example .env
        print_status ".env file created from template"
        
        # Generate secure passwords
        print_info "Generating secure passwords..."
        
        # Generate JWT secret key
        JWT_SECRET=$(openssl rand -base64 64 2>/dev/null || echo "fallback_jwt_secret_$(date +%s)")
        DB_PASSWORD=$(openssl rand -base64 32 2>/dev/null || echo "fallback_db_pass_$(date +%s)")
        
        # Update .env file with generated passwords
        if command -v sed &> /dev/null; then
            sed -i "s/thisismysecretkeyfortheupcomingproject/$JWT_SECRET/g" .env
            sed -i "s/asroma/$DB_PASSWORD/g" .env
            # Ensure browser API URL exists for local access
            if ! grep -q '^VITE_API_BASE_URL=' .env; then
                echo "VITE_API_BASE_URL=http://localhost:8087/api/v1.0" >> .env
            fi
            if ! grep -q '^ALLOWED_ORIGINS=' .env; then
                echo "ALLOWED_ORIGINS=http://localhost:3001,http://127.0.0.1:3001" >> .env
            fi
            print_status "Secure passwords generated and updated in .env"
            print_warning "IMPORTANT: Save these passwords securely!"
            print_info "Database password: $DB_PASSWORD"
            print_info "JWT secret key: $JWT_SECRET"
            print_info "docker-compose.client.yml reads SPRING_DATASOURCE_PASSWORD from .env"
        else
            print_warning "sed not available, please manually update passwords in .env file"
        fi
    else
        print_error "env.example not found!"
        exit 1
    fi
else
    print_status ".env file already exists"
fi

# Helper: prefer docker compose plugin, fall back to docker-compose
compose() {
    if docker compose version &> /dev/null; then
        docker compose "$@"
    else
        docker-compose "$@"
    fi
}

# Step 3: Downloading POS System images
echo "Step 3: Downloading POS System images..."
print_info "This may take a few minutes depending on your internet connection..."
compose -f docker-compose.client.yml pull

if [ $? -ne 0 ]; then
    print_error "Failed to download images!"
    print_info "Please check your internet connection and try again."
    exit 1
fi

print_status "Images downloaded successfully!"

# Step 4: Starting POS System
echo "Step 4: Starting POS System..."
compose -f docker-compose.client.yml up -d

if [ $? -ne 0 ]; then
    print_error "Failed to start the system!"
    print_info "Please check the logs: docker compose -f docker-compose.client.yml logs"
    exit 1
fi

# Step 5: Waiting for services to be ready
echo "Step 5: Waiting for services to start..."
print_info "Please wait while the system initializes..."

# Wait longer for database initialization
sleep 15

# Check if services are running
echo "Step 6: Checking service status..."
if compose -f docker-compose.client.yml ps | grep -qE "Up|running"; then
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
echo "  Web Interface: http://localhost:3001"
echo "  API Endpoint: http://localhost:8087/api/v1.0"
echo
print_info "Default Login Credentials:"
echo "  Email: admin@abv.com"
echo "  Password: 123456"
echo
print_warning "For other PCs in the shop, run: ./switch-network.sh"
print_warning "If the system is still starting, wait 2-3 minutes and refresh."
echo
echo "Management: ./start.sh | ./stop.sh | ./restart.sh | ./status.sh"
echo "Guide: INSTALLATION_GUIDE.md"
echo
print_info "Installation completed successfully!"
echo
read -p "Press Enter to continue..."
