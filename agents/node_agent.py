#!/usr/bin/env python3
"""
A2A Node Agent (Lightweight Version)
Worker agent that registers with Bojana and executes tasks
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import subprocess
import threading
import time
import socket
from datetime import datetime
from urllib.parse import urlparse
import urllib.request

class NodeAgent:
    """Node agent state and functionality"""

    def __init__(self, node_id, coordinator_url, port, capabilities=None):
        self.node_id = node_id
        self.coordinator_url = coordinator_url
        self.port = port
        self.capabilities = capabilities or []
        self.status = 'starting'
        self.tasks = {}

    def register(self):
        """Register with coordinator"""
        try:
            data = json.dumps({
                'node_id': self.node_id,
                'capabilities': self.capabilities,
                'hostname': socket.gethostname(),
                'ip': self._get_local_ip(),
                'port': self.port
            }).encode()

            req = urllib.request.Request(
                f"{self.coordinator_url}/nodes/register",
                data=data,
                headers={'Content-Type': 'application/json'}
            )

            with urllib.request.urlopen(req, timeout=5) as response:
                result = json.loads(response.read().decode())
                self.status = 'online'
                return result

        except Exception as e:
            print(f"❌ Registration failed: {e}")
            self.status = 'offline'
            return None

    def _get_local_ip(self):
        """Get local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return "127.0.0.1"

    def execute_task(self, task_data):
        """Execute a task"""
        task_type = task_data.get('type')

        if task_type == 'command':
            return self._execute_command(task_data.get('command'))

        elif task_type == 'speak':
            return self._speak(task_data.get('text'))

        elif task_type == 'listen':
            return self._listen(task_data.get('duration', 5))

        elif task_type == 'system_info':
            return self._system_info()

        else:
            return {'error': f'Unknown task type: {task_type}'}

    def _execute_command(self, command):
        """Execute shell command"""
        try:
            result = subprocess.run(command, shell=True,
                                  capture_output=True, text=True, timeout=30)
            return {
                'success': True,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'returncode': result.returncode
            }
        except Exception as e:
            return {'error': str(e)}

    def _speak(self, text):
        """Text to speech using Google TTS (via wrapper)"""
        try:
            # Use TTS wrapper script (Google TTS with eSpeak fallback)
            subprocess.Popen(
                ['/data/data/com.termux/files/home/tts.sh', text, 'sr'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            return {'success': True, 'text': text, 'engine': 'google-tts', 'language': 'sr-RS'}
        except Exception as e:
            return {'error': str(e)}

    def _listen(self, duration):
        """Speech to text"""
        try:
            result = subprocess.run(
                ['termux-speech-to-text'],
                capture_output=True, text=True, timeout=duration + 5
            )
            return {
                'success': True,
                'transcript': result.stdout.strip()
            }
        except Exception as e:
            return {'error': str(e)}

    def _system_info(self):
        """Get system information"""
        info = {
            'node_id': self.node_id,
            'status': self.status,
            'capabilities': self.capabilities
        }

        # Battery info
        try:
            battery = subprocess.run(['termux-battery-status'],
                                   capture_output=True, text=True, timeout=2)
            if battery.returncode == 0:
                info['battery'] = json.loads(battery.stdout)
        except:
            pass

        return {'success': True, 'info': info}

# Global agent instance (will be set in main)
agent = None

class NodeHandler(BaseHTTPRequestHandler):
    """HTTP handler for node agent"""

    def _send_json(self, data, status=200):
        """Send JSON response"""
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode())

    def _get_body(self):
        """Read request body"""
        content_length = int(self.headers.get('Content-Length', 0))
        if content_length > 0:
            body = self.rfile.read(content_length)
            return json.loads(body.decode())
        return {}

    def do_GET(self):
        """Handle GET requests"""
        path = urlparse(self.path).path

        if path == '/' or path == '/status':
            self._send_json({
                'node_id': agent.node_id,
                'status': agent.status,
                'capabilities': agent.capabilities,
                'tasks': len(agent.tasks),
                'timestamp': datetime.now().isoformat()
            })

        elif path == '/health':
            self._send_json({
                'status': 'healthy' if agent.status == 'online' else 'unhealthy',
                'timestamp': datetime.now().isoformat()
            })

        else:
            self._send_json({'error': 'Not found'}, 404)

    def do_POST(self):
        """Handle POST requests"""
        path = urlparse(self.path).path
        body = self._get_body()

        if path == '/task':
            # Execute task
            result = agent.execute_task(body)
            self._send_json(result)

        elif path == '/speak':
            # Shortcut for speak
            text = body.get('text')
            if not text:
                self._send_json({'error': 'text required'}, 400)
                return
            result = agent._speak(text)
            self._send_json(result)

        elif path == '/listen':
            # Shortcut for listen
            duration = body.get('duration', 5)
            result = agent._listen(duration)
            self._send_json(result)

        else:
            self._send_json({'error': 'Not found'}, 404)

    def log_message(self, format, *args):
        """Custom logging"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {format % args}")

class ReuseAddrHTTPServer(HTTPServer):
    allow_reuse_address = True

def main(node_id, port=8001, coordinator_url="http://192.168.0.88:8000"):
    """Start node agent"""
    global agent

    # Initialize agent
    agent = NodeAgent(
        node_id=node_id,
        coordinator_url=coordinator_url,
        port=port,
        capabilities=['command', 'speak', 'listen', 'system_info']
    )

    print(f"🤖 Node Agent '{node_id}' Starting...")
    print(f"   Port: {port}")
    print(f"   Coordinator: {coordinator_url}")
    print(f"   Capabilities: {', '.join(agent.capabilities)}")
    print()

    # Register with coordinator
    print("📡 Registering with Bojana...")
    result = agent.register()
    if result:
        print(f"✅ Registered successfully!")
        print(f"   Response: {json.dumps(result, indent=2)}")
    else:
        print("⚠️  Registration failed, but continuing...")

    print(f"\n🚀 Node agent ready on port {port}!\n")

    # Start HTTP server
    server = ReuseAddrHTTPServer(('0.0.0.0', port), NodeHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print(f"\n👋 Node '{node_id}' shutting down...")
        server.shutdown()

if __name__ == "__main__":
    import sys

    # Get node_id from command line or use default
    node_id = sys.argv[1] if len(sys.argv) > 1 else "node1"
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8001
    coordinator = sys.argv[3] if len(sys.argv) > 3 else "http://192.168.0.88:8000"

    main(node_id, port, coordinator)
