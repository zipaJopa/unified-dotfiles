#!/data/data/com.termux/files/usr/bin/bash
# Autostart script for Bojana agent

echo "🚀 Starting Bojana services..."

# Start SSH server
if command -v sshd &> /dev/null; then
    sshd
    echo "✅ SSH server started on port 8022"
else
    echo "⚠️  SSH not installed - run: pkg install openssh"
fi

# Start agent
if [ -f ~/agent.py ]; then
    python ~/agent.py &
    echo "✅ Agent started on port 8000"
else
    echo "⚠️  Agent script not found"
fi

echo "📡 Bojana is ONLINE"
