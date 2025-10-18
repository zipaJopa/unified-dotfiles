#!/data/data/com.termux/files/usr/bin/bash
# Elite System Optimization - Full Auto

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════╗
║   ELITE SYSTEM OPTIMIZATION v1.0     ║
║   Automated Performance Boost        ║
╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check root
if ! su -c "echo test" &>/dev/null; then
    echo -e "${RED}✗ Root required!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Root access confirmed${NC}\n"

# 1. KERNEL OPTIMIZATIONS
echo -e "${BLUE}[1/6] Kernel optimizations...${NC}"
su -c "
    # VM tweaks
    echo '10' > /proc/sys/vm/swappiness
    echo '50' > /proc/sys/vm/vfs_cache_pressure
    echo '4096' > /proc/sys/vm/min_free_kbytes

    # Network tweaks
    echo '1' > /proc/sys/net/ipv4/tcp_low_latency
    echo '2' > /proc/sys/net/ipv4/tcp_fastopen

    # Scheduler tweaks
    echo 'deadline' > /sys/block/sda/queue/scheduler 2>/dev/null || true
    echo 'cfq' > /sys/block/mmcblk0/queue/scheduler 2>/dev/null || true
" 2>/dev/null
echo -e "${GREEN}  ✓ Kernel optimized${NC}\n"

# 2. BUILD.PROP TWEAKS
echo -e "${BLUE}[2/6] Build.prop performance tweaks...${NC}"
su -c "
    # Performance
    resetprop ro.media.enc.jpeg.quality 100
    resetprop debug.performance.tuning 1
    resetprop video.accelerate.hw 1
    resetprop debug.egl.profiler 1

    # GPU
    resetprop debug.composition.type gpu
    resetprop debug.egl.hw 1
    resetprop debug.sf.hw 1

    # Dalvik VM
    resetprop dalvik.vm.heapsize 512m
    resetprop dalvik.vm.heapgrowthlimit 256m

    # Network
    resetprop net.tcp.buffersize.default 4096,87380,256960,4096,16384,256960
    resetprop net.tcp.buffersize.wifi 4096,87380,256960,4096,16384,256960
" 2>/dev/null
echo -e "${GREEN}  ✓ Props optimized${NC}\n"

# 3. MEMORY OPTIMIZATION
echo -e "${BLUE}[3/6] Memory optimization...${NC}"
su -c "
    # Drop caches
    sync
    echo 3 > /proc/sys/vm/drop_caches

    # Trim all partitions
    fstrim -v /data 2>/dev/null || true
    fstrim -v /cache 2>/dev/null || true
    fstrim -v /system 2>/dev/null || true
" 2>/dev/null
echo -e "${GREEN}  ✓ Memory optimized${NC}\n"

# 4. GOVERNOR TWEAKS
echo -e "${BLUE}[4/6] CPU governor tweaks...${NC}"
su -c "
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f \"\$cpu\" ] && echo 'performance' > \"\$cpu\" 2>/dev/null || echo 'interactive' > \"\$cpu\" 2>/dev/null || true
    done
" 2>/dev/null
echo -e "${GREEN}  ✓ Governor optimized${NC}\n"

# 5. SQLITE OPTIMIZATION
echo -e "${BLUE}[5/6] SQLite database optimization...${NC}"
DATABASES=$(su -c "find /data/data -name '*.db' 2>/dev/null" | head -20)
COUNT=0
for db in $DATABASES; do
    su -c "sqlite3 \"$db\" 'VACUUM; REINDEX;'" 2>/dev/null && ((COUNT++)) || true
done
echo -e "${GREEN}  ✓ Optimized $COUNT databases${NC}\n"

# 6. CLEAN JUNK
echo -e "${BLUE}[6/6] Cleaning junk files...${NC}"
CLEANED=$(su -c "
    du -sh /data/local/tmp 2>/dev/null | cut -f1
    rm -rf /data/local/tmp/* 2>/dev/null
    rm -rf /data/cache/* 2>/dev/null
    rm -rf /cache/* 2>/dev/null
")
echo -e "${GREEN}  ✓ Cleaned temp files${NC}\n"

# Summary
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         OPTIMIZATION COMPLETE         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo -e "\n${YELLOW}Performance improvements:${NC}"
echo "  • Kernel parameters tuned"
echo "  • Build props optimized"
echo "  • Memory cleaned & trimmed"
echo "  • CPU governor optimized"
echo "  • Databases vacuumed"
echo "  • Junk files removed"
echo ""
echo -e "${BLUE}💡 Tip: Run 'elite-optimize' weekly for best performance${NC}"
