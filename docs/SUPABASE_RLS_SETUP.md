# Configuration Supabase Row Level Security (RLS) pour SecureChat

## 🔐 Vue d'ensemble

SecureChat utilise Supabase avec Row Level Security (RLS) pour garantir que chaque utilisateur ne peut accéder qu'à ses propres données et aux salons auxquels il participe. Cette configuration assure une sécurité multi-utilisateurs robuste.

## 📋 Prérequis

1. **Projet Supabase** : Créer un projet sur [supabase.com](https://supabase.com)
2. **Variables d'environnement** : Configurer les clés API dans `lib/config/app_config.dart`
3. **Extensions PostgreSQL** : Les extensions `uuid-ossp` et `pgcrypto` sont automatiquement activées

## 🗄️ Structure de la base de données

### Tables principales

#### 1. `profiles` - Profils utilisateurs
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  username TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  pin_hash TEXT, -- PIN chiffré pour sécurité additionnelle
  last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_online BOOLEAN DEFAULT FALSE,
  
  PRIMARY KEY (id),
  UNIQUE(username)
);
```

**Politiques RLS :**
- ✅ **Lecture publique** : Tous les profils sont visibles (pour la recherche d'utilisateurs)
- ✅ **Insertion** : Utilisateurs peuvent créer leur propre profil
- ✅ **Mise à jour** : Utilisateurs peuvent modifier uniquement leur profil

#### 2. `rooms` - Salons de chat
```sql
CREATE TABLE rooms (
  id TEXT PRIMARY KEY DEFAULT encode(gen_random_bytes(6), 'hex'),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT,
  description TEXT,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  max_participants INTEGER DEFAULT 2,
  encryption_key_hash TEXT,
  status TEXT DEFAULT 'waiting',
  is_private BOOLEAN DEFAULT FALSE
);
```

**Politiques RLS :**
- ✅ **Lecture** : Utilisateurs voient uniquement les salons où ils participent
- ✅ **Création** : Utilisateurs authentifiés peuvent créer des salons
- ✅ **Mise à jour** : Seuls les créateurs peuvent modifier leurs salons
- ✅ **Suppression** : Seuls les créateurs peuvent supprimer leurs salons

#### 3. `room_participants` - Participants des salons
```sql
CREATE TABLE room_participants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id TEXT REFERENCES rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  left_at TIMESTAMP WITH TIME ZONE,
  role TEXT DEFAULT 'participant',
  
  UNIQUE(room_id, user_id)
);
```

**Politiques RLS :**
- ✅ **Lecture** : Utilisateurs voient les participants des salons où ils sont présents
- ✅ **Insertion** : Utilisateurs peuvent rejoindre des salons
- ✅ **Mise à jour** : Utilisateurs peuvent quitter des salons

#### 4. `messages` - Messages chiffrés
```sql
CREATE TABLE messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id TEXT REFERENCES rooms(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  encrypted_content TEXT NOT NULL, -- Contenu chiffré AES-256
  message_type TEXT DEFAULT 'text',
  metadata JSONB
);
```

**Politiques RLS :**
- ✅ **Lecture** : Utilisateurs voient les messages des salons où ils participent
- ✅ **Insertion** : Utilisateurs peuvent envoyer des messages dans leurs salons
- ✅ **Mise à jour** : Utilisateurs peuvent modifier leurs propres messages
- ✅ **Suppression** : Utilisateurs peuvent supprimer leurs propres messages

## 🔧 Configuration automatique

### Migration initiale
Le fichier `supabase/migrations/001_initial_schema.sql` contient :

1. **Création des tables** avec contraintes de sécurité
2. **Activation RLS** sur toutes les tables
3. **Politiques de sécurité** détaillées
4. **Index de performance** optimisés
5. **Triggers automatiques** pour la gestion des timestamps
6. **Configuration Realtime** pour les mises à jour en temps réel
7. **Storage bucket** pour les avatars avec politiques sécurisées

### Fonctions automatiques

#### Mise à jour des timestamps
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
```

