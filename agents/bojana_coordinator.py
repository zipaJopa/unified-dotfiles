#!/usr/bin/env python3
"""
Bojana - A2A Coordinator Server (Lightweight Version)
Coordinates tasks between multiple agent nodes
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import time
import uuid
from datetime import datetime
from urllib.parse import urlparse, parse_qs
import threading
import subprocess
import urllib.request

class A2ACoordinator:
    """Simple in-memory task and node management"""

    def __init__(self):
        self.nodes = {}  # node_id -> node_info
        self.tasks = {}  # task_id -> task_info
        self.lock = threading.Lock()

    def register_node(self, node_id, node_info):
        """Register a new agent node"""
        with self.lock:
            self.nodes[node_id] = {
                **node_info,
                'registered_at': datetime.now().isoformat(),
                'last_heartbeat': datetime.now().isoformat()
            }
            return True

    def get_nodes(self):
        """Get all registered nodes"""
        with self.lock:
            return list(self.nodes.values())

    def create_task(self, task_data):
        """Create a new task"""
        task_id = str(uuid.uuid4())
        with self.lock:
            self.tasks[task_id] = {
                'id': task_id,
                'status': 'pending',
                'created_at': datetime.now().isoformat(),
                **task_data
            }
        return task_id

    def get_task(self, task_id):
        """Get task by ID"""
        with self.lock:
            return self.tasks.get(task_id)

    def update_task(self, task_id, updates):
        """Update task status"""
        with self.lock:
            if task_id in self.tasks:
                self.tasks[task_id].update(updates)
                self.tasks[task_id]['updated_at'] = datetime.now().isoformat()
                return True
        return False

    def select_node(self, required_capability=None):
        """Select a node for task execution"""
        with self.lock:
            available_nodes = []
            for node_id, node_info in self.nodes.items():
                # Check if node has required capability
                if required_capability:
                    if required_capability in node_info.get('capabilities', []):
                        available_nodes.append(node_info)
                else:
                    available_nodes.append(node_info)

            # Simple round-robin: return first available
            return available_nodes[0] if available_nodes else None

    def delegate_task(self, task_data):
        """Delegate task to appropriate node"""
        # Determine required capability from task type
        task_type = task_data.get('type')
        required_capability = task_type if task_type else None

        # Select node
        node = self.select_node(required_capability)
        if not node:
            return {
                'success': False,
                'error': f'No node available with capability: {required_capability}'
            }

        # Create task
        task_id = self.create_task({
            **task_data,
            'node_id': node['node_id'],
            'status': 'delegating'
        })

        # Send task to node
        try:
            node_ip = node.get('ip', 'localhost')
            node_port = node.get('port', 8001)  # Get port from node registration

            # Build node URL - try localhost first
            node_url = f"http://localhost:{node_port}/task"

            data = json.dumps(task_data).encode()
            req = urllib.request.Request(
                node_url,
                data=data,
                headers={'Content-Type': 'application/json'}
            )

            with urllib.request.urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode())

                # Update task with result
                self.update_task(task_id, {
                    'status': 'completed',
                    'result': result,
                    'completed_at': datetime.now().isoformat()
                })

                return {
                    'success': True,
                    'task_id': task_id,
                    'node_id': node['node_id'],
                    'result': result
                }

        except Exception as e:
            # Update task as failed
            self.update_task(task_id, {
                'status': 'failed',
                'error': str(e),
                'failed_at': datetime.now().isoformat()
            })

            return {
                'success': False,
                'task_id': task_id,
                'error': str(e)
            }

# Global coordinator instance
coordinator = A2ACoordinator()

class BojanaHandler(BaseHTTPRequestHandler):
    """HTTP handler for Bojana coordinator"""

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

        if path == '/' or path == '/index.html' or path == '/dashboard.html':
            # Serve dashboard HTML
            try:
                with open('/data/data/com.termux/files/home/dashboard.html', 'r') as f:
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()
                    self.wfile.write(f.read().encode())
                return
            except:
                pass  # Fall through to status endpoint

        if path == '/status' or path == '/api':
            # Status endpoint
            self._send_json({
                'name': 'bojana',
                'role': 'coordinator',
                'status': 'ONLINE',
                'nodes': len(coordinator.nodes),
                'tasks': len(coordinator.tasks),
                'timestamp': datetime.now().isoformat()
            })

        elif path == '/nodes':
            # List all nodes
            self._send_json({
                'nodes': coordinator.get_nodes()
            })

        elif path.startswith('/tasks/'):
            # Get specific task
            task_id = path.split('/')[-1]
            task = coordinator.get_task(task_id)
            if task:
                self._send_json(task)
            else:
                self._send_json({'error': 'Task not found'}, 404)

        elif path == '/tasks':
            # List all tasks
            self._send_json({
                'tasks': list(coordinator.tasks.values())
            })

        elif path == '/system':
            # System info
            try:
                battery = subprocess.run(['termux-battery-status'],
                                       capture_output=True, text=True, timeout=2)
                battery_info = json.loads(battery.stdout) if battery.returncode == 0 else {}
            except:
                battery_info = {}

            self._send_json({
                'device': 'Moto G100',
                'rom': 'Pixel Experience Android 14',
                'battery': battery_info,
                'timestamp': datetime.now().isoformat()
            })

        else:
            self._send_json({'error': 'Not found'}, 404)

    def do_POST(self):
        """Handle POST requests"""
        path = urlparse(self.path).path
        body = self._get_body()

        if path == '/nodes/register':
            # Register new node
            node_id = body.get('node_id')
            if not node_id:
                self._send_json({'error': 'node_id required'}, 400)
                return

            coordinator.register_node(node_id, body)
            self._send_json({
                'success': True,
                'node_id': node_id,
                'message': f'Node {node_id} registered'
            })

        elif path == '/tasks/create':
            # Create new task
            task_id = coordinator.create_task(body)
            self._send_json({
                'success': True,
                'task_id': task_id
            })

        elif path.startswith('/tasks/') and path.endswith('/update'):
            # Update task status
            task_id = path.split('/')[-2]
            success = coordinator.update_task(task_id, body)
            if success:
                self._send_json({'success': True})
            else:
                self._send_json({'error': 'Task not found'}, 404)

        elif path == '/tasks/delegate':
            # Delegate task to a node
            result = coordinator.delegate_task(body)
            if result['success']:
                self._send_json(result)
            else:
                self._send_json(result, 500)

        elif path == '/command':
            # Execute command (for testing)
            command = body.get('command')
            if not command:
                self._send_json({'error': 'command required'}, 400)
                return

            try:
                result = subprocess.run(command, shell=True,
                                      capture_output=True, text=True, timeout=10)
                self._send_json({
                    'success': True,
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode
                })
            except Exception as e:
                self._send_json({'error': str(e)}, 500)

        else:
            self._send_json({'error': 'Not found'}, 404)

    def log_message(self, format, *args):
        """Custom logging"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {format % args}")

class ReuseAddrHTTPServer(HTTPServer):
    allow_reuse_address = True

if __name__ == "__main__":
    PORT = 8000
    HOST = '0.0.0.0'

    print("🌟 Bojana A2A Coordinator Starting...")
    print(f"   Host: {HOST}")
    print(f"   Port: {PORT}")
    print(f"   Endpoints:")
    print(f"     GET  /                - Status")
    print(f"     GET  /nodes           - List nodes")
    print(f"     GET  /tasks           - List tasks")
    print(f"     GET  /tasks/<id>      - Get task")
    print(f"     GET  /system          - System info")
    print(f"     POST /nodes/register  - Register node")
    print(f"     POST /tasks/create    - Create task")
    print(f"     POST /tasks/delegate  - Delegate task to node")
    print(f"     POST /command         - Execute command")
    print("   Ready! 🚀\n")

    server = ReuseAddrHTTPServer((HOST, PORT), BojanaHandler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Bojana shutting down...")
        server.shutdown()
