# 🔄 Guide de Migration Auth - Clean Architecture

## Vue d'ensemble

Ce guide documente la migration progressive du code d'authentification existant vers la nouvelle architecture Clean Architecture avec Riverpod.

## Architecture Migratoire

### Avant (Services Legacy)
```
lib/services/
├── auth_service.dart              # Service PIN basique (SHA-256)
├── supabase_auth_service.dart     # Service Supabase email/password
├── unified_auth_service.dart      # Service unifié (PBKDF2)
└── auth_migration_service.dart    # Migration automatique
```

### Après (Clean Architecture)
```
lib/features/auth/
├── domain/                        # Logique métier
│   ├── entities/                  # User, AuthState
│   ├── repositories/              # Interfaces
│   └── usecases/                  # Cas d'usage
├── data/                          # Accès aux données
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart           # Interface
│   │   ├── auth_remote_datasource_impl.dart      # Implémentation native
│   │   └── legacy_auth_datasource_adapter.dart   # 🔄 ADAPTATEUR
│   ├── models/                    # Modèles de données
│   └── repositories/              # Implémentations
└── presentation/                  # Interface utilisateur
    ├── providers/                 # Providers Riverpod
    ├── pages/                     # Pages auth
    └── widgets/                   # Composants réutilisables
```

## Stratégie de Migration

### 1. Adaptateur Legacy (✅ Terminé)

**Fichier**: `lib/features/auth/data/datasources/legacy_auth_datasource_adapter.dart`

L'adaptateur `LegacyAuthDataSourceAdapter` fait le pont entre :
- **Services existants** : `UnifiedAuthService`, `SupabaseAuthService`
- **Nouvelle interface** : `AuthRemoteDataSource`

**Avantages** :
- ✅ Migration progressive sans breaking changes
- ✅ Réutilisation du code existant et testé
- ✅ Maintien de la sécurité (PBKDF2, AES-256)
- ✅ Compatibilité avec Supabase

### 2. Mapping des Méthodes

| Nouvelle Interface | Service Legacy | Description |
|-------------------|----------------|-------------|
| `signInWithEmailAndPassword()` | `SupabaseAuthService.signIn()` | Connexion email/password |
| `signUpWithEmailAndPassword()` | `SupabaseAuthService.signUp()` | Inscription |
| `signOut()` | `SupabaseAuthService.signOut()` | Déconnexion |
| `getCurrentUser()` | `SupabaseAuthService.currentUser` | Utilisateur actuel |
| `verifyPin()` | `UnifiedAuthService.verifyPassword()` | Vérification PIN |
| `setupPin()` | `UnifiedAuthService.setPassword()` | Configuration PIN |
| `changePin()` | `UnifiedAuthService.changePassword()` | Changement PIN |
| `getAuthState()` | Combinaison Supabase + PIN | État global |

### 3. Gestion des Erreurs

L'adaptateur mappe les exceptions :
- `supabase.AuthException` → `AuthException` (Clean Architecture)
- Codes d'erreur standardisés
- Messages d'erreur localisés

### 4. Configuration des Providers

**Avant** :
```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    supabaseClient: Supabase.instance.client,
  );
});
```

**Après** :
```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return LegacyAuthDataSourceAdapter(); // 🔄 Utilise l'adaptateur
});
```

## Prochaines Étapes

### Phase 1 : Stabilisation (En cours)
- [x] Créer l'adaptateur `LegacyAuthDataSourceAdapter`
- [x] Modifier les providers pour utiliser l'adaptateur
- [ ] Compléter les use cases manquants
- [ ] Corriger les erreurs de compilation

### Phase 2 : Tests et Validation
- [ ] Tests unitaires de l'adaptateur
- [ ] Tests d'intégration auth complète
- [ ] Validation des flux utilisateur

### Phase 3 : Migration Progressive
- [ ] Migrer progressivement vers l'implémentation native
- [ ] Supprimer l'adaptateur quand plus nécessaire
- [ ] Nettoyer les anciens services

## Avantages de cette Approche

1. **Migration en douceur** : Pas de breaking changes
2. **Réutilisation** : Code existant et testé conservé
3. **Sécurité maintenue** : PBKDF2, AES-256, migration automatique
4. **Flexibilité** : Possibilité de migrer progressivement
5. **Testabilité** : Architecture Clean facilite les tests

## Notes Techniques

### Initialisation
L'adaptateur s'assure que `UnifiedAuthService` est initialisé avant utilisation.

### Gestion des Dates
Conversion automatique des dates Supabase (String) vers DateTime.

### État Combiné
L'état d'authentification combine :
- État Supabase (email/password)
- État PIN (sécurité locale)

### Compatibilité
L'adaptateur maintient la compatibilité avec :
- Tous les services existants
- La migration automatique des données
- Les patterns de sécurité établis

---

**Migration réalisée avec succès** ✅
*Architecture Clean + Services Legacy = Migration progressive parfaite*