#### Ajout automatique du créateur comme participant
```sql
CREATE OR REPLACE FUNCTION add_room_creator_as_participant()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO room_participants (room_id, user_id, role)
    VALUES (NEW.id, NEW.created_by, 'creator');
    RETURN NEW;
END;
$$ language 'plpgsql';
```

## 🚀 Déploiement

### 1. Appliquer les migrations
```bash
# Via Supabase CLI
supabase db push

# Ou via l'interface web Supabase
# Copier le contenu de 001_initial_schema.sql dans l'éditeur SQL
```

### 2. Configurer l'authentification
```dart
// Dans lib/config/app_config.dart
class AppConfig {
  static String getSupabaseUrl() => 'YOUR_SUPABASE_URL';
  static String getSupabaseAnonKey() => 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Initialiser Supabase
```dart
await Supabase.initialize(
  url: AppConfig.getSupabaseUrl(),
  anonKey: AppConfig.getSupabaseAnonKey(),
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce, // Sécurité renforcée
    autoRefreshToken: true,
    persistSession: true,
  ),
);
```

## 🔒 Sécurité avancée

### Chiffrement des données
- **Messages** : Chiffrés côté client avec AES-256 avant stockage
- **PIN utilisateur** : Hashé avec SHA-256 avant stockage
- **Clés de salon** : Stockées chiffrées avec hash de vérification

### Authentification PKCE
- **Proof Key for Code Exchange** activé pour tous les flux d'authentification
- **Tokens automatiquement rafraîchis** pour maintenir la session
- **Sessions persistantes** sécurisées localement

### Politiques RLS granulaires
- **Isolation complète** entre utilisateurs
- **Accès basé sur la participation** aux salons
- **Vérifications d'autorisation** à chaque requête
- **Audit trail** automatique avec timestamps

## 📊 Monitoring et maintenance

### Index de performance
```sql
-- Optimisation des requêtes fréquentes
CREATE INDEX idx_messages_room_created ON messages(room_id, created_at);
CREATE INDEX idx_room_participants_user_id ON room_participants(user_id);
CREATE INDEX idx_rooms_expires_at ON rooms(expires_at);
```

### Nettoyage automatique
```sql
-- Fonction pour nettoyer les salons expirés
CREATE OR REPLACE FUNCTION cleanup_expired_rooms()
RETURNS void AS $$
BEGIN
    DELETE FROM rooms WHERE expires_at < NOW() - INTERVAL '1 day';
END;
$$ language 'plpgsql';
```

## 🧪 Tests de sécurité

### Vérification RLS
```sql
-- Tester l'isolation des données
SET ROLE authenticated;
SET request.jwt.claims TO '{"sub": "user-id-1"}';

-- Cette requête ne doit retourner que les données de l'utilisateur
SELECT * FROM rooms;
SELECT * FROM messages;
```

### Tests d'autorisation
```dart
// Vérifier que les utilisateurs ne peuvent pas accéder aux données d'autres utilisateurs
final otherUserRoom = await SupabaseRoomService.getRoom('other-user-room-id');
assert(otherUserRoom == null); // Doit être null
```

## 📚 Ressources

- [Documentation Supabase RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [Guide PKCE](https://supabase.com/docs/guides/auth/auth-deep-dive/auth-deep-dive-jwts)
- [Bonnes pratiques sécurité](https://supabase.com/docs/guides/auth/auth-helpers/auth-ui)

## ⚠️ Notes importantes

1. **Variables d'environnement** : Ne jamais commiter les vraies clés API
2. **Service key** : Utiliser uniquement côté serveur, jamais côté client
3. **RLS activé** : Vérifier que RLS est activé sur toutes les tables sensibles
4. **Tests réguliers** : Tester les politiques RLS après chaque modification
