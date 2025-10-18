#!/usr/bin/env python3
"""Simple Wake-on-LAN script for waking up HQ mainframe"""
import socket
import sys

def send_wol(mac_address, broadcast_ip='192.168.0.255', port=9):
    """
    Send Wake-on-LAN magic packet to specified MAC address.

    Args:
        mac_address: MAC address in format XX:XX:XX:XX:XX:XX or XX-XX-XX-XX-XX-XX
        broadcast_ip: Broadcast address (default: 192.168.0.255)
        port: WOL port (default: 9)
    """
    # Clean MAC address (remove separators)
    mac_address = mac_address.replace(':', '').replace('-', '').upper()

    if len(mac_address) != 12:
        raise ValueError(f"Invalid MAC address: {mac_address}")

    # Convert MAC to bytes
    mac_bytes = bytes.fromhex(mac_address)

    # Create magic packet: 6 bytes of FF + 16 repetitions of MAC
    magic_packet = b'\xFF' * 6 + mac_bytes * 16

    # Send packet via UDP broadcast
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    try:
        sock.sendto(magic_packet, (broadcast_ip, port))
        print(f"✓ WOL packet sent to {mac_address} via {broadcast_ip}:{port}")
        return True
    except Exception as e:
        print(f"✗ Failed to send WOL packet: {e}")
        return False
    finally:
        sock.close()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python wol.py <MAC_ADDRESS> [BROADCAST_IP]")
        print("Example: python wol.py AA:BB:CC:DD:EE:FF")
        print("         python wol.py AA-BB-CC-DD-EE-FF 192.168.0.255")
        sys.exit(1)

    mac = sys.argv[1]
    broadcast = sys.argv[2] if len(sys.argv) > 2 else '192.168.0.255'

    send_wol(mac, broadcast)
