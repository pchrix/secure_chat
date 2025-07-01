#!/usr/bin/env python3
"""
Serveur simple pour tester SecureChat PWA
Usage: python3 serve_app.py
Puis ouvrir: http://localhost:8000 sur votre smartphone
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

# Configuration
PORT = 8000
WEB_DIR = "build/web"

class SecureChatHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    
    def end_headers(self):
        # Headers pour PWA
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

def main():
    # Vérifier que le build web existe
    if not os.path.exists(WEB_DIR):
        print(f"❌ Erreur: Le dossier {WEB_DIR} n'existe pas")
        print("🔧 Exécutez d'abord: flutter build web --release")
        sys.exit(1)
    
    # Démarrer le serveur
    with socketserver.TCPServer(("", PORT), SecureChatHandler) as httpd:
        print(f"🚀 SecureChat PWA démarré sur:")
        print(f"   📱 Local: http://localhost:{PORT}")
        print(f"   🌐 Réseau: http://[votre-ip]:{PORT}")
        print(f"")
        print(f"📋 Instructions smartphone:")
        print(f"   1. Connectez votre smartphone au même WiFi")
        print(f"   2. Ouvrez Chrome/Safari sur le smartphone")
        print(f"   3. Allez sur http://[votre-ip]:{PORT}")
        print(f"   4. Appuyez sur 'Ajouter à l'écran d'accueil'")
        print(f"")
        print(f"⚡ Appuyez sur Ctrl+C pour arrêter")
        print(f"" + "="*50)
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n🛑 Serveur arrêté")

if __name__ == "__main__":
    main()
