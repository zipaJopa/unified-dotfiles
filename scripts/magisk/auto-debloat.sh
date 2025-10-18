#!/data/data/com.termux/files/usr/bin/bash
# Auto Debloat Script - Removes common bloatware

echo "🔥 Starting auto-debloat..."

# Common bloatware packages
BLOAT=(
    "com.facebook.katana"
    "com.facebook.system"
    "com.facebook.appmanager"
    "com.google.android.apps.tachyon"
    "com.google.android.apps.docs"
    "com.google.android.music"
    "com.google.android.videos"
    "com.android.chrome"
    "com.google.android.apps.youtube.music"
    "com.netflix.mediaclient"
    "com.microsoft.office.outlook"
    "com.microsoft.office.word"
    "com.microsoft.office.excel"
    "com.android.bips"
    "com.android.printspooler"
)

for app in "${BLOAT[@]}"; do
    echo "Checking: $app"
    if su -c "pm list packages | grep -q $app"; then
        echo "  → Disabling $app"
        su -c "pm disable-user --user 0 $app"
    else
        echo "  → Not found, skipping"
    fi
done

echo "✅ Debloat complete!"
