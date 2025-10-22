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
echo "   POS System Network Configuration"
echo "========================================"
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root!"
    exit 1
fi

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
print_info "Detected server IP: $SERVER_IP"

echo
echo "Choose network configuration:"
echo "1) Local only (localhost) - for single computer setup"
echo "2) Network access (IP: $SERVER_IP) - for multiple computers"
echo "3) Custom IP address"
echo

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        print_info "Configuring for local access only..."
        cp docker-compose.client.yml docker-compose.yml
        print_status "Configuration set to local access"
        print_info "Access: http://localhost:3001"
        ;;
    2)
        print_info "Configuring for network access..."
        cp docker-compose.network.yml docker-compose.yml
        # Update IP address in the file
        sed -i "s/192.168.80.120/$SERVER_IP/g" docker-compose.yml
        print_status "Configuration set to network access"
        print_info "Access from any computer: http://$SERVER_IP:3001"
        ;;
    3)
        read -p "Enter custom IP address: " custom_ip
        print_info "Configuring for custom IP: $custom_ip"
        cp docker-compose.network.yml docker-compose.yml
        # Update IP address in the file
        sed -i "s/192.168.80.120/$custom_ip/g" docker-compose.yml
        print_status "Configuration set to custom IP"
        print_info "Access from any computer: http://$custom_ip:3001"
        ;;
    *)
        print_error "Invalid choice!"
        exit 1
        ;;
esac

echo
print_warning "You need to restart the system for changes to take effect:"
echo "  ./restart.sh"
echo
print_info "After restart, test access from cash register computer:"
echo "  http://$SERVER_IP:3001"
echo
read -p "Press Enter to continue..."
