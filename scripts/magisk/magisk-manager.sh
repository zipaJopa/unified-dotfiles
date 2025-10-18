#!/data/data/com.termux/files/usr/bin/bash
# Magisk Module Manager CLI

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

case "$1" in
    list)
        echo -e "${GREEN}📦 Installed Magisk Modules:${NC}"
        echo "================================"
        su -c "for module in /data/adb/modules/*; do
            if [ -d \"\$module\" ] && [ -f \"\$module/module.prop\" ]; then
                name=\$(grep '^name=' \"\$module/module.prop\" | cut -d'=' -f2)
                version=\$(grep '^version=' \"\$module/module.prop\" | cut -d'=' -f2)
                echo \"  → \$name (v\$version)\"
            fi
        done"
        ;;

    install)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: magisk-manager install <path-to-module.zip>${NC}"
            exit 1
        fi

        if [ ! -f "$2" ]; then
            echo -e "${RED}Error: File not found: $2${NC}"
            exit 1
        fi

        echo -e "${YELLOW}Installing module: $2${NC}"
        su -c "magisk --install-module \"$2\""

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Module installed successfully!${NC}"
            echo -e "${YELLOW}Reboot required to activate.${NC}"
        else
            echo -e "${RED}✗ Installation failed!${NC}"
        fi
        ;;

    remove)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: magisk-manager remove <module-id>${NC}"
            exit 1
        fi

        MODULE_PATH="/data/adb/modules/$2"
        if [ ! -d "$MODULE_PATH" ]; then
            echo -e "${RED}Error: Module not found: $2${NC}"
            exit 1
        fi

        echo -e "${YELLOW}Removing module: $2${NC}"
        su -c "rm -rf \"$MODULE_PATH\""

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Module removed!${NC}"
            echo -e "${YELLOW}Reboot required.${NC}"
        else
            echo -e "${RED}✗ Removal failed!${NC}"
        fi
        ;;

    disable)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: magisk-manager disable <module-id>${NC}"
            exit 1
        fi

        MODULE_PATH="/data/adb/modules/$2"
        echo -e "${YELLOW}Disabling module: $2${NC}"
        su -c "touch \"$MODULE_PATH/disable\""
        echo -e "${GREEN}✓ Module disabled. Reboot required.${NC}"
        ;;

    enable)
        if [ -z "$2" ]; then
            echo -e "${RED}Usage: magisk-manager enable <module-id>${NC}"
            exit 1
        fi

        MODULE_PATH="/data/adb/modules/$2"
        echo -e "${YELLOW}Enabling module: $2${NC}"
        su -c "rm -f \"$MODULE_PATH/disable\""
        echo -e "${GREEN}✓ Module enabled. Reboot required.${NC}"
        ;;

    update)
        echo -e "${YELLOW}Checking for Magisk updates...${NC}"
        su -c "magisk -c"
        ;;

    info)
        echo -e "${GREEN}🔧 Magisk Info:${NC}"
        echo "================================"
        echo "  Version: $(su -c 'magisk -v')"
        echo "  Version Code: $(su -c 'magisk -V')"
        echo "  Modules Path: /data/adb/modules"
        echo "  Total Modules: $(su -c 'ls /data/adb/modules 2>/dev/null | wc -l')"
        ;;

    *)
        echo -e "${GREEN}Magisk Module Manager${NC}"
        echo "================================"
        echo "Usage: magisk-manager <command> [options]"
        echo ""
        echo "Commands:"
        echo "  list                    List installed modules"
        echo "  install <zip>           Install module from ZIP"
        echo "  remove <module-id>      Remove a module"
        echo "  disable <module-id>     Disable a module"
        echo "  enable <module-id>      Enable a module"
        echo "  update                  Check Magisk updates"
        echo "  info                    Show Magisk info"
        echo ""
        echo "Examples:"
        echo "  magisk-manager list"
        echo "  magisk-manager install ~/Downloads/module.zip"
        echo "  magisk-manager remove busybox-ndk"
        ;;
esac
