#!/usr/bin/env python3
"""
Voice Conversation System - Priča sa Bojanom bez kucanja!
Wake word: "Hej Bojana" ili "Bojana"
"""

import subprocess
import json
import time
import sys
import urllib.request
import re

class VoiceConversation:
    def __init__(self, agent_url="http://localhost:8001"):
        self.agent_url = agent_url
        self.wake_words = ["bojana", "hej bojana", "hey bojana"]
        self.exit_words = ["izađi", "izadji", "kraj", "stop", "exit"]

    def speak(self, text):
        """TTS - Bojana govori"""
        print(f"🗣️  Bojana: {text}")
        subprocess.Popen(
            ['/data/data/com.termux/files/home/tts.sh', text, 'sr'],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

    def listen(self, duration=5):
        """STT - Sluša korisnika"""
        print(f"🎤 Slušam... ({duration}s)")
        try:
            result = subprocess.run(
                ['termux-speech-to-text'],
                capture_output=True,
                text=True,
                timeout=duration + 3
            )
            text = result.stdout.strip().lower()
            if text:
                print(f"👤 Ti: {text}")
            return text
        except Exception as e:
            print(f"❌ STT greška: {e}")
            return ""

    def check_wake_word(self, text):
        """Provera da li je rekao wake word"""
        text_lower = text.lower()
        for word in self.wake_words:
            if word in text_lower:
                return True
        return False

    def check_exit(self, text):
        """Provera da li želi da izađe"""
        text_lower = text.lower()
        for word in self.exit_words:
            if word in text_lower:
                return True
        return False

    def process_command(self, text):
        """Obradi komandu i vrati odgovor"""
        text_lower = text.lower()

        # Status komande
        if any(word in text_lower for word in ["status", "kako si", "šta radiš", "sta radis"]):
            try:
                response = urllib.request.urlopen(f"{self.agent_url}/status", timeout=3)
                data = json.loads(response.read().decode())
                return f"Ja sam {data['node_id']}, status {data['status']}, imam {len(data['capabilities'])} mogućnosti."
            except:
                return "Izvini, ne mogu da pristupim statusu."

        # Info o sebi
        elif any(word in text_lower for word in ["ko si", "predstavi se"]):
            return "Ja sam Bojana, tvoj AI agent koordinator. Mogu da izvršavam komande, govorim, slušam i upravljam ostalim agentima."

        # Vreme
        elif any(word in text_lower for word in ["koliko je sati", "vreme", "koji je sat"]):
            from datetime import datetime
            now = datetime.now()
            return f"Sada je {now.hour} časova i {now.minute} minuta."

        # Baterija
        elif "baterija" in text_lower:
            try:
                result = subprocess.run(['termux-battery-status'],
                                      capture_output=True, text=True, timeout=2)
                battery = json.loads(result.stdout)
                return f"Baterija je {battery['percentage']} procenata, status {battery['status']}"
            except:
                return "Ne mogu da proverim bateriju."

        # Izvršavanje komandi
        elif "izvrši" in text_lower or "izvršavaj" in text_lower or "pokreni" in text_lower:
            # Ekstraktuj komandu posle ključne reči
            command = re.sub(r'.*(izvrši|izvršavaj|pokreni)\s+', '', text_lower)
            return f"Izvršavam komandu: {command}"

        # Default - ne razume
        else:
            return "Nisam razumela. Možeš da me pitaš za status, vreme, bateriju, ili da izvršim neku komandu."

    def run(self):
        """Glavni loop - čeka wake word i konverzacija"""
        print("=" * 50)
        print("🎙️  VOICE CONVERSATION SISTEM")
        print("=" * 50)
        print("\n📋 UPUTSTVO:")
        print("  1. Reci 'Hej Bojana' ili 'Bojana' da me aktiviraš")
        print("  2. Postavi pitanje ili komandu")
        print("  3. Reci 'kraj' ili 'izađi' da završiš")
        print("\n💡 PRIMERI:")
        print("  - 'Bojana, kako si?'")
        print("  - 'Bojana, koliko je sati?'")
        print("  - 'Bojana, koliko je baterija?'")
        print("  - 'Bojana, ko si ti?'")
        print("\n" + "=" * 50)

        self.speak("Sistem za glasovnu konverzaciju je aktivan. Reci 'hej Bojana' kad si spremna.")

        wake_word_mode = True
        conversation_timeout = time.time()

        while True:
            try:
                if wake_word_mode:
                    print("\n💤 Čekam wake word 'Hej Bojana'...")
                    text = self.listen(duration=10)

                    if not text:
                        continue

                    if self.check_wake_word(text):
                        print("✅ Wake word detektovan!")
                        self.speak("Da, slušam te!")
                        wake_word_mode = False
                        conversation_timeout = time.time() + 120  # 2 min conversation timeout
                        continue
                else:
                    # Conversation mode
                    if time.time() > conversation_timeout:
                        print("⏰ Conversation timeout")
                        self.speak("Vraćam se u režim spavanja.")
                        wake_word_mode = True
                        continue

                    print("\n🎤 Slušam tvoju komandu...")
                    text = self.listen(duration=8)

                    if not text:
                        print("⚠️  Nisam čula ništa...")
                        time.sleep(1)
                        continue

                    # Check za exit
                    if self.check_exit(text):
                        self.speak("Vraćam se u režim spavanja. Pozovi me kad zatreba!")
                        wake_word_mode = True
                        continue

                    # Proveri wake word again (može da nastavi razgovor)
                    if self.check_wake_word(text):
                        # Ukloni wake word iz teksta
                        for word in self.wake_words:
                            text = text.replace(word, "").strip()

                    # Obradi komandu
                    if text:
                        response = self.process_command(text)
                        self.speak(response)
                        conversation_timeout = time.time() + 120  # Reset timeout

            except KeyboardInterrupt:
                print("\n\n👋 Završavam...")
                self.speak("Doviđenja!")
                break
            except Exception as e:
                print(f"❌ Greška: {e}")
                time.sleep(2)

if __name__ == "__main__":
    conv = VoiceConversation()
    conv.run()
