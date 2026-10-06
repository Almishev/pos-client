#!/bin/bash

echo "Stopping Supermarket POS System..."

if [ ! -f "docker-compose.client.yml" ]; then
    echo "Error: docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

compose() {
    if docker compose version &>/dev/null; then
        docker compose "$@"
    elif command -v docker-compose &>/dev/null; then
        docker-compose "$@"
    else
        echo "Error: neither 'docker compose' nor 'docker-compose' found."
        exit 1
    fi
}

compose -f docker-compose.client.yml down

echo "POS System stopped!"
