# 🏗️ Architecture SecureChat

## 📋 Vue d'ensemble de l'Architecture

SecureChat utilise une architecture Flutter modulaire avec chiffrement AES-256 et gestion d'état Provider. L'application est actuellement en phase MVP avec une configuration Supabase minimale.

## 🏛️ Architecture Globale

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURECHAT MVP                           │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Flutter Web/Mobile)                             │
│  ├── UI Layer (Pages + Widgets)                            │
│  ├── Business Logic (Providers + Services)                 │
│  └── Data Layer (Models + Local Storage)                   │
├─────────────────────────────────────────────────────────────┤
│  Backend (Mode Hybride)                                    │
│  ├── Local: SharedPreferences + Secure Storage             │
│  ├── Cloud: Supabase (Configuration minimale)             │
│  └── Demo: Données statiques pour tests                    │
├─────────────────────────────────────────────────────────────┤
│  Sécurité (Chiffrement Local)                             │
│  ├── AES-256 (Messages + Clés)                            │
│  ├── PIN Authentication (Local)                           │
│  └── Stockage sécurisé (SharedPreferences)                │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Structure du Projet

### **Structure Actuelle**
```
lib/
├── main.dart                    # Point d'entrée avec Provider
├── models/                      # Modèles de données
│   ├── contact.dart            # Modèle contact (partiellement utilisé)
│   ├── message.dart            # Modèle message pour historique
│   ├── room.dart               # Modèle salon sécurisé
│   └── room_participant.dart   # Participants aux salons
├── pages/                       # Pages de l'application
│   ├── auth_page.dart          # Authentification PIN
│   ├── home_page.dart          # Page d'accueil (liste salons)
│   ├── contacts_page.dart      # Gestion contacts
│   ├── modern_encryption_page.dart # Interface chiffrement
│   └── settings_page.dart      # Paramètres
├── providers/                   # Gestion d'état
│   ├── app_state_provider.dart # État global application
│   └── room_provider.dart      # État des salons (si implémenté)
├── services/                    # Services métier
│   ├── auth_service.dart       # Authentification PIN
│   ├── encryption_service.dart # Chiffrement AES-256
│   ├── room_service.dart       # Gestion salons
│   └── supabase_service.dart   # Backend cloud (minimal)
├── widgets/                     # Composants réutilisables
│   ├── glass_container.dart    # Effets glassmorphism
│   ├── numeric_keypad.dart     # Clavier PIN
│   └── change_password_dialog.dart # Dialog changement PIN
├── theme.dart                   # Configuration thème
└── utils/
    └── security_utils.dart      # Utilitaires cryptographiques
```

## 🔧 Services Principaux

### **AuthService** 
```dart
Fonctionnalités:
✅ Authentification PIN 4-6 chiffres
✅ Hachage SHA-256 des mots de passe
✅ Protection contre force brute (3 tentatives)
✅ Verrouillage temporaire (5 minutes)
⚠️ Stockage local uniquement (pas d'auth serveur)

État: Opérationnel avec limitations
```

### **EncryptionService**
```dart
Fonctionnalités:
✅ Chiffrement AES-256 avec IV aléatoire
✅ Génération de clés sécurisées
✅ Validation des messages chiffrés
✅ Conversion passphrase vers clé
❌ Pas de PBKDF2 ou HMAC (sécurité basique)

État: Fonctionnel mais peut être amélioré
```

### **RoomService** (Si implémenté)
```dart
Fonctionnalités prévues:
⚠️ Création et gestion des salons temporaires
⚠️ Expiration automatique
⚠️ Partage d'invitations
❌ Synchronisation multi-appareils
❌ Gestion d'état temps réel

État: Implémentation partielle/bugguée
```

### **SupabaseService**
```dart
Fonctionnalités:
⚠️ Configuration minimale
❌ Row Level Security non implémenté
❌ Authentification serveur manquante
✅ Fallback local fonctionnel

État: Configuration de base uniquement
```

## 📊 Modèles de Données

### **Room** (Salon)
```dart
class Room {
  String id;              // ID unique salon
  DateTime createdAt;     // Date création
  DateTime expiresAt;     // Date expiration
  RoomStatus status;      // waiting/active/expired
  int participantCount;   // Nombre participants
  String? creatorId;      // ID créateur
}
```

### **Message**
```dart
class Message {
  String id;              // ID unique message
  String text;            // Contenu (chiffré)
  bool isEncrypted;       // Indicateur chiffrement
  DateTime timestamp;     // Horodatage
  String? contactId;      // ID contact/salon
}
```

### **Contact**
```dart
class Contact {
  String id;              // ID unique
  String name;            // Nom contact
  String publicKey;       // Clé publique (démo)
  DateTime createdAt;     // Date ajout
}
```

## 🎨 Architecture UI/UX

