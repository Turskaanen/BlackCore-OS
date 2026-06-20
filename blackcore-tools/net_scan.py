#!/usr/bin/env python3
import socket
import sys

def scan(ip):
    print(f"Scanning {ip}...")
    for port in range(1, 1025):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.1)
        try:
            s.connect((ip, port))
            print(f"[OPEN] {port}")
        except:
            pass
        s.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: net_scan.py <ip>")
        sys.exit(1)
    scan(sys.argv[1])
