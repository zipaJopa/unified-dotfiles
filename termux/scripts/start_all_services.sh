#!/data/data/com.termux/files/usr/bin/bash
# Master Service Starter for Bojana Node
# Starts all network services with proper binding

echo "🚀 Starting Bojana Node Services..."
echo "===================================="

# Get network info
WLAN_IP=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
echo "📡 Network IP: $WLAN_IP"
echo ""

# Enable IP forwarding
echo "⚙️  Enabling IP forwarding..."
/debug_ramdisk/su -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
echo "✅ IP forwarding enabled"
echo ""

# Kill existing services
echo "🔄 Stopping existing services..."
pkill -f agent.py 2>/dev/null
pkill -f sshd 2>/dev/null
echo "✅ Existing services stopped"
echo ""

# Start Agent
echo "🤖 Starting Bojana Agent (port 8000)..."
cd ~
nohup python ~/agent.py > ~/agent.log 2>&1 &
AGENT_PID=$!
sleep 2

if ps -p $AGENT_PID > /dev/null; then
    echo "✅ Agent started (PID: $AGENT_PID)"
    echo "   Access: http://$WLAN_IP:8000/"
else
    echo "❌ Agent failed to start"
    cat ~/agent.log
fi
echo ""

# Start SSH (if installed)
if command -v sshd &> /dev/null; then
    echo "🔐 Starting SSH server..."
    sshd
    if pgrep sshd > /dev/null; then
        echo "✅ SSH server started"
        echo "   Access: ssh -p 8022 $WLAN_IP"
    else
        echo "❌ SSH server failed to start"
    fi
else
    echo "ℹ️  SSH not installed (pkg install openssh)"
fi
echo ""

# Summary
echo "===================================="
echo "📊 Service Summary:"
echo "   Agent:  http://$WLAN_IP:8000/"
echo "   SSH:    ssh -p 8022 $WLAN_IP"
echo ""
echo "🔍 Check status: ps aux | grep -E '(agent|sshd)'"
echo "📝 View logs:    tail -f ~/agent.log"
echo "===================================="
