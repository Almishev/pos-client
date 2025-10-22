#!/bin/bash

echo "Starting Supermarket POS System..."

# Check if docker-compose.client.yml exists
if [ ! -f "docker-compose.client.yml" ]; then
    echo "Error: docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Start the system
docker-compose -f docker-compose.client.yml up -d

echo "POS System started!"
echo "Go to: http://localhost:3001"
echo
echo "Default login:"
echo "Email: admin@abv.com"
echo "Password: 123456"
