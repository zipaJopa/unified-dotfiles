#!/data/data/com.termux/files/usr/bin/bash
# Google TTS wrapper for Serbian
# Usage: tts-google.sh "text to speak"

TEXT="$1"
ENGINE="com.google.android.tts"
LANG="sr-RS"
STREAM="MUSIC"

# Use Google TTS with Serbian language
termux-tts-speak -e "$ENGINE" -l "$LANG" -s "$STREAM" "$TEXT" &