### **Thème et Design System**
```dart
Palette de couleurs:
- Primary: #9B59B6 (Violet)
- Secondary: #2E86AB (Bleu)
- Accent: #4A5568 (Gris)
- Success: #00FF88 (Vert néon)
- Error: #FF3366 (Rouge)

Effets:
✅ Glassmorphism basique
⚠️ Animations partiellement implémentées
❌ Responsive design incomplet
❌ Accessibilité limitée
```

### **Navigation et Flux**
```
App Launch → PIN Auth → Home Page → [Room List]
                ↓
Home → Create Room → Share ID → Chat Interface
Home → Join Room → Enter ID → Chat Interface
Home → Settings → Change PIN/Config
```

## 🔐 Architecture de Sécurité

### **Chiffrement Local**
```
Message Input → AES-256 Encryption → Encrypted Output
             ↓
         IV + Encrypted Content → Base64 → Storage/Share
```

### **Gestion des Clés**
```
User PIN → SHA-256 Hash → Stored Locally
Room Creation → Generate AES Key → Store with Room ID
Message Send → Room Key → Encrypt → Transmit
```

### **Stockage Local**
```
SharedPreferences:
├── PIN Hash (SHA-256)
├── Room Data (IDs, status, keys)
├── User Preferences
└── Demo Data (mode développement)
```

## 🚀 Technologies et Dépendances

### **Flutter & Dart**
```yaml
SDK: Flutter 3.29.0, Dart 3.5.0
Packages principaux:
- flutter_riverpod: ^2.4.9 (gestion d'état)
- encrypt: ^5.0.3 (chiffrement AES-256)
- crypto: ^3.0.6 (fonctions hash)
- shared_preferences: ^2.3.2 (stockage local)
- uuid: ^4.5.1 (génération d'IDs)
```

### **Backend & Cloud**
```yaml
Backend: Supabase (configuration minimale)
Base de données: PostgreSQL (Supabase)
APIs: REST auto-générées
Authentification: Local PIN (pas de Supabase Auth)
```

## ⚠️ Limitations Architecturales Actuelles

### **Sécurité**
- ❌ **Authentification locale uniquement** (pas d'isolation utilisateur)
- ❌ **Pas de Row Level Security** sur Supabase
- ❌ **Stockage clés en SharedPreferences** (non sécurisé)
- ❌ **Pas d'audit de sécurité complet**

### **Performance**
- ❌ **Animations bugguées** et non optimisées
- ❌ **Fuites mémoire potentielles**
- ❌ **Pas de lazy loading**
- ❌ **Build size non optimisé**

### **Fonctionnalités**
- ❌ **Tutoriel cassé**
- ❌ **Partage d'invitations incomplet**
- ❌ **Pas de synchronisation multi-appareils**
- ❌ **Interface responsive limitée**

### **Maintenance**
- ❌ **Tests incomplets** (couverture partielle)
- ❌ **Documentation dispersée**
- ❌ **Architecture pas entièrement modulaire**

## 🎯 Recommandations d'Amélioration

### **Phase 1 - Stabilisation (Priorité Haute)**
1. **Corriger les bugs critiques** (tutoriel, animations)
2. **Optimiser les performances** (animations, mémoire)
3. **Implémenter tests automatisés** complets
4. **Nettoyer l'architecture** (supprimer code obsolète)

### **Phase 2 - Sécurité (Priorité Haute)**
1. **Migrer vers flutter_secure_storage**
2. **Implémenter Supabase Auth + RLS**
3. **Audit de sécurité professionnel**
4. **Chiffrement renforcé** (PBKDF2, HMAC)

### **Phase 3 - Fonctionnalités (Priorité Moyenne)**
1. **Migration Provider → Riverpod**
2. **Interface responsive complète**
3. **Synchronisation multi-appareils**
4. **Notifications push sécurisées**

### **Phase 4 - Production (Priorité Basse)**
1. **CI/CD automatisé**
2. **Monitoring et analytics**
3. **Documentation complète**
4. **Déploiement multi-plateforme**

## 📈 État Actuel vs Vision Cible

### **État MVP Actuel**
```
Fonctionnalités: 40% complètes
Stabilité: 60% (bugs connus)
Sécurité: 50% (basique mais fonctionnelle)
Performance: 30% (optimisations requises)
Documentation: 70% (en cours de consolidation)
```

### **Vision Cible Production**
```
Fonctionnalités: 100% complètes et testées
Stabilité: 95% (bugs critiques résolus)
Sécurité: 90% (audit professionnel validé)
Performance: 85% (optimisé pour tous appareils)
Documentation: 95% (complète et maintenue)
```

---

**📝 Note :** Cette architecture évolue rapidement. Voir `CHANGELOG.md` pour les dernières modifications et `docs/archive/` pour l'historique des décisions architecturales.
