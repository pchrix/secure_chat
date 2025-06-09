# 🔐 SecureChat

Une application de messagerie sécurisée avec chiffrement de bout en bout, développée avec Flutter.

## 📱 Aperçu

SecureChat est une application de chiffrement moderne qui offre :
- **Chiffrement AES-256** pour la sécurité maximale
- **Interface moderne** avec thème sombre élégant
- **Gestion des contacts** avec codes de partage sécurisés
- **Clés temporaires** avec expiration automatique
- **PWA** pour un déploiement multi-plateforme

## ✨ Fonctionnalités

### Sécurité
- 🔒 Chiffrement AES-256 de bout en bout
- 🔑 Gestion des clés temporaires (expiration 6h)
- 🛡️ Authentification par mot de passe numérique (4-6 chiffres)
- 🚨 Protection contre les tentatives multiples (verrouillage automatique)
- 📱 Stockage sécurisé des données sensibles

### Interface Utilisateur
- 🌙 Thème sombre moderne (#1C1C1E)
- 🎨 Palette de couleurs cohérente (violet #9B59B6, bleu #2E86AB)
- ⚡ Animations fluides et transitions
- 🇫🇷 Interface entièrement en français
- 📱 Design responsive et adaptatif

### Fonctionnalités
- 💬 Interface bidirectionnelle Entrée/Sortie
- 👥 Gestion des contacts avec codes de partage
- 📋 Copie automatique dans le presse-papiers
- 🔄 Détection automatique du type de contenu (chiffré/clair)
- ⏰ Expiration automatique des clés de chiffrement

## 🚀 Installation

### Prérequis
- Flutter SDK >= 3.0
- Dart SDK >= 3.0

### Étapes d'installation

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-username/securechat-app.git
   cd securechat-app
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
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── contact.dart
│   ├── message.dart
│   └── secret_access_config.dart
├── pages/                    # Pages de l'interface utilisateur
│   ├── auth_page.dart
│   ├── contacts_page.dart
│   ├── home_page.dart
│   ├── modern_encryption_page.dart
│   └── settings_page.dart
├── providers/                # Gestion d'état avec Provider
│   └── app_state_provider.dart
├── services/                 # Services métier
│   ├── auth_service.dart
│   └── encryption_service.dart
├── utils/                    # Utilitaires
│   └── security_utils.dart
├── widgets/                  # Widgets réutilisables
│   └── change_password_dialog.dart
└── theme.dart               # Configuration du thème
```

### Technologies utilisées
- **Flutter** : Framework principal
- **Provider** : Gestion d'état
- **Material Design 3** : Système de design
- **encrypt** : Chiffrement AES-256
- **crypto** : Fonctions cryptographiques
- **shared_preferences** : Stockage local

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
