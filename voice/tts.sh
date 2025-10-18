#!/data/data/com.termux/files/usr/bin/bash
# TTS wrapper using Google TTS (with eSpeak fallback)
# Usage: tts.sh "text to speak" [language_code]

TEXT="$1"
LANG="${2:-sr}"  # Default to Serbian

# Try Google TTS first (better quality)
if command -v termux-tts-speak &> /dev/null; then
    ENGINE="com.google.android.tts"

    # Map language codes
    case "$LANG" in
        sr|serbian) LANG_CODE="sr-RS" ;;
        en|english) LANG_CODE="en-US" ;;
        *) LANG_CODE="$LANG" ;;
    esac

    # Use Google TTS (non-blocking)
    termux-tts-speak -e "$ENGINE" -l "$LANG_CODE" -s MUSIC "$TEXT" &
else
    # Fallback to espeak if termux-tts-speak not available
    espeak -v sr -s 150 "$TEXT" --stdout | play -t wav -q - 2>/dev/null &
fi
