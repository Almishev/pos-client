#!/bin/bash

echo "Supermarket POS System Status:"
echo "=============================="

# Check if docker-compose.client.yml exists
if [ ! -f "docker-compose.client.yml" ]; then
    echo "Error: docker-compose.client.yml not found!"
    echo "Please make sure you're in the correct directory."
    exit 1
fi

# Show container status
docker-compose -f docker-compose.client.yml ps

echo
echo "========================================"
echo "    Service Information"
echo "========================================"
echo
echo "Frontend (Web Interface):"
echo "  URL: http://localhost:3001"
echo "  Status: $(docker-compose -f docker-compose.client.yml ps frontend | grep -q "Up" && echo "Running" || echo "Stopped")"
echo
echo "Backend (API):"
echo "  URL: http://localhost:8087/api/v1.0"
echo "  Status: $(docker-compose -f docker-compose.client.yml ps backend | grep -q "Up" && echo "Running" || echo "Stopped")"
echo
echo "Database (PostgreSQL):"
echo "  Host: localhost:5433"
echo "  Database: billing_app"
echo "  Status: $(docker-compose -f docker-compose.client.yml ps postgres | grep -q "Up" && echo "Running" || echo "Stopped")"
echo
echo "========================================"
echo "    Management Commands"
echo "========================================"
echo
echo "To view logs:"
echo "  docker-compose -f docker-compose.client.yml logs"
echo
echo "To restart:"
echo "  ./restart.sh"
echo
echo "To stop:"
echo "  ./stop.sh"
echo
echo "To start:"
echo "  ./start.sh"
