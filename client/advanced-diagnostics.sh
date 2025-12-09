#!/bin/bash

echo "=========================================="
echo "  Advanced Network Diagnostics"
echo "=========================================="
echo ""

SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $SERVER_IP"
echo ""

echo "=== Step 1: Port Binding Check ==="
echo "Checking if ports are bound to all interfaces (0.0.0.0)..."
FRONTEND_BIND=$(ss -tlnp | grep ":3001" | grep "0.0.0.0")
BACKEND_BIND=$(ss -tlnp | grep ":8087" | grep "0.0.0.0")

if [ -n "$FRONTEND_BIND" ]; then
    echo "  ✅ Frontend (3001): Bound to 0.0.0.0 (all interfaces)"
else
    echo "  ❌ Frontend (3001): NOT bound to all interfaces"
fi

if [ -n "$BACKEND_BIND" ]; then
    echo "  ✅ Backend (8087): Bound to 0.0.0.0 (all interfaces)"
else
    echo "  ❌ Backend (8087): NOT bound to all interfaces"
fi
echo ""

echo "=== Step 2: Docker Port Mappings ==="
echo "Frontend:"
docker port pos-shop-frontend 2>/dev/null || echo "  ❌ Cannot get port mapping"
echo "Backend:"
docker port pos-shop-backend 2>/dev/null || echo "  ❌ Cannot get port mapping"
echo ""

echo "=== Step 3: Network Interface Check ==="
INTERFACE=$(ip route | grep default | awk '{print $5}')
echo "Default interface: $INTERFACE"
echo "IP address: $SERVER_IP"
echo ""

echo "=== Step 4: Test Connection from Network IP ==="
echo "Testing connection to $SERVER_IP:3001..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://$SERVER_IP:3001/ 2>/dev/null)
if [ "$RESPONSE" = "200" ]; then
    echo "  ✅ Can connect to $SERVER_IP:3001 (HTTP $RESPONSE)"
else
    echo "  ⚠️  Cannot connect to $SERVER_IP:3001 (HTTP $RESPONSE)"
fi
echo ""

echo "=== Step 5: Monitor for External Requests ==="
echo "Starting 30-second monitor for requests from other devices..."
echo "Try accessing http://$SERVER_IP:3001 from your smartphone/laptop NOW!"
echo ""

# Clear and monitor logs
docker logs pos-shop-frontend --tail 0 > /dev/null 2>&1

EXTERNAL_FOUND=0
timeout 30 docker logs -f pos-shop-frontend 2>&1 | while IFS= read -r line; do
    # Check for external IPs (not server, localhost, or docker network)
    if echo "$line" | grep -qE "192\.168\.80\.([0-9]{1,2}|1[0-1][0-9]|12[0-9]|1[3-9][0-9]|[2-9][0-9]{2})"; then
        EXTERNAL_IP=$(echo "$line" | grep -oE "192\.168\.80\.([0-9]{1,3})" | head -1)
        if [ "$EXTERNAL_IP" != "$SERVER_IP" ] && [ "$EXTERNAL_IP" != "192.168.80.1" ]; then
            echo "  ✅ EXTERNAL REQUEST DETECTED from: $EXTERNAL_IP"
            echo "     $line"
            EXTERNAL_FOUND=1
        fi
    fi
done

echo ""
if [ $EXTERNAL_FOUND -eq 0 ]; then
    echo "  ❌ No external requests detected in 30 seconds"
    echo ""
    echo "  This means requests from smartphone/laptop are NOT reaching the server."
    echo "  Possible causes:"
    echo "  1. AP Isolation on Wi-Fi router"
    echo "  2. Firewall blocking connections"
    echo "  3. Devices not on same network"
    echo "  4. Router firmware update changed settings"
else
    echo "  ✅ External requests ARE reaching the server!"
fi
echo ""

echo "=== Step 6: Recent Log Analysis ==="
echo "Last 10 requests with IP addresses:"
docker logs pos-shop-frontend --tail 20 2>&1 | grep -E "GET|POST|OPTIONS" | tail -10
echo ""

echo "Unique IP addresses in last 50 requests:"
docker logs pos-shop-frontend --tail 50 2>&1 | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u
echo ""

echo "=========================================="
echo "  Recommendations"
echo "=========================================="
echo ""
echo "If no external requests detected:"
echo ""
echo "1. Check AP Isolation on router (even if it worked before)"
echo "   - Router firmware updates can enable it"
echo "   - Router settings can reset after power outage"
echo ""
echo "2. Test with tcpdump (requires sudo):"
echo "   sudo tcpdump -i any -n port 3001"
echo "   - If you see packets from other IPs → requests reach server"
echo "   - If no packets → network isolation problem"
echo ""
echo "3. Test ping from smartphone/laptop:"
echo "   ping $SERVER_IP"
echo "   - If ping works but web doesn't → firewall/port issue"
echo "   - If ping doesn't work → network isolation"
echo ""
echo "4. Check if router was updated recently"
echo "   - Firmware updates can change default settings"
echo ""
echo "=========================================="

