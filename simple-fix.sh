#!/bin/bash

echo "========================================"
echo "   Simple Network Fix"
echo "========================================"
echo

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Detected server IP: $SERVER_IP"

# Stop current system
echo "Stopping current system..."
docker-compose -f docker-compose.client.yml down

# Create nginx configuration that proxies to server IP
echo "Creating nginx configuration..."
cat > nginx-fix.conf << EOF
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files \$uri \$uri/ /index.html;
        }

        # Proxy API requests to server IP instead of localhost
        location /api/ {
            proxy_pass http://$SERVER_IP:8087/api/v1.0/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Start system normally
echo "Starting system..."
docker-compose -f docker-compose.client.yml up -d

# Wait for frontend to start
echo "Waiting for frontend to start..."
sleep 10

# Copy the fixed nginx config into the running container
echo "Applying nginx fix..."
docker cp nginx-fix.conf pos-shop-frontend:/etc/nginx/nginx.conf

# Restart nginx in the container
echo "Restarting nginx..."
docker exec pos-shop-frontend nginx -s reload

# Clean up
rm -f nginx-fix.conf

echo
echo "========================================"
echo "   Fix Applied!"
echo "========================================"
echo
echo "✅ Nginx now proxies API requests to $SERVER_IP:8087"
echo
echo "Test access:"
echo "  🖥️  Server: http://localhost:3001"
echo "  💻 Cash Register: http://$SERVER_IP:3001"
echo
echo "Login: admin@abv.com / 123456"
echo
