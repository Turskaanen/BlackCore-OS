#!/usr/bin/env python3
import platform
import os
import socket

def main():
    print("=== BlackCore System Info ===")
    print(f"OS: {platform.system()} {platform.release()}")
    print(f"Kernel: {platform.version()}")
    print(f"Machine: {platform.machine()}")
    print(f"Hostname: {socket.gethostname()}")
    print(f"User: {os.getenv('USER')}")
    print("=============================")

if __name__ == "__main__":
    main()
