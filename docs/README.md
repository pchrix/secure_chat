# Documentation SecureChat

## Vue d'ensemble

SecureChat est une application de chiffrement moderne avec interface élégante. Elle offre des fonctionnalités de messagerie sécurisée avec un design moderne et une navigation intuitive.

## Structure de la documentation

- [Configuration Context7](./context7-setup.md) - Configuration du serveur MCP pour la documentation
- [Architecture](./architecture.md) - Architecture de l'application (à créer)
- [Sécurité](./security.md) - Spécifications de sécurité (à créer)
- [API](./api.md) - Documentation des services (à créer)
- [Déploiement](./deployment.md) - Guide de déploiement PWA (à créer)

## Fonctionnalités principales

### Interface Moderne
- Page d'accueil élégante avec navigation claire
- Design sombre moderne (#1C1C1E)
- Animations fluides et transitions
- Interface entièrement en français

### Chiffrement Sécurisé
- Chiffrement/déchiffrement AES-256
- Interface bidirectionnelle Entrée/Sortie
- Génération automatique de clés
- Expiration automatique des clés (6 heures)
- Copie automatique dans le presse-papiers

### Gestion des Contacts
- Ajout de contacts via codes de partage
- Génération de codes de contact
- Interface moderne avec style cohérent
- Suppression sécurisée des contacts

### Paramètres
- Configuration d'accès (legacy)
- Interface accordéon moderne
- Navigation intuitive

## Technologies utilisées

### Frontend
- **Flutter** : Framework principal
- **Material Design 3** : Système de design
- **Provider** : Gestion d'état

### Sécurité
- **encrypt** : Chiffrement AES-256
- **crypto** : Fonctions cryptographiques
- **pointycastle** : Cryptographie avancée

### Stockage
- **shared_preferences** : Stockage local (minimal)
- **flutter_secure_storage** : Stockage sécurisé (prévu)

### Déploiement
- **PWA** : Progressive Web App
- **Service Worker** : Fonctionnement hors ligne

## Développement

### Prérequis
- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Node.js >= 18 (pour Context7)

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd application_de_chiffrement_cachée

# Installer les dépendances
flutter pub get

# Lancer en mode développement
flutter run -d chrome --web-port=8080
```

### Tests
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/
```

### Build PWA
```bash
# Build pour production
flutter build web --release

# Servir localement
flutter run -d web-server --web-port=8080
```

## Contribution

### Structure du code
```
lib/
├── main.dart                 # Point d'entrée
├── models/                   # Modèles de données
├── pages/                    # Pages de l'application
├── providers/                # Gestion d'état
├── services/                 # Services métier
├── utils/                    # Utilitaires
├── widgets/                  # Widgets réutilisables
└── theme.dart               # Thème de l'application
```

### Conventions
- Utiliser des noms explicites en anglais
- Commenter les fonctions critiques de sécurité
- Suivre les conventions Dart/Flutter
- Tester les fonctionnalités de chiffrement

### Sécurité
- Ne jamais committer de clés ou secrets
- Tester l'effacement sécurisé
- Valider tous les inputs utilisateur
- Documenter les choix cryptographiques

## Roadmap

### Phase 1 : UI (En cours)
- [x] Calculatrice scientifique
- [ ] Interface mode chiffrement améliorée
- [ ] Animations et transitions
- [ ] Panic button UI

### Phase 2 : Sécurité
- [ ] Renforcement du chiffrement (PBKDF2, HMAC)
- [ ] Effacement sécurisé implémenté
- [ ] Authentification biométrique
- [ ] Stockage sécurisé

### Phase 3 : Backend
- [ ] Système d'authentification premium
- [ ] Configuration personnalisée
- [ ] Tests complets
- [ ] Optimisation PWA

## Support

Pour toute question ou problème :
1. Consultez la documentation
2. Vérifiez les issues GitHub
3. Utilisez Context7 pour la documentation technique : `use context7`

## Licence

[À définir]
