#!/bin/bash

echo "Supermarket POS System Status"
echo "============================="

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

compose -f docker-compose.client.yml ps

echo
echo "Service Status:"
echo "==============="

echo "Frontend (Port 3001):"
echo "  Status: $(compose -f docker-compose.client.yml ps frontend 2>/dev/null | grep -qE 'Up|running' && echo "Running" || echo "Stopped")"

echo "Backend (Port 8087):"
echo "  Status: $(compose -f docker-compose.client.yml ps backend 2>/dev/null | grep -qE 'Up|running' && echo "Running" || echo "Stopped")"

echo "Database (Port 5433):"
echo "  Status: $(compose -f docker-compose.client.yml ps postgres 2>/dev/null | grep -qE 'Up|running' && echo "Running" || echo "Stopped")"

echo
echo "Useful commands:"
echo "  docker compose -f docker-compose.client.yml logs"
echo "  ./start.sh"
echo "  ./stop.sh"
echo "  ./restart.sh"
