# 🖥️ Multi-Computer Setup Guide

## Problem Description
When accessing the POS system from a cash register computer (e.g., `http://192.168.80.120:3001`), the frontend tries to connect to `localhost:8087` instead of the server's IP address, causing login failures.

## Quick Solution

### Step 1: Configure Network Access
```bash
cd pos-client
./switch-network.sh
```

Choose option 2 (Network access) and the script will automatically configure the system for network access.

### Step 2: Restart the System
```bash
./restart.sh
```

### Step 3: Test from Cash Register
Open browser on cash register computer and go to:
```
http://[SERVER_IP]:3001
```

## Manual Configuration

### Option 1: Use Network Docker Compose
```bash
# Stop current system
./stop.sh

# Use network configuration
cp docker-compose.network.yml docker-compose.client.yml

# Update IP address in the file (replace 192.168.80.120 with your server IP)
sed -i 's/192.168.80.120/YOUR_SERVER_IP/g' docker-compose.client.yml

# Start system
./start.sh
```

### Option 2: Update Environment Variables
Edit `docker-compose.client.yml` and add environment variable to frontend service:

```yaml
frontend:
  image: antonalmishev/supermarket-pos-frontend:latest
  container_name: pos-shop-frontend
  ports:
    - "3001:80"
  environment:
    - VITE_API_BASE_URL=http://YOUR_SERVER_IP:8087/api/v1.0
  depends_on:
    - backend
  networks:
    - pos-shop-network
```

## Testing

### From Server Computer:
- ✅ Frontend: http://localhost:3001
- ✅ Backend: http://localhost:8087

### From Cash Register Computer:
- ✅ Frontend: http://[SERVER_IP]:3001
- ✅ Backend: http://[SERVER_IP]:8087

## Troubleshooting

### Check if services are accessible:
```bash
# From cash register computer
curl http://[SERVER_IP]:3001  # Frontend
curl http://[SERVER_IP]:8087/api/v1.0/health  # Backend
```

### Check firewall (on server):
```bash
sudo ufw status
sudo ufw allow 3001
sudo ufw allow 8087
```

### Check Docker network:
```bash
docker network ls
docker network inspect supermarket_pos-shop-network
```

### Check if backend is accessible:
```bash
# From cash register computer
telnet [SERVER_IP] 8087
```

## Network Requirements

### Server Computer:
- ✅ Docker and Docker Compose installed
- ✅ Ports 3001 and 8087 open
- ✅ Network access enabled

### Cash Register Computer:
- ✅ Web browser (Chrome, Firefox, Edge)
- ✅ Network connection to server
- ✅ No firewall blocking access

## Security Considerations

### For Production:
1. **Use HTTPS** instead of HTTP
2. **Configure firewall** to restrict access
3. **Use VPN** for remote access
4. **Regular security updates**

### For Development/Testing:
- Current setup is sufficient for local network testing

## Common Issues

### Issue: "Connection Refused"
**Solution**: Check if backend is running and accessible
```bash
docker-compose -f docker-compose.client.yml ps
```

### Issue: "Invalid Email/Password"
**Solution**: Check if database is initialized
```bash
docker-compose -f docker-compose.client.yml logs postgres
```

### Issue: "CORS Error"
**Solution**: Backend CORS is already configured for network access

## Support

If you encounter issues:
1. Check system status: `./status.sh`
2. View logs: `docker-compose -f docker-compose.client.yml logs`
3. Restart system: `./restart.sh`
4. Contact system administrator

---
**Multi-computer setup is now ready!** 🎉
