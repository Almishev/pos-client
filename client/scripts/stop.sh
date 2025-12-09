#!/bin/bash

echo "Stopping Supermarket POS System..."

# Check if docker-compose.client.yml exists
if [ ! -f "docker-compose.client.yml" ]; then
    echo "Error: docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Stop the system
docker-compose -f docker-compose.client.yml down

echo "POS System stopped!"
