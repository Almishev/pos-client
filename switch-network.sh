#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

set_env_var() {
    local key="$1"
    local value="$2"
    if [ ! -f ".env" ]; then
        print_error ".env not found! Run ./install.sh first."
        exit 1
    fi
    grep -v "^${key}=" .env > .env.tmp
    echo "${key}=${value}" >> .env.tmp
    mv .env.tmp .env
}

apply_api_urls() {
    local host="$1"
    set_env_var "SERVER_IP" "$host"
    set_env_var "VITE_API_BASE_URL" "http://${host}:8087/api/v1.0"
    set_env_var "BACKEND_URL" "http://${host}:8087"
    if [ "$host" = "localhost" ] || [ "$host" = "127.0.0.1" ]; then
        set_env_var "ALLOWED_ORIGINS" "http://localhost:3001,http://127.0.0.1:3001"
    else
        set_env_var "ALLOWED_ORIGINS" "http://localhost:3001,http://127.0.0.1:3001,http://${host}:3001"
    fi
}

echo "========================================"
echo "   POS System Network Configuration"
echo "========================================"
echo

if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root!"
    exit 1
fi

if [ ! -f "docker-compose.client.yml" ]; then
    print_error "docker-compose.client.yml not found! Run this from the pos-client directory."
    exit 1
fi

if [ ! -f ".env" ]; then
    print_error ".env not found! Run ./install.sh first."
    exit 1
fi

SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="127.0.0.1"
fi
print_info "Detected server IP: $SERVER_IP"

echo
echo "This updates VITE_API_BASE_URL / ALLOWED_ORIGINS in .env"
echo "(browsers cannot reach Docker service names like 'backend')."
echo
echo "Choose network configuration:"
echo "1) Local only (localhost) - single computer"
echo "2) Network access (IP: $SERVER_IP) - other PCs in the shop"
echo "3) Custom IP address"
echo

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        print_info "Configuring for local access only..."
        apply_api_urls "localhost"
        print_status "Configuration set to local access"
        print_info "Access: http://localhost:3001"
        ;;
    2)
        print_info "Configuring for network access..."
        apply_api_urls "$SERVER_IP"
        print_status "Configuration set to network access"
        print_info "Access from any computer: http://$SERVER_IP:3001"
        ;;
    3)
        read -p "Enter custom IP address: " custom_ip
        if [ -z "$custom_ip" ]; then
            print_error "IP address required"
            exit 1
        fi
        print_info "Configuring for custom IP: $custom_ip"
        apply_api_urls "$custom_ip"
        print_status "Configuration set to custom IP"
        print_info "Access from any computer: http://$custom_ip:3001"
        SERVER_IP="$custom_ip"
        ;;
    *)
        print_error "Invalid choice!"
        exit 1
        ;;
esac

echo
print_warning "Restart the system for changes to take effect:"
echo "  ./restart.sh"
echo
print_info "On cash registers open:"
echo "  http://$SERVER_IP:3001"
echo
print_info "Firewall (if needed):"
echo "  sudo ufw allow 3001/tcp && sudo ufw allow 8087/tcp"
echo
read -p "Press Enter to continue..."
