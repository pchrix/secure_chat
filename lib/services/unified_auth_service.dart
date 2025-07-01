import 'package:flutter/foundation.dart';
import 'secure_pin_service.dart';
import 'auth_migration_service.dart';

// Export des classes pour compatibilité
export 'secure_pin_service.dart' show PinValidationResult;
export 'auth_migration_service.dart' show AuthState, AuthStateType;

/// Service d'authentification unifié utilisant SecurePinService
/// Conforme aux meilleures pratiques Context7 de sécurité
class UnifiedAuthService {
  static bool _isInitialized = false;

  /// Initialise le service d'authentification unifié
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser le service PIN sécurisé
      await SecurePinService.initialize();

      // Effectuer la migration si nécessaire
      final migrationResult = await AuthMigrationService.performFullMigration();

      if (kDebugMode) {
        print('🔐 UnifiedAuthService initialisé');
        print('📋 Migration: ${migrationResult.message}');
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur d\'initialisation UnifiedAuthService: $e');
      }
      throw Exception('Erreur d\'initialisation de l\'authentification: $e');
    }
  }

  /// Vérifie si le service est initialisé
  static bool get isInitialized => _isInitialized;

  /// Vérifie si un PIN est défini
  static Future<bool> hasPasswordSet() async {
    _ensureInitialized();
    return await SecurePinService.hasPinSet();
  }

  /// Définit un nouveau PIN
  static Future<AuthResult> setPassword(String pin) async {
    _ensureInitialized();

    final result = await SecurePinService.setPin(pin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else {
      return AuthResult.error(result.message);
    }
  }

  /// Vérifie un PIN
  static Future<AuthResult> verifyPassword(String pin) async {
    _ensureInitialized();

    final result = await SecurePinService.verifyPin(pin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else if (result.isLocked) {
      return AuthResult.locked(result.lockoutMinutes);
    } else {
      return AuthResult.failed(result.remainingAttempts);
    }
  }

  /// Change le PIN
  static Future<AuthResult> changePassword(String oldPin, String newPin) async {
    _ensureInitialized();

    final result = await SecurePinService.changePin(oldPin, newPin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else {
      return AuthResult.error(result.message);
    }
  }

  /// Réinitialise le PIN
  static Future<void> resetPassword() async {
    _ensureInitialized();
    await SecurePinService.resetPin();
  }

  /// Vérifie l'état de l'authentification
  static Future<AuthState> checkAuthState() async {
    _ensureInitialized();
    return await AuthMigrationService.checkAuthState();
  }

  /// Valide la force d'un PIN
  static PinValidationResult validatePasswordStrength(String pin) {
    _ensureInitialized();
    return SecurePinService.validatePinStrength(pin);
  }

  /// Réinitialise complètement l'authentification (pour les tests)
  static Future<void> resetAll() async {
    await AuthMigrationService.resetAll();
    _isInitialized = false;
  }

  /// S'assure que le service est initialisé
  static void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
          'UnifiedAuthService non initialisé. Appelez initialize() d\'abord.');
    }
  }

  // === MÉTHODES DE COMPATIBILITÉ AVEC L'ANCIEN AuthService ===

  /// Vérifie si le compte est verrouillé (compatibilité)
  static Future<bool> isAccountLocked() async {
    _ensureInitialized();

    // Tenter une vérification avec un PIN vide pour vérifier le verrouillage
    final result = await SecurePinService.verifyPin('');
    return result.isLocked;
  }

  /// Obtient le temps de verrouillage restant (compatibilité)
  static Future<int> getRemainingLockoutTime() async {
    _ensureInitialized();

    final result = await SecurePinService.verifyPin('');
    return result.isLocked ? result.lockoutMinutes : 0;
  }

  /// Obtient le nombre de tentatives échouées (estimation)
  static Future<int> getFailedAttempts() async {
    _ensureInitialized();

    // Cette information n'est pas directement accessible dans SecurePinService
    // Retourner 0 par défaut
    return 0;
  }

  /// Configuration de sécurité
  static const int maxFailedAttempts = SecurePinService.maxFailedAttempts;
  static const int lockoutDurationMinutes =
      SecurePinService.lockoutDurationMinutes;
  static const int minPinLength = SecurePinService.minPinLength;
  static const int maxPinLength = SecurePinService.maxPinLength;
}

// === CLASSES DE RÉSULTATS (Compatibilité avec l'ancien AuthService) ===

class AuthResult {
  final bool isSuccess;
  final bool isLocked;
  final int remainingAttempts;
  final int lockoutMinutes;
  final String message;
  final AuthResultType type;

  const AuthResult._(
    this.isSuccess,
    this.isLocked,
    this.remainingAttempts,
    this.lockoutMinutes,
    this.message,
    this.type,
  );

  factory AuthResult.success() => const AuthResult._(
      true, false, 0, 0, 'Authentification réussie', AuthResultType.success);

  factory AuthResult.failed(int remainingAttempts) => AuthResult._(
      false,
      false,
      remainingAttempts,
      0,
      'PIN incorrect ($remainingAttempts tentatives restantes)',
      AuthResultType.failed);

  factory AuthResult.locked(int lockoutMinutes) => AuthResult._(
      false,
      true,
      0,
      lockoutMinutes,
      'Compte verrouillé ($lockoutMinutes minutes restantes)',
      AuthResultType.locked);

  factory AuthResult.noPasswordSet() => const AuthResult._(
      false, false, 0, 0, 'Aucun PIN défini', AuthResultType.noPasswordSet);

  factory AuthResult.error(String message) =>
      AuthResult._(false, false, 0, 0, message, AuthResultType.error);

  // Getters pour compatibilité
  bool get verified => isSuccess;
}

enum AuthResultType {
  success,
  failed,
  locked,
  noPasswordSet,
  error,
}
