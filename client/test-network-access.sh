#!/bin/bash

echo "=========================================="
echo "  Network Access Test Script"
echo "=========================================="
echo ""

SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $SERVER_IP"
echo ""

echo "=== Step 1: Test from Server ==="
echo "Testing local access..."
LOCAL_FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/)
LOCAL_BACKEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8087/api/v1.0/health)

if [ "$LOCAL_FRONTEND" = "200" ]; then
    echo "  ✅ Frontend (localhost:3001): OK"
else
    echo "  ❌ Frontend (localhost:3001): FAILED (HTTP $LOCAL_FRONTEND)"
fi

if [ "$LOCAL_BACKEND" = "200" ]; then
    echo "  ✅ Backend (localhost:8087): OK"
else
    echo "  ❌ Backend (localhost:8087): FAILED (HTTP $LOCAL_BACKEND)"
fi
echo ""

echo "=== Step 2: Test from Network IP ==="
NETWORK_FRONTEND=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://$SERVER_IP:3001/ 2>/dev/null)
NETWORK_BACKEND=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 http://$SERVER_IP:8087/api/v1.0/health 2>/dev/null)

if [ "$NETWORK_FRONTEND" = "200" ]; then
    echo "  ✅ Frontend ($SERVER_IP:3001): OK"
else
    echo "  ⚠️  Frontend ($SERVER_IP:3001): May need testing from another device"
fi

if [ "$NETWORK_BACKEND" = "200" ]; then
    echo "  ✅ Backend ($SERVER_IP:8087): OK"
else
    echo "  ⚠️  Backend ($SERVER_IP:8087): May need testing from another device"
fi
echo ""

echo "=== Step 3: Monitor for External Requests ==="
echo "Starting request monitor (will show requests from other devices)..."
echo "Press Ctrl+C to stop"
echo ""
echo "Waiting for requests from smartphone/laptop..."
echo ""

# Clear previous logs
docker logs pos-shop-frontend --tail 0 > /dev/null 2>&1

# Monitor logs for new requests
timeout 60 docker logs -f pos-shop-frontend 2>&1 | while IFS= read -r line; do
    # Check if line contains an IP that's not the server or localhost
    if echo "$line" | grep -qE "192\.168\.80\.(1[0-9][0-9]|[2-9][0-9]|1[0-1][0-9])"; then
        EXTERNAL_IP=$(echo "$line" | grep -oE "192\.168\.80\.([0-9]{1,3})" | head -1)
        if [ "$EXTERNAL_IP" != "$SERVER_IP" ]; then
            echo "  ✅ REQUEST DETECTED from: $EXTERNAL_IP"
            echo "     $line"
            echo ""
        fi
    fi
done || echo "Monitor stopped (60 seconds timeout or Ctrl+C)"

echo ""
echo "=== Step 4: Check Recent Logs ==="
echo "Last 10 requests:"
docker logs pos-shop-frontend --tail 10 2>&1 | grep -E "GET|POST|OPTIONS" | tail -5
echo ""

echo "=========================================="
echo "  Testing Instructions"
echo "=========================================="
echo ""
echo "From your smartphone/laptop:"
echo ""
echo "1. Connect to the same Wi-Fi network (192.168.80.x)"
echo ""
echo "2. Open browser and go to:"
echo "   http://$SERVER_IP:3001"
echo ""
echo "3. Try to login:"
echo "   Email: admin@abv.bg"
echo "   Password: 123456"
echo ""
echo "4. Check browser console (F12):"
echo "   - If you see CORS errors → Backend CORS issue"
echo "   - If you see 'Network Error' → Network isolation (AP Isolation)"
echo "   - If you see 'Connection refused' → Firewall blocking"
echo ""
echo "5. While testing, run this script to see if requests reach the server"
echo ""
echo "=========================================="

