#!/data/data/com.termux/files/usr/bin/bash
# TTS Variants - Test different voice qualities

TEXT="${1:-Zdravo Boban! Ovo je test različitih glasova.}"

echo "=== TTS VARIANT TEST ==="
echo ""
echo "1. Default (Stephen Hawking mode)"
espeak -v sr "$TEXT" --stdout | play -t wav -q - 2>/dev/null
sleep 1

echo "2. Niži glas, sporije (muški glas)"
espeak -v sr -p 40 -s 130 -a 150 "$TEXT" --stdout | play -t wav -q - 2>/dev/null
sleep 1

echo "3. Viši glas, srednja brzina (ženski glas)"
espeak -v sr -p 60 -s 150 -a 140 "$TEXT" --stdout | play -t wav -q - 2>/dev/null
sleep 1

echo "4. Muška varijanta +m3"
espeak -v sr+m3 -s 140 -a 150 "$TEXT" --stdout | play -t wav -q - 2>/dev/null
sleep 1

echo "5. Whisper mode (tiši, sporiji)"
espeak -v sr+whisper -s 120 -a 100 "$TEXT" --stdout | play -t wav -q - 2>/dev/null

echo ""
echo "=== Test završen ==="
