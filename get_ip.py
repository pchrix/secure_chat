#!/usr/bin/env python3
"""
Script pour obtenir l'adresse IP locale
"""

import socket

def get_local_ip():
    try:
        # Connexion temporaire pour obtenir l'IP locale
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

if __name__ == "__main__":
    ip = get_local_ip()
    print(f"🌐 Votre adresse IP locale: {ip}")
    print(f"📱 URL pour smartphone: http://{ip}:8000")
