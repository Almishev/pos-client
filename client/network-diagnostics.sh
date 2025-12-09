#!/bin/bash

echo "=========================================="
echo "  Network Diagnostics for POS System"
echo "=========================================="
echo ""

# Server info
echo "=== Server Information ==="
echo "Server IP: $(hostname -I | awk '{print $1}')"
echo "Network Interface: $(ip route | grep default | awk '{print $5}')"
echo "Gateway: $(ip route | grep default | awk '{print $3}')"
echo ""

# Port status
echo "=== Port Status ==="
echo "Frontend (3001):"
ss -tlnp | grep ":3001" || echo "  ❌ Port 3001 not listening"
echo ""
echo "Backend (8087):"
ss -tlnp | grep ":8087" || echo "  ❌ Port 8087 not listening"
echo ""

# Docker containers
echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep pos-shop
echo ""

# Test connectivity
echo "=== Connectivity Tests ==="
echo "Testing local connection..."
LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/)
if [ "$LOCAL_TEST" = "200" ]; then
    echo "  ✅ Local frontend: OK (HTTP $LOCAL_TEST)"
else
    echo "  ❌ Local frontend: FAILED (HTTP $LOCAL_TEST)"
fi

LOCAL_BACKEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8087/api/v1.0/health)
if [ "$LOCAL_BACKEND" = "200" ]; then
    echo "  ✅ Local backend: OK (HTTP $LOCAL_BACKEND)"
else
    echo "  ❌ Local backend: FAILED (HTTP $LOCAL_BACKEND)"
fi

SERVER_IP=$(hostname -I | awk '{print $1}')
NETWORK_TEST=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://$SERVER_IP:3001/ 2>/dev/null)
if [ "$NETWORK_TEST" = "200" ]; then
    echo "  ✅ Network frontend: OK (HTTP $NETWORK_TEST)"
else
    echo "  ⚠️  Network frontend: May need testing from another device"
fi
echo ""

# CORS test
echo "=== CORS Configuration Test ==="
CORS_TEST=$(curl -s -H "Origin: http://192.168.80.101:3001" -I http://localhost:8087/api/v1.0/health | grep -i "access-control-allow-origin")
if [ -n "$CORS_TEST" ]; then
    echo "  ✅ CORS: Configured correctly"
    echo "  Response: $CORS_TEST"
else
    echo "  ⚠️  CORS: No CORS headers found"
fi
echo ""

# Firewall check
echo "=== Firewall Check ==="
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    echo "  UFW Status: $UFW_STATUS"
    if echo "$UFW_STATUS" | grep -q "active"; then
        echo "  ⚠️  UFW is active - check if ports 3001 and 8087 are allowed"
        echo "  Run: sudo ufw allow 3001/tcp && sudo ufw allow 8087/tcp"
    fi
else
    echo "  ℹ️  UFW not installed or not accessible"
fi
echo ""

# Recommendations
echo "=========================================="
echo "  Recommendations"
echo "=========================================="
echo ""
echo "If devices cannot connect, check:"
echo ""
echo "1. AP Isolation (Client Isolation) on Wi-Fi Router:"
echo "   - Access router settings (usually http://192.168.80.1)"
echo "   - Find 'Wireless' or 'Wi-Fi Settings'"
echo "   - Look for 'AP Isolation', 'Client Isolation', or 'Station Isolation'"
echo "   - DISABLE it"
echo "   - Save and restart router"
echo ""
echo "2. Firewall Rules:"
echo "   sudo ufw allow 3001/tcp"
echo "   sudo ufw allow 8087/tcp"
echo ""
echo "3. Network Verification:"
echo "   - Ensure devices are on same network (192.168.80.x)"
echo "   - Test ping: ping 192.168.80.120"
echo "   - Test port: telnet 192.168.80.120 3001"
echo ""
echo "4. Test from smartphone/laptop:"
echo "   - Open browser"
echo "   - Go to: http://192.168.80.120:3001"
echo "   - Check browser console for errors (F12)"
echo ""
echo "=========================================="

