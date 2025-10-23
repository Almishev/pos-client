#!/bin/bash

echo "========================================"
echo "   Auto Fix Network Configuration"
echo "========================================"
echo

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Detected server IP: $SERVER_IP"

# Update docker-compose.client.yml with correct IP
echo "Updating configuration..."
sed -i "s/192.168.80.120/$SERVER_IP/g" docker-compose.client.yml

# Stop and restart system
echo "Restarting system..."
docker-compose -f docker-compose.client.yml down
docker rm -f pos-shop-frontend 2>/dev/null || true
docker-compose -f docker-compose.client.yml up -d

echo "Waiting for services..."
sleep 20

echo
echo "========================================"
echo "   Fixed! Try logging in now:"
echo "========================================"
echo
echo "Server: http://localhost:3001"
echo "Cash Register: http://$SERVER_IP:3001"
echo
echo "Login: admin@abv.com / 123456"
echo
