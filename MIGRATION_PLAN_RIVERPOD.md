# 🔄 PLAN DE MIGRATION VERS RIVERPOD PUR

## 📊 ÉTAT ACTUEL - PROBLÈMES IDENTIFIÉS

### ❌ **Singletons Détectés**
```bash
# Recherche effectuée : grep -r "\.instance" lib --include="*.dart"
```

**Services avec pattern singleton :**
- `RoomService.instance` → 8 occurrences
- `RoomKeyService.instance` → 4 occurrences  
- `Supabase.instance.client` → 6 occurrences (framework, OK)

**Services avec méthodes statiques :**
- `UnifiedAuthService` → 15 méthodes statiques
- `SupabaseAuthService` → 8 méthodes statiques
- `SupabaseRoomService` → 12 méthodes statiques
- `SupabaseService` → 6 méthodes statiques

### ❌ **Duplication de Gestion d'État**
- `/providers/app_state_provider.dart` (legacy Provider)
- `/providers/room_provider_riverpod.dart` (Riverpod)
- `/core/providers/service_providers.dart` (Riverpod)
- `/core/providers/optimized_room_provider.dart` (Riverpod)

## 🎯 OBJECTIF : 100% RIVERPOD + INJECTION DE DÉPENDANCES

### ✅ **Résultat Attendu**
- ❌ `grep -r "\.instance" lib` → 0 résultats (sauf framework)
- ✅ Tous les services via providers Riverpod
- ✅ AutoDispose par défaut
- ✅ Un seul point de vérité par domaine

## 📋 PLAN D'EXÉCUTION - 4 PHASES

### **PHASE 1 : MIGRATION DES SERVICES SINGLETON → PROVIDERS**

#### 1.1 RoomService → RoomServiceProvider
**Fichiers à modifier :**
- `lib/services/room_service.dart`
- `lib/core/providers/service_providers.dart`
- Tous les fichiers utilisant `RoomService.instance`

**Actions :**
1. Supprimer pattern singleton dans `RoomService`
2. Créer constructeur avec injection de dépendances
3. Migrer `roomServiceProvider` vers injection pure
4. Remplacer tous les `RoomService.instance` par `ref.watch(roomServiceProvider)`

#### 1.2 RoomKeyService → RoomKeyServiceProvider  
**Fichiers à modifier :**
- `lib/services/room_key_service.dart`
- `lib/core/providers/service_providers.dart`
- Tous les fichiers utilisant `RoomKeyService.instance`

**Actions :**
1. Supprimer pattern singleton dans `RoomKeyService`
2. Créer constructeur avec injection de dépendances
3. Migrer `roomKeyServiceProvider` vers injection pure
4. Remplacer tous les `RoomKeyService.instance` par `ref.watch(roomKeyServiceProvider)`

### **PHASE 2 : MIGRATION DES SERVICES STATIQUES → PROVIDERS**

#### 2.1 UnifiedAuthService → AuthServiceProvider
**Fichiers à modifier :**
- `lib/services/unified_auth_service.dart`
- `lib/features/auth/presentation/providers/pin_state_provider.dart`
- Tous les fichiers utilisant `UnifiedAuthService.*`

**Actions :**
1. Convertir méthodes statiques en méthodes d'instance
2. Créer `authServiceProvider` avec AutoDispose
3. Injecter dépendances (SecurePinService, AuthMigrationService)
4. Remplacer `UnifiedAuthService.method()` par `ref.watch(authServiceProvider).method()`

#### 2.2 SupabaseAuthService → SupabaseAuthProvider
**Fichiers à modifier :**
- `lib/services/supabase_auth_service.dart`
- `lib/core/providers/service_providers.dart`

#### 2.3 SupabaseRoomService → SupabaseRoomProvider
**Fichiers à modifier :**
- `lib/services/supabase_room_service.dart`
- `lib/core/providers/service_providers.dart`

### **PHASE 3 : CONSOLIDATION DES PROVIDERS**

#### 3.1 Supprimer Doublons
**Fichiers à supprimer :**
- `lib/providers/app_state_provider.dart` (legacy Provider)
- Providers redondants dans `/providers/`

**Fichiers à conserver/migrer :**
- `lib/core/providers/service_providers.dart` (principal)
- `lib/features/*/presentation/providers/` (par domaine)

#### 3.2 Centraliser par Domaine
**Structure cible :**
```
lib/features/
├── auth/presentation/providers/
│   ├── auth_providers.dart
│   └── pin_providers.dart
├── rooms/presentation/providers/
│   ├── room_providers.dart
│   └── room_state_providers.dart
├── chat/presentation/providers/
│   └── chat_providers.dart
```

### **PHASE 4 : OPTIMISATION RIVERPOD**

#### 4.1 AutoDispose par Défaut
- Ajouter `.autoDispose` à tous les providers non-globaux
- Utiliser `ref.keepAlive()` seulement si nécessaire

#### 4.2 Family pour Paramètres
- Migrer providers avec paramètres vers `.family`
- Optimiser cache et disposal

#### 4.3 Dependencies Explicites
- Ajouter `dependencies: []` pour providers scopés
- Utiliser `@Dependencies` pour widgets

## 🔧 COMMANDES DE VALIDATION

### Pendant Migration
```bash
# Vérifier singletons restants
grep -r "\.instance" lib --include="*.dart" | grep -v "Supabase.instance"

# Vérifier méthodes statiques problématiques  
grep -r "static.*get\|static.*Future\|static.*void" lib/services --include="*.dart"

# Analyser code
flutter analyze
```

### Après Migration
```bash
# Doit retourner 0 résultats (sauf framework)
grep -r "\.instance" lib --include="*.dart" | wc -l

# Tests
flutter test
```

## 📊 MÉTRIQUES DE SUCCÈS

- [ ] 0 singleton `.instance` (sauf framework)
- [ ] 0 service statique avec état
- [ ] 100% providers Riverpod
- [ ] AutoDispose par défaut
- [ ] `flutter analyze` propre
- [ ] Tests passent

## 🚀 PRÊT POUR EXÉCUTION

**Ordre d'exécution :**
1. Phase 1.1 : RoomService
2. Phase 1.2 : RoomKeyService  
3. Phase 2.1 : UnifiedAuthService
4. Phase 2.2-2.3 : Services Supabase
5. Phase 3 : Consolidation
6. Phase 4 : Optimisation

**Validation à chaque étape :**
- Tests passent
- Application fonctionne
- Pas de régression
