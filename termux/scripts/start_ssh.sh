#!/data/data/com.termux/files/usr/bin/bash
# Start SSH server on port 8022

echo "🔐 Starting SSH server on port 8022..."
sshd

# Check if running
if pgrep -x sshd > /dev/null; then
    echo "✅ SSH server running!"
    echo ""
    echo "Connect from PC:"
    echo "ssh -p 8022 $(whoami)@$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')"
else
    echo "❌ SSH server failed to start!"
fi
