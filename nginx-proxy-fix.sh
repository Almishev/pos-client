#!/bin/bash

echo "========================================"
echo "   Fix Network Access with Nginx Proxy"
echo "========================================"
echo

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Detected server IP: $SERVER_IP"

# Stop current system
echo "Stopping current system..."
docker-compose -f docker-compose.client.yml down

# Create custom nginx configuration for network access
echo "Creating nginx configuration for network access..."
cat > nginx-network.conf << EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Handle React Router
        location / {
            try_files \$uri \$uri/ /index.html;
        }

        # API proxy to backend - use server IP instead of localhost
        location /api/ {
            proxy_pass http://$SERVER_IP:8087/api/v1.0/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # Static assets caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Create custom docker-compose with nginx volume mount
echo "Creating custom docker-compose configuration..."
cat > docker-compose.network-nginx.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: pos-shop-db
    environment:
      POSTGRES_DB: billing_app
      POSTGRES_USER: user1
      POSTGRES_PASSWORD: asroma
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db:/docker-entrypoint-initdb.d
    networks:
      - pos-shop-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user1 -d billing_app"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: antonalmishev/supermarket-pos-backend:latest
    container_name: pos-shop-backend
    ports:
      - "8087:8087"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/billing_app
      SPRING_DATASOURCE_USERNAME: user1
      SPRING_DATASOURCE_PASSWORD: asroma
      SPRING_JPA_HIBERNATE_DDL_AUTO: update
      SPRING_JPA_SHOW_SQL: "true"
      SERVER_PORT: "8087"
      SERVER_SERVLET_CONTEXT_PATH: /api/v1.0
      JWT_SECRET_KEY: thisismysecretkeyfortheupcomingproject
      AWS_ACCESS_KEY: disabled
      AWS_SECRET_KEY: disabled
      AWS_REGION: eu-central-1
      AWS_BUCKET_NAME: disabled
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - pos-shop-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8087/api/v1.0/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped

  frontend:
    image: antonalmishev/supermarket-pos-frontend:latest
    container_name: pos-shop-frontend
    ports:
      - "3001:80"
    volumes:
      - ./nginx-network.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend
    networks:
      - pos-shop-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

networks:
  pos-shop-network:
    name: supermarket_pos-shop-network
    driver: bridge

volumes:
  postgres_data:
    name: supermarket_postgres_data
    driver: local
EOF

# Start system with custom nginx configuration
echo "Starting system with network nginx configuration..."
docker-compose -f docker-compose.network-nginx.yml up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 20

# Check status
echo "Checking service status..."
docker-compose -f docker-compose.network-nginx.yml ps

echo
echo "========================================"
echo "   Network Access Fixed!"
echo "========================================"
echo
echo "✅ System is now configured for network access!"
echo
echo "Access URLs:"
echo "  🖥️  Server: http://localhost:3001"
echo "  💻 Cash Register: http://$SERVER_IP:3001"
echo
echo "Login credentials:"
echo "  📧 Email: admin@abv.com"
echo "  🔑 Password: 123456"
echo
echo "The nginx proxy now routes /api/ requests to $SERVER_IP:8087"
echo
