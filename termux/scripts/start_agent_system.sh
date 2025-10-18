#!/data/data/com.termux/files/usr/bin/bash
# Master Agent System Starter
# Starts Bojana coordinator and all node agents

echo "🌟 Starting Agent System..."
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get network IP
get_ip() {
    /debug_ramdisk/su -c 'ip addr show wlan0' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 2>/dev/null || echo "N/A"
}

WLAN_IP=$(get_ip)
echo -e "${GREEN}📡 Network IP: $WLAN_IP${NC}"
echo ""

# Kill existing agents
echo "🔄 Stopping existing agents..."
pkill -f bojana_coordinator.py 2>/dev/null
pkill -f node_agent.py 2>/dev/null
sleep 2
echo -e "${GREEN}✓ Stopped${NC}"
echo ""

# Start Bojana Coordinator
echo "🌟 Starting Bojana Coordinator..."
cd ~
nohup python bojana_coordinator.py > bojana.log 2>&1 &
BOJANA_PID=$!
sleep 3

if ps -p $BOJANA_PID > /dev/null; then
    echo -e "${GREEN}✓ Bojana started (PID: $BOJANA_PID)${NC}"
    echo "   Access: http://$WLAN_IP:8000/"
else
    echo -e "${RED}✗ Bojana failed to start${NC}"
    cat ~/bojana.log | tail -10
    exit 1
fi
echo ""

# Start Node1 Agent
echo "🤖 Starting Node1 Agent..."
nohup python node_agent.py node1 8001 http://localhost:8000 > node1.log 2>&1 &
NODE1_PID=$!
sleep 3

if ps -p $NODE1_PID > /dev/null; then
    echo -e "${GREEN}✓ Node1 started (PID: $NODE1_PID)${NC}"
    echo "   Access: http://$WLAN_IP:8001/"
else
    echo -e "${YELLOW}⚠ Node1 failed to start${NC}"
    cat ~/node1.log | tail -10
fi
echo ""

# Summary
echo "================================"
echo -e "${GREEN}📊 Agent System Status:${NC}"
echo ""
echo "Coordinator:"
curl -s http://localhost:8000/ | python -m json.tool 2>/dev/null || echo "  Not responding"
echo ""
echo "Registered Nodes:"
curl -s http://localhost:8000/nodes | python -m json.tool 2>/dev/null || echo "  Not responding"
echo ""
echo "================================"
echo -e "${GREEN}✓ Agent System Ready!${NC}"
echo ""
echo "Commands:"
echo "  Status:  curl http://localhost:8000/"
echo "  Nodes:   curl http://localhost:8000/nodes"
echo "  Stop:    pkill -f bojana_coordinator && pkill -f node_agent"
echo ""
