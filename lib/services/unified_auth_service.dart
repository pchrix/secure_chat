import 'package:flutter/foundation.dart';
import 'secure_pin_service.dart';
import 'auth_migration_service.dart';

// Export des classes pour compatibilité
export 'secure_pin_service.dart' show PinValidationResult;
export 'auth_migration_service.dart' show AuthState, AuthStateType;

/// Service d'authentification unifié avec injection de dépendances
/// Conforme aux meilleures pratiques Context7 de sécurité et Riverpod
class UnifiedAuthService {
  bool _isInitialized = false;

  /// Constructeur avec injection de dépendances
  /// [securePinService] Service de gestion des PIN sécurisés
  /// [authMigrationService] Service de migration d'authentification
  UnifiedAuthService({
    required SecurePinService securePinService,
    required AuthMigrationService authMigrationService,
  }) : _securePinService = securePinService,
       _authMigrationService = authMigrationService;

  /// Services injectés
  final SecurePinService _securePinService;
  final AuthMigrationService _authMigrationService;

  /// Initialise le service d'authentification unifié
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser le service PIN sécurisé
      await _securePinService.initialize();

      // Effectuer la migration si nécessaire
      final migrationResult = await _authMigrationService.performFullMigration();

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
  bool get isInitialized => _isInitialized;

  /// Vérifie si un PIN est défini
  Future<bool> hasPasswordSet() async {
    _ensureInitialized();
    return await _securePinService.hasPinSet();
  }

  /// Définit un nouveau PIN
  Future<AuthResult> setPassword(String pin) async {
    _ensureInitialized();

    final result = await _securePinService.setPin(pin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else {
      return AuthResult.error(result.message);
    }
  }

  /// Vérifie un PIN
  Future<AuthResult> verifyPassword(String pin) async {
    _ensureInitialized();

    final result = await _securePinService.verifyPin(pin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else if (result.isLocked) {
      return AuthResult.locked(result.lockoutMinutes);
    } else {
      return AuthResult.failed(result.remainingAttempts);
    }
  }

  /// Change le PIN
  Future<AuthResult> changePassword(String oldPin, String newPin) async {
    _ensureInitialized();

    final result = await _securePinService.changePin(oldPin, newPin);

    if (result.isSuccess) {
      return AuthResult.success();
    } else {
      return AuthResult.error(result.message);
    }
  }

  /// Réinitialise le PIN
  Future<void> resetPassword() async {
    _ensureInitialized();
    await _securePinService.resetPin();
  }

  /// Vérifie l'état de l'authentification
  Future<AuthState> checkAuthState() async {
    _ensureInitialized();
    return await _authMigrationService.checkAuthState();
  }

  /// Valide la force d'un PIN
  PinValidationResult validatePasswordStrength(String pin) {
    _ensureInitialized();
    return _securePinService.validatePinStrength(pin);
  }

  /// Réinitialise complètement l'authentification (pour les tests)
  Future<void> resetAll() async {
    await _authMigrationService.resetAll();
    _isInitialized = false;
  }

  /// S'assure que le service est initialisé
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
          'UnifiedAuthService non initialisé. Appelez initialize() d\'abord.');
    }
  }

  // === MÉTHODES DE COMPATIBILITÉ AVEC L'ANCIEN AuthService ===

  /// Vérifie si le compte est verrouillé (compatibilité)
  Future<bool> isAccountLocked() async {
    _ensureInitialized();

    // Tenter une vérification avec un PIN vide pour vérifier le verrouillage
    final result = await _securePinService.verifyPin('');
    return result.isLocked;
  }

  /// Obtient le temps de verrouillage restant (compatibilité)
  Future<int> getRemainingLockoutTime() async {
    _ensureInitialized();

    final result = await _securePinService.verifyPin('');
    return result.isLocked ? result.lockoutMinutes : 0;
  }

  /// Obtient le nombre de tentatives échouées (estimation)
  Future<int> getFailedAttempts() async {
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
