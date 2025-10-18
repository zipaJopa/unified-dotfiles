#!/data/data/com.termux/files/usr/bin/bash
# MASTER SETUP - One command to rule them all

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

clear

echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║          🔥 MASTER ELITE SETUP 🔥                ║
║                                                   ║
║      Automated System Optimization Suite         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Check root
if ! su -c "echo test" &>/dev/null; then
    echo -e "${RED}✗ Root access required!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Root access: Active${NC}"
echo -e "${GREEN}✓ Device: $(getprop ro.product.model)${NC}"
echo -e "${GREEN}✓ Android: $(getprop ro.build.version.release)${NC}"
echo -e "${GREEN}✓ Magisk: $(su -c 'magisk -v' 2>/dev/null || echo 'N/A')${NC}\n"

# Menu
echo -e "${YELLOW}Select setup mode:${NC}"
echo ""
echo "  ${BLUE}1.${NC} FULL AUTO - Do everything (Recommended)"
echo "  ${BLUE}2.${NC} Optimization Only - System tweaks"
echo "  ${BLUE}3.${NC} Debloat Only - Remove bloatware"
echo "  ${BLUE}4.${NC} Magisk Modules - Auto install modules"
echo "  ${BLUE}5.${NC} Backup Only - Backup configs"
echo "  ${BLUE}6.${NC} Custom - Choose what to run"
echo ""
read -p "Enter choice [1-6]: " mode

echo ""

case $mode in
    1)
        echo -e "${PURPLE}═══ FULL AUTO MODE ACTIVATED ═══${NC}\n"

        # Backup first
        echo -e "${BLUE}→ Creating backup...${NC}"
        bash ~/scripts/quick-backup.sh
        echo ""

        # Debloat
        echo -e "${BLUE}→ Running debloat...${NC}"
        bash ~/scripts/auto-debloat.sh
        echo ""

        # Optimize
        echo -e "${BLUE}→ System optimization...${NC}"
        bash ~/scripts/elite-optimization.sh
        echo ""

        # Magisk modules
        echo -e "${BLUE}→ Installing Magisk modules...${NC}"
        echo "4" | bash ~/scripts/auto-install-magisk-modules.sh
        echo ""
        ;;

    2)
        echo -e "${BLUE}→ Running optimization...${NC}"
        bash ~/scripts/elite-optimization.sh
        ;;

    3)
        echo -e "${BLUE}→ Running debloat...${NC}"
        bash ~/scripts/auto-debloat.sh
        ;;

    4)
        echo -e "${BLUE}→ Installing Magisk modules...${NC}"
        bash ~/scripts/auto-install-magisk-modules.sh
        ;;

    5)
        echo -e "${BLUE}→ Creating backup...${NC}"
        bash ~/scripts/quick-backup.sh
        ;;

    6)
        echo -e "${YELLOW}Custom mode:${NC}"
        echo ""
        read -p "Run backup? [y/N]: " do_backup
        read -p "Run debloat? [y/N]: " do_debloat
        read -p "Run optimization? [y/N]: " do_optimize
        read -p "Install Magisk modules? [y/N]: " do_magisk
        echo ""

        [[ "$do_backup" =~ ^[Yy]$ ]] && bash ~/scripts/quick-backup.sh && echo ""
        [[ "$do_debloat" =~ ^[Yy]$ ]] && bash ~/scripts/auto-debloat.sh && echo ""
        [[ "$do_optimize" =~ ^[Yy]$ ]] && bash ~/scripts/elite-optimization.sh && echo ""
        [[ "$do_magisk" =~ ^[Yy]$ ]] && bash ~/scripts/auto-install-magisk-modules.sh && echo ""
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Final summary
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}║              ✓ SETUP COMPLETE!                   ║${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Your system is now optimized!${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  elite-optimize  - Run optimization"
echo "  debloat         - Remove bloatware"
echo "  mm list         - List Magisk modules"
echo "  sysinfo         - System information"
echo "  quickbackup     - Backup configs"
echo ""
echo -e "${PURPLE}Type 'fish' to switch to Fish shell${NC}"
echo -e "${PURPLE}All aliases and functions are ready!${NC}"
echo ""

# Offer reboot if modules were installed
if [[ $mode == 1 ]] || [[ $mode == 4 ]]; then
    echo -e "${YELLOW}⚠️  Reboot recommended to activate Magisk modules${NC}"
    read -p "Reboot now? [y/N]: " do_reboot
    [[ "$do_reboot" =~ ^[Yy]$ ]] && su -c "svc power reboot"
fi
