#!/data/data/com.termux/files/usr/bin/bash
sshd 2>/dev/null
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbPNps18N6PR50iW1Lnymqv+ezzOe/TrxM4pFlN9wUV9cgMryXjqTIqjhuMPK8UU1V5sVHxttCslAcWuohUR2v1roiJs7E/GaCBF9Eog5X/uruHd4of7wS1r/PKQpCjyOYmBHucZRtCIanDoRV0EgTXs/4hgu4iYcGQpnw2upJBqxDhIJ7UiBnGrMDN1ehZBf8kbR2s6TZ9zjVMulVXh3X7j/XsWyT8qtLcdmmH0+K4Xnlb57vts14xTwQ0N/SBKjZ1Jc//mpZ8TAfJAP7xURXz1LQeENkVFhazbNWTjS0qW+7v9PLO1C8A9qQUjMtZk93yY6p3vyEIzsAFRaXZM7O1y3R1i+RoQ7lKiwTefLNvml3rtWDHxKQslk0XF3LyLPDy0Rjrt75op3pJ6GLWk3Eh8py8stcDZqglUofn9gJJB8nWWQ0JCNzYqLicBRz0y7gxRUQyzifVfKXuk/VQfClTq15/oKXklV0yjm9kIsk3lg0cC6hpLFGPl7c7vu3xihCkz5QaQChQg89ZntcD+FiWa9NuM0ebEmElQph4k0Ke0NY7YpMZJsdg3gQqxtaWBra2Eo+Sslg0rNBdos+QkdbXgpNL+5F54la2PghaikMvmku+WlHnzPUX13w3AltSLrqTtrc/jPUiLpHyWnnw+lsOvGayMHcwUCr6yshaP4uGw== u0_a302@localhost" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "alias deki='ssh u0_a302@192.168.0.88'" >> ~/.config/fish/config.fish
sshd 2>/dev/null
echo "✅ BOJANA setup done! Type 'deki' to connect"
