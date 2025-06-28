#!/bin/bash

# Script de déploiement automatique PWA pour SecureChat
# Usage: ./deploy_pwa.sh [platform]
# Platforms: netlify, vercel, firebase, github-pages

set -e

echo "🔐 SecureChat PWA - Script de déploiement"
echo "========================================"

# Vérifications préalables
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "❌ Erreur: Flutter n'est pas installé ou pas dans le PATH"
    exit 1
fi

# Nettoyage et build
echo "🧹 Nettoyage du projet..."
flutter clean

echo "📦 Installation des dépendances..."
flutter pub get

echo "🔨 Compilation de la PWA..."
flutter build web --release

# Ajout des fichiers de configuration
echo "⚙️ Configuration des redirections..."
cp vercel.json build/web/ 2>/dev/null || true

# Informations sur le build
BUILD_SIZE=$(du -sh build/web | cut -f1)
echo "✅ Build terminé avec succès!"
echo "📊 Taille du build: $BUILD_SIZE"
echo "📁 Fichiers générés dans: build/web/"

# Instructions de déploiement selon la plateforme
PLATFORM=${1:-"manuel"}

case $PLATFORM in
    "netlify")
        echo ""
        echo "🌐 Déploiement Netlify:"
        echo "1. Connectez-vous à https://netlify.com"
        echo "2. Glissez-déposez le dossier build/web"
        echo "3. Ou utilisez: netlify deploy --dir=build/web --prod"
        ;;
    "vercel")
        echo ""
        echo "▲ Déploiement Vercel:"
        echo "1. Installez Vercel CLI: npm i -g vercel"
        echo "2. Lancez: vercel --prod"
        echo "3. Suivez les instructions"
        ;;
    "firebase")
        echo ""
        echo "🔥 Déploiement Firebase:"
        echo "1. Installez Firebase CLI: npm i -g firebase-tools"
        echo "2. Initialisez: firebase init hosting"
        echo "3. Déployez: firebase deploy"
        ;;
    "github-pages")
        echo ""
        echo "🐙 Déploiement GitHub Pages:"
        echo "1. Commitez le dossier build/web"
        echo "2. Activez GitHub Pages sur la branche main"
        echo "3. Configurez le dossier source sur /docs ou utilisez une action"
        ;;
    *)
        echo ""
        echo "📋 Déploiement manuel:"
        echo "1. Uploadez le contenu de build/web/ sur votre serveur"
        echo "2. Configurez HTTPS (obligatoire pour PWA)"
        echo "3. Configurez les redirections vers index.html"
        ;;
esac

echo ""
echo "🔒 Important pour SecureChat:"
echo "• HTTPS est obligatoire pour les fonctionnalités PWA"
echo "• Configurez les headers de sécurité"
echo "• Testez l'installation PWA sur mobile"
echo "• Vérifiez que le service worker fonctionne"

echo ""
echo "🚀 PWA prête au déploiement!"
