#!/bin/bash

echo "Starting Supermarket POS System..."

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

BACKUP_DIR="./archives/db-backups"
if [ -f .env ]; then
    raw=$(grep -E '^[[:space:]]*BACKUP_HOST_PATH=' .env | tail -n1 | cut -d= -f2- | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
    if [ -n "$raw" ]; then
        BACKUP_DIR="$raw"
    fi
fi
mkdir -p "$BACKUP_DIR"
echo "Backup directory: $BACKUP_DIR"

compose -f docker-compose.client.yml up -d

echo "POS System started!"
echo "Go to: http://localhost:3001"
echo
echo "Default login: digit PIN (admin 000000)"
