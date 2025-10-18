#!/data/data/com.termux/files/usr/bin/bash
# TERMUX → WSL AI GRID AUTO-JUMP
# Usage: ssh-ai-grid [tmate]

WSL_IP="100.89.14.93"  # Your WSL Tailscale IP
WSL_USER="bog"
TMATE_MODE="${1:-local}"

echo "🚀 Connecting to AI Grid..."
echo "   WSL: $WSL_USER@$WSL_IP"
echo ""

if [ "$TMATE_MODE" = "tmate" ]; then
    ssh -t $WSL_USER@$WSL_IP "ai-grid tmate"
else
    ssh -t $WSL_USER@$WSL_IP "ai-grid"
fi
