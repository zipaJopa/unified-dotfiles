#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, socket, socketserver
from datetime import datetime

class AgentHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            status = {
                "node": "bojana",
                "device": "Moto G100",
                "rom": "Pixel Experience Android 14",
                "status": "ONLINE",
                "timestamp": datetime.now().isoformat(),
                "ip": socket.gethostbyname(socket.gethostname())
            }
            self.wfile.write(json.dumps(status, indent=2).encode())
    
    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {format % args}")

class ReuseAddrHTTPServer(HTTPServer):
    allow_reuse_address = True

if __name__ == "__main__":
    PORT = 8000
    HOST = '0.0.0.0'  # Bind to all interfaces
    print(f"🚀 Bojana Agent starting on {HOST}:{PORT}...")
    print(f"   Access from network: http://192.168.0.88:{PORT}")
    server = ReuseAddrHTTPServer((HOST, PORT), AgentHandler)
    server.serve_forever()
