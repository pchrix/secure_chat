#!/usr/bin/env python3
"""
Serveur HTTP simple pour tester la PWA SecureChat
Usage: python3 serve_pwa.py [port]
"""

import http.server
import socketserver
import os
import sys
from functools import partial

class PWAHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="build/web", **kwargs)
    
    def end_headers(self):
        # Headers pour la PWA
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        
        # Headers de sécurité pour une app de chiffrement
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY')
        self.send_header('X-XSS-Protection', '1; mode=block')
        self.send_header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains')
        
        super().end_headers()

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    
    # Vérifier que le dossier build/web existe
    if not os.path.exists("build/web"):
        print("❌ Erreur: build/web n'existe pas. Lancez d'abord 'flutter build web'")
        sys.exit(1)
    
    handler = PWAHTTPRequestHandler
    
    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"🚀 Serveur PWA SecureChat démarré sur http://localhost:{port}")
        print(f"📱 Pour tester l'installation PWA, ouvrez cette URL dans Chrome/Edge")
        print(f"🔒 L'application utilise HTTPS en production pour la sécurité")
        print(f"⚡ Mode développement - rechargement manuel requis")
        print(f"\nAppuyez sur Ctrl+C pour arrêter...")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n✅ Serveur arrêté.")

if __name__ == "__main__":
    main()
