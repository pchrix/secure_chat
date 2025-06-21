# 🔐 SecureChat

Une application de messagerie sécurisée moderne avec salons temporaires et chiffrement de bout en bout, développée avec Flutter.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.29.0-blue.svg)
![Tests](https://img.shields.io/badge/tests-26%20passing-green.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📱 Aperçu

SecureChat est une application de messagerie sécurisée qui offre :
- **Chiffrement AES-256** pour la sécurité maximale
- **Interface moderne** style iMessage/WhatsApp avec effets glassmorphism
- **Salons temporaires** 1-to-1 avec expiration automatique
- **Authentification PIN** 4-6 chiffres sécurisée
- **Backend Supabase** avec Row Level Security (RLS)
- **PWA** pour un déploiement multi-plateforme

## ✨ Fonctionnalités

### Sécurité
- 🔒 Chiffrement AES-256 de bout en bout
- 🏠 Salons temporaires avec expiration automatique
- 🛡️ Authentification par code PIN (4-6 chiffres)
- 🚨 Protection contre les tentatives multiples (verrouillage automatique)
- 📱 Stockage sécurisé des données sensibles

### Interface Utilisateur
- 🎨 Design moderne avec effets glassmorphism
- 🌙 Interface style messagerie (iMessage/WhatsApp)
- ⚡ Animations fluides et micro-interactions
- 🇫🇷 Interface entièrement en français
- 📱 Design responsive et adaptatif

### Fonctionnalités
- 🏠 Salons temporaires 1-to-1 sécurisés
- 🔗 Partage d'invitations via ID unique
- 📋 Copie automatique dans le presse-papiers
- 🔄 Détection automatique du type de contenu (chiffré/clair)
- ⏰ Expiration automatique des salons (1h à 24h)
- 🎓 Tutoriel interactif intégré
- 🔄 Migration automatique des données

## 🚀 Installation

### Prérequis
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.5.0
- Chrome (pour le développement web)

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone https://github.com/pchrix/secure_chat.git
   cd secure_chat
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**
   ```bash
   # Mode développement
   flutter run

   # Pour le web
   flutter run -d chrome --web-port=8080
   ```

## 🏗️ Architecture

### Structure du projet
```
lib/
├── main.dart                 # Point d'entrée avec initialisation Supabase
├── animations/               # Transitions et micro-interactions
├── models/                   # Modèles de données
│   ├── room.dart            # Modèle des salons
│   ├── room_participant.dart
│   ├── contact.dart
│   └── message.dart
├── pages/                    # Pages de l'interface utilisateur
│   ├── auth_page.dart       # Authentification PIN
│   ├── home_page.dart       # Page d'accueil
│   ├── tutorial_page.dart   # Tutoriel interactif
│   ├── create_room_page.dart
│   ├── join_room_page.dart
│   ├── room_chat_page.dart  # Interface de chat
│   └── settings_page.dart
├── providers/                # Gestion d'état avec Provider
│   ├── app_state_provider.dart
│   └── room_provider.dart
├── services/                 # Services métier
│   ├── auth_service.dart    # Authentification sécurisée
│   ├── encryption_service.dart # Chiffrement AES-256
│   ├── room_service.dart    # Gestion des salons
│   ├── room_key_service.dart # Gestion des clés
│   ├── supabase_service.dart # Backend Supabase
│   └── migration_service.dart
├── utils/                    # Utilitaires
│   └── security_utils.dart
├── widgets/                  # Widgets glassmorphism réutilisables
│   ├── glass_container.dart
│   ├── numeric_keypad.dart
│   ├── room_card.dart
│   └── change_password_dialog.dart
└── theme.dart               # Thème glassmorphism unifié
```

### Technologies utilisées
- **Flutter 3.29.0** : Framework principal
- **Provider** : Gestion d'état réactive
- **Supabase** : Backend avec RLS
- **Material Design 3** : Système de design
- **encrypt** : Chiffrement AES-256
- **crypto** : Fonctions cryptographiques
- **shared_preferences** : Stockage local sécurisé
- **uuid** : Génération d'identifiants uniques

## 🔧 Développement

### Tests
```bash
# Tests unitaires
flutter test

# Analyse du code
flutter analyze

# Formatage du code
dart format .
```

### Build pour production
```bash
# Build web (PWA)
flutter build web --release

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📚 Documentation

La documentation complète est disponible dans le dossier `docs/` :
- [Architecture](docs/README.md) - Vue d'ensemble du projet
- [Sécurité](docs/README.md) - Spécifications de sécurité
- [Déploiement](docs/README.md) - Guide de déploiement PWA

## 🛡️ Sécurité

### Chiffrement
- **AES-256** en mode CBC avec IV aléatoire
- **SHA-256** pour le hachage des mots de passe
- **Clés temporaires** avec expiration automatique
- **Effacement sécurisé** des données sensibles

### Authentification
- Mots de passe numériques (4-6 chiffres)
- Protection contre les attaques par force brute
- Verrouillage automatique après 3 tentatives échouées
- Durée de verrouillage : 5 minutes

## 🚀 Déploiement PWA

L'application est configurée comme Progressive Web App (PWA) :

1. **Build de production**
   ```bash
   flutter build web --release
   ```

2. **Servir l'application**
   ```bash
   # Serveur local pour test
   flutter run -d web-server --web-port=8080
   ```

3. **Déploiement**
   - Les fichiers de build se trouvent dans `build/web/`
   - Compatible avec tous les hébergeurs web statiques
   - Support du mode hors ligne via Service Worker

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :
1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation dans `docs/`

---

**⚠️ Note de sécurité :** Cette application est conçue pour un usage personnel et éducatif. Pour un usage en production, veuillez effectuer un audit de sécurité complet.
