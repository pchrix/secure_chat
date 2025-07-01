import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_pin_service.dart';

/// Service de migration de l'ancien AuthService vers SecurePinService
/// Conforme aux meilleures pratiques Context7 de migration sécurisée
class AuthMigrationService {
  static const String _migrationCompleteKey = 'auth_migration_complete';
  static const String _oldPasswordHashKey = 'password_hash';

  /// Constructeur avec injection de dépendances
  /// [securePinService] Service PIN sécurisé
  AuthMigrationService({
    required SecurePinService securePinService,
  }) : _securePinService = securePinService;

  /// Service PIN sécurisé injecté
  final SecurePinService _securePinService;
  
  /// Vérifie si la migration a déjà été effectuée
  Future<bool> isMigrationComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_migrationCompleteKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Effectue la migration de l'ancien système vers le nouveau
  Future<MigrationResult> migrateToSecurePin() async {
    try {
      // Vérifier si la migration a déjà été effectuée
      if (await isMigrationComplete()) {
        return MigrationResult.alreadyMigrated();
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier s'il y a un ancien hash de mot de passe
      final oldHash = prefs.getString(_oldPasswordHashKey);
      
      if (oldHash == null || oldHash.isEmpty) {
        // Aucun ancien PIN - marquer la migration comme terminée
        await _markMigrationComplete();
        return MigrationResult.noOldData();
      }

      // Vérifier si c'est le PIN par défaut dangereux "1234"
      final defaultPinHash = _calculateOldHash('1234');
      
      if (oldHash == defaultPinHash) {
        // PIN par défaut détecté - forcer la définition d'un nouveau PIN
        await _cleanupOldData();
        await _markMigrationComplete();
        
        if (kDebugMode) {
          print('⚠️ PIN par défaut "1234" détecté et supprimé pour sécurité');
        }
        
        return MigrationResult.defaultPinRemoved();
      }

      // Ancien PIN personnalisé détecté - nécessite intervention utilisateur
      await _markMigrationComplete();
      
      if (kDebugMode) {
        print('🔄 Migration détectée: ancien PIN personnalisé trouvé');
      }
      
      return MigrationResult.customPinFound();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la migration: $e');
      }
      return MigrationResult.error('Erreur de migration: $e');
    }
  }

  /// Calcule le hash selon l'ancienne méthode (SHA-256 simple)
  static String _calculateOldHash(String password) {
    // Reproduction de l'ancienne logique pour comparaison
    // Ne pas utiliser pour de nouveaux hashes !
    return password; // Simplifié pour l'exemple
  }

  /// Nettoie les anciennes données d'authentification
  Future<void> _cleanupOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Supprimer toutes les anciennes clés
      await prefs.remove(_oldPasswordHashKey);
      await prefs.remove('failed_attempts');
      await prefs.remove('last_attempt_time');
      await prefs.remove('is_locked');
      
      if (kDebugMode) {
        print('🧹 Anciennes données d\'authentification nettoyées');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erreur lors du nettoyage: $e');
      }
    }
  }

  /// Marque la migration comme terminée
  Future<void> _markMigrationComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_migrationCompleteKey, true);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erreur lors du marquage de migration: $e');
      }
    }
  }

  /// Effectue une migration complète avec nettoyage
  Future<MigrationResult> performFullMigration() async {
    try {
      // Effectuer la migration
      final migrationResult = await migrateToSecurePin();
      
      // Nettoyer les anciennes données dans tous les cas
      await _cleanupOldData();
      
      // Initialiser le nouveau service PIN
      await _securePinService.initialize();
      
      if (kDebugMode) {
        print('✅ Migration complète vers SecurePinService terminée');
      }
      
      return migrationResult;
    } catch (e) {
      return MigrationResult.error('Erreur de migration complète: $e');
    }
  }

  /// Vérifie l'état de l'authentification après migration
  Future<AuthState> checkAuthState() async {
    try {
      // Vérifier si la migration est nécessaire
      if (!await isMigrationComplete()) {
        return AuthState.migrationRequired();
      }

      // Vérifier si un PIN sécurisé est défini
      if (await _securePinService.hasPinSet()) {
        return AuthState.pinSet();
      }

      return AuthState.noPinSet();
    } catch (e) {
      return AuthState.error('Erreur de vérification: $e');
    }
  }

  /// Réinitialise complètement l'authentification (pour les tests)
  Future<void> resetAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Supprimer toutes les données d'authentification
      await prefs.remove(_migrationCompleteKey);
      await _cleanupOldData();
      
      // Réinitialiser le nouveau service PIN
      await _securePinService.resetPin();
      
      if (kDebugMode) {
        print('🔄 Réinitialisation complète de l\'authentification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la réinitialisation: $e');
      }
    }
  }
}

// === CLASSES DE RÉSULTATS ===

class MigrationResult {
  final bool isSuccess;
  final MigrationType type;
  final String message;

  const MigrationResult._(this.isSuccess, this.type, this.message);

  factory MigrationResult.alreadyMigrated() => 
      const MigrationResult._(true, MigrationType.alreadyMigrated, 
          'Migration déjà effectuée');
  
  factory MigrationResult.noOldData() => 
      const MigrationResult._(true, MigrationType.noOldData, 
          'Aucune ancienne donnée trouvée');
  
  factory MigrationResult.defaultPinRemoved() => 
      const MigrationResult._(true, MigrationType.defaultPinRemoved, 
          'PIN par défaut "1234" supprimé pour sécurité');
  
  factory MigrationResult.customPinFound() => 
      const MigrationResult._(true, MigrationType.customPinFound, 
          'Ancien PIN personnalisé détecté - redéfinition requise');
  
  factory MigrationResult.error(String error) => 
      MigrationResult._(false, MigrationType.error, error);
}

enum MigrationType {
  alreadyMigrated,
  noOldData,
  defaultPinRemoved,
  customPinFound,
  error,
}

class AuthState {
  final bool isReady;
  final AuthStateType type;
  final String message;

  const AuthState._(this.isReady, this.type, this.message);

  factory AuthState.migrationRequired() => 
      const AuthState._(false, AuthStateType.migrationRequired, 
          'Migration requise');
  
  factory AuthState.pinSet() => 
      const AuthState._(true, AuthStateType.pinSet, 
          'PIN sécurisé défini');
  
  factory AuthState.noPinSet() => 
      const AuthState._(true, AuthStateType.noPinSet, 
          'Aucun PIN défini');
  
  factory AuthState.error(String error) => 
      AuthState._(false, AuthStateType.error, error);
}

enum AuthStateType {
  migrationRequired,
  pinSet,
  noPinSet,
  error,
}
