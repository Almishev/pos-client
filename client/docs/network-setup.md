# 🌐 Network Configuration for Multi-Computer Setup

## Problem
When accessing the POS system from a cash register computer (e.g., `http://192.168.80.120:3001`), the frontend tries to connect to `localhost:8087` instead of the server's IP address.

## Solution Options

### Option 1: Use Nginx Proxy (Recommended) ✅
The frontend is already configured to use `/api` which gets proxied by Nginx to the backend. This should work from any computer on the network.

### Option 2: Configure Frontend for Network Access
If Option 1 doesn't work, we need to configure the frontend to use the server's IP address.

## Quick Fix

### Step 1: Check if Nginx proxy is working
From the cash register computer, test:
```bash
curl http://192.168.80.120:3001/api/health
```

If this returns a response, the proxy is working correctly.

### Step 2: If proxy is not working, update environment
Create a new environment file for network access:

```bash
# In client-package directory
cp env.example-front env.network
```

Edit `env.network`:
```
VITE_API_BASE_URL=http://192.168.80.120:8087/api/v1.0
```

### Step 3: Update docker-compose for network access
Add environment variable to frontend service:

```yaml
frontend:
  image: antonalmishev/supermarket-pos-frontend:latest
  container_name: pos-shop-frontend
  ports:
    - "3001:80"
  environment:
    - VITE_API_BASE_URL=http://192.168.80.120:8087/api/v1.0
  depends_on:
    - backend
  networks:
    - pos-shop-network
```

## Testing

### From Server Computer:
- Frontend: http://localhost:3001
- Backend: http://localhost:8087

### From Cash Register Computer:
- Frontend: http://192.168.80.120:3001
- Backend: http://192.168.80.120:8087

## Troubleshooting

### Check if services are accessible:
```bash
# From cash register computer
curl http://192.168.80.120:3001  # Frontend
curl http://192.168.80.120:8087/api/v1.0/health  # Backend
```

### Check firewall:
```bash
# On server computer
sudo ufw status
sudo ufw allow 3001
sudo ufw allow 8087
```

### Check Docker network:
```bash
docker network ls
docker network inspect supermarket_pos-shop-network
```
