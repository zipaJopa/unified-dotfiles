#!/usr/bin/env python3
"""
Voice Conversation Agent
Supports both real TTS/STT and simulated mode
"""

import subprocess
import json
import time
from datetime import datetime

class VoiceAgent:
    """Voice-enabled agent with fallback to text mode"""

    def __init__(self, use_real_voice=True):
        self.use_real_voice = use_real_voice
        self.conversation_history = []

        # Check if TTS is available
        if use_real_voice:
            self.tts_available = self._check_tts()
            self.stt_available = self._check_stt()
        else:
            self.tts_available = False
            self.stt_available = False

    def _check_tts(self):
        """Check if TTS is working"""
        try:
            result = subprocess.run(
                ['termux-tts-speak', '--help'],
                capture_output=True,
                timeout=2
            )
            return result.returncode == 0
        except:
            return False

    def _check_stt(self):
        """Check if STT is working"""
        try:
            result = subprocess.run(
                ['termux-speech-to-text', '--help'],
                capture_output=True,
                timeout=2
            )
            return result.returncode == 0
        except:
            return False

    def speak(self, text, use_tts=None):
        """Speak text (TTS or print)"""
        if use_tts is None:
            use_tts = self.tts_available

        timestamp = datetime.now().isoformat()

        if use_tts:
            try:
                # Non-blocking TTS with timeout - Serbian language
                subprocess.Popen(
                    ['termux-tts-speak', '-l', 'sr', text],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL
                )
                print(f"🔊 [{timestamp}] TTS (srpski): {text}")
            except Exception as e:
                print(f"💬 [{timestamp}] (TTS failed): {text}")
        else:
            print(f"💬 [{timestamp}] Bojana: {text}")

        self.conversation_history.append({
            'timestamp': timestamp,
            'type': 'speak',
            'text': text,
            'used_tts': use_tts
        })

        return text

    def listen(self, duration=5, use_stt=None):
        """Listen for speech (STT or keyboard input)"""
        if use_stt is None:
            use_stt = self.stt_available

        timestamp = datetime.now().isoformat()

        if use_stt:
            try:
                print(f"🎤 Listening for {duration}s...")
                result = subprocess.run(
                    ['termux-speech-to-text'],
                    capture_output=True,
                    text=True,
                    timeout=duration + 5
                )
                text = result.stdout.strip()
                print(f"👂 [{timestamp}] Heard: {text}")

                self.conversation_history.append({
                    'timestamp': timestamp,
                    'type': 'listen',
                    'text': text,
                    'used_stt': True
                })

                return text
            except Exception as e:
                print(f"❌ STT failed: {e}")
                return None
        else:
            # Keyboard input mode
            print(f"⌨️  [{timestamp}] Type your message:")
            text = input("> ")

            self.conversation_history.append({
                'timestamp': timestamp,
                'type': 'listen',
                'text': text,
                'used_stt': False
            })

            return text

    def process_command(self, text):
        """Process voice command"""
        text_lower = text.lower()

        # Simple command recognition
        if 'status' in text_lower or 'kako si' in text_lower:
            return "Ja sam odlično! Svi agenti su online i spremni za rad."

        elif 'ko si' in text_lower or 'predstavi se' in text_lower:
            return "Ja sam Bojana, tvoj agent koordinator. Upravljam mrežom distribuiranih agenata."

        elif 'vreme' in text_lower or 'sati' in text_lower:
            now = datetime.now().strftime("%H:%M")
            return f"Trenutno vreme je {now}."

        elif 'datum' in text_lower:
            today = datetime.now().strftime("%d.%m.%Y")
            return f"Današnji datum je {today}."

        elif 'hvala' in text_lower or 'thanks' in text_lower:
            return "Nema na čemu! Uvek sam tu da pomognem."

        elif 'cao' in text_lower or 'zdravo' in text_lower or 'hello' in text_lower:
            return "Zdravo! Kako mogu da ti pomognem danas?"

        elif 'exit' in text_lower or 'quit' in text_lower or 'kraj' in text_lower:
            return "STOP"

        else:
            return f"Čujem te! Rekao si: {text}"

    def conversation_loop(self):
        """Main conversation loop"""
        print("\n" + "="*60)
        print("🎤 VOICE CONVERSATION AGENT")
        print("="*60)
        print(f"TTS Available: {'✅' if self.tts_available else '❌ (keyboard mode)'}")
        print(f"STT Available: {'✅' if self.stt_available else '❌ (keyboard mode)'}")
        print("\nKomande:")
        print("  - 'status' / 'kako si'")
        print("  - 'ko si' / 'predstavi se'")
        print("  - 'vreme' / 'datum'")
        print("  - 'exit' / 'quit' - zaustavi")
        print("="*60 + "\n")

        # Greeting
        self.speak("Zdravo! Ja sam Bojana. Reci mi nešto!")

        while True:
            # Listen
            user_input = self.listen()

            if not user_input or user_input.strip() == "":
                self.speak("Nisam te čula. Možeš li ponoviti?")
                continue

            # Process
            response = self.process_command(user_input)

            # Check if user wants to exit
            if response == "STOP":
                self.speak("Doviđenja! Bilo mi je drago da pričam sa tobom.")
                break

            # Respond
            self.speak(response)
            time.sleep(0.5)  # Brief pause

        # Show conversation history
        print("\n" + "="*60)
        print("📜 CONVERSATION HISTORY")
        print("="*60)
        for entry in self.conversation_history:
            icon = "🔊" if entry['type'] == 'speak' else "👂"
            print(f"{icon} [{entry['timestamp']}] {entry['text']}")
        print("="*60 + "\n")

        return self.conversation_history

def demo_conversation():
    """Demo conversation with keyboard input"""
    print("🎭 DEMO MODE - Type your responses\n")

    agent = VoiceAgent(use_real_voice=False)

    # Simulated conversation
    demos = [
        ("Zdravo Bojana!", None),
        ("Ko si ti?", None),
        ("Koji je status sistema?", None),
        ("Hvala!", None),
        ("exit", None)
    ]

    agent.speak("Zdravo! Ja sam Bojana. Reci mi nešto!")

    for user_msg, _ in demos:
        print(f"\n⌨️  User types: {user_msg}")
        time.sleep(1)

        response = agent.process_command(user_msg)
        if response == "STOP":
            agent.speak("Doviđenja!")
            break
        agent.speak(response)
        time.sleep(1)

    return agent.conversation_history

if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "--demo":
        demo_conversation()
    else:
        agent = VoiceAgent(use_real_voice=True)
        agent.conversation_loop()
