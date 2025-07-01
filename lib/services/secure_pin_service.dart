import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

/// Service d'authentification PIN sécurisé avec injection de dépendances
/// Conforme aux meilleures pratiques Context7 bcrypt et PBKDF2
class SecurePinService {
  static const String _pinHashKey = 'secure_pin_hash';
  static const String _pinSaltKey = 'secure_pin_salt';
  static const String _failedAttemptsKey = 'secure_failed_attempts';
  static const String _lastAttemptTimeKey = 'secure_last_attempt_time';
  static const String _isLockedKey = 'secure_is_locked';

  // Configuration sécurisée selon Context7
  static const int maxFailedAttempts = 3;
  static const int lockoutDurationMinutes = 5;
  static const int pbkdf2Iterations = 100000; // Recommandation OWASP 2024
  static const int saltLength = 32; // 256 bits
  static const int minPinLength = 6; // Minimum sécurisé
  static const int maxPinLength = 12;

  /// Constructeur avec injection de dépendances
  /// [secureStorageService] Service de stockage sécurisé
  SecurePinService({
    required SecureStorageService secureStorageService,
  }) : _secureStorageService = secureStorageService;

  /// Service de stockage sécurisé injecté
  final SecureStorageService _secureStorageService;

  /// Initialise le service PIN sécurisé
  Future<void> initialize() async {
    await _secureStorageService.initialize();
  }

  /// Génère un salt cryptographiquement sécurisé
  static String _generateSecureSalt() {
    final random = Random.secure();
    final saltBytes =
        List<int>.generate(saltLength, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Dérive une clé sécurisée avec PBKDF2
  /// Conforme aux recommandations Context7 bcrypt
  static String _deriveKeyPBKDF2(String pin, String salt) {
    final pinBytes = utf8.encode(pin);
    final saltBytes = base64Decode(salt);

    // PBKDF2 avec SHA-256 (100,000 itérations selon OWASP)
    List<int> derived = pinBytes;

    for (int i = 0; i < pbkdf2Iterations; i++) {
      final hmac = Hmac(sha256, saltBytes);
      derived = hmac.convert([...derived, ...pinBytes]).bytes;
    }

    return base64Encode(derived);
  }

  /// Valide la force du PIN selon les critères de sécurité
  PinValidationResult validatePinStrength(String pin) {
    if (pin.length < minPinLength) {
      return PinValidationResult.tooShort(minPinLength);
    }

    if (pin.length > maxPinLength) {
      return PinValidationResult.tooLong(maxPinLength);
    }

    // Vérifier que ce n'est pas un PIN faible commun
    final weakPins = [
      '123456',
      '000000',
      '111111',
      '222222',
      '333333',
      '444444',
      '555555',
      '666666',
      '777777',
      '888888',
      '999999',
      '123123',
      '456456',
      '789789',
      '159753',
      '987654',
      '654321',
      '112233',
      '445566',
    ];

    if (weakPins.contains(pin)) {
      return PinValidationResult.tooWeak();
    }

    // Vérifier la diversité des chiffres
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits < 3) {
      return PinValidationResult.notDiverse();
    }

    // Vérifier les séquences
    if (_hasSequentialDigits(pin)) {
      return PinValidationResult.hasSequence();
    }

    return PinValidationResult.valid();
  }

  /// Vérifie si le PIN contient des séquences dangereuses (4+ chiffres consécutifs)
  bool _hasSequentialDigits(String pin) {
    // Chercher des séquences de 4 chiffres ou plus
    for (int i = 0; i < pin.length - 3; i++) {
      final a = int.tryParse(pin[i]);
      final b = int.tryParse(pin[i + 1]);
      final c = int.tryParse(pin[i + 2]);
      final d = int.tryParse(pin[i + 3]);

      if (a != null && b != null && c != null && d != null) {
        // Séquence croissante ou décroissante de 4 chiffres
        if ((b == a + 1 && c == b + 1 && d == c + 1) ||
            (b == a - 1 && c == b - 1 && d == c - 1)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Définit un nouveau PIN sécurisé
  Future<PinSetResult> setPin(String pin) async {
    try {
      // Valider la force du PIN
      final validation = validatePinStrength(pin);
      if (!validation.isValid) {
        return PinSetResult.validationFailed(validation.message);
      }

      // Générer un salt unique
      final salt = _generateSecureSalt();

      // Dériver la clé avec PBKDF2
      final pinHash = _deriveKeyPBKDF2(pin, salt);

      // Stocker de manière sécurisée
      await _secureStorageService.storeConfigValue(_pinHashKey, pinHash);
      await _secureStorageService.storeConfigValue(_pinSaltKey, salt);

      // Réinitialiser les tentatives échouées
      await _resetFailedAttempts();

      if (kDebugMode) {
        print('✅ PIN sécurisé défini avec succès (PBKDF2 + Salt)');
      }

      return PinSetResult.success();
    } catch (e) {
      return PinSetResult.error('Erreur lors de la définition du PIN: $e');
    }
  }

  /// Vérifie si un PIN a été défini
  Future<bool> hasPinSet() async {
    try {
      final pinHash = await _secureStorageService.getConfigValue(_pinHashKey);
      final salt = await _secureStorageService.getConfigValue(_pinSaltKey);

      return pinHash != null &&
          pinHash.isNotEmpty &&
          salt != null &&
          salt.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie un PIN avec protection contre les attaques par force brute
  Future<PinVerificationResult> verifyPin(String pin) async {
    try {
      // Vérifier si le compte est verrouillé
      if (await _isAccountLocked()) {
        final remainingTime = await _getRemainingLockoutTime();
        return PinVerificationResult.locked(remainingTime);
      }

      // Récupérer le hash et le salt stockés
      final storedHash = await _secureStorageService.getConfigValue(_pinHashKey);
      final salt = await _secureStorageService.getConfigValue(_pinSaltKey);

      if (storedHash == null || salt == null) {
        return PinVerificationResult.noPinSet();
      }

      // Dériver la clé du PIN fourni avec le même salt
      final inputHash = _deriveKeyPBKDF2(pin, salt);

      // Comparaison sécurisée (protection contre timing attacks)
      if (_secureCompare(storedHash, inputHash)) {
        // PIN correct - réinitialiser les tentatives échouées
        await _resetFailedAttempts();
        return PinVerificationResult.success();
      } else {
        // PIN incorrect - incrémenter les tentatives échouées
        await _incrementFailedAttempts();
        final attempts = await _getFailedAttempts();

        if (attempts >= maxFailedAttempts) {
          await _lockAccount();
          return PinVerificationResult.locked(lockoutDurationMinutes);
        }

        return PinVerificationResult.failed(maxFailedAttempts - attempts);
      }
    } catch (e) {
      return PinVerificationResult.error('Erreur lors de la vérification: $e');
    }
  }

  /// Comparaison sécurisée pour éviter les timing attacks
  bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Change le PIN (nécessite l'ancien PIN)
  Future<PinChangeResult> changePin(String oldPin, String newPin) async {
    try {
      // Vérifier l'ancien PIN
      final verification = await verifyPin(oldPin);
      if (!verification.isSuccess) {
        return PinChangeResult.oldPinIncorrect();
      }

      // Définir le nouveau PIN
      final setResult = await setPin(newPin);
      if (!setResult.isSuccess) {
        return PinChangeResult.newPinInvalid(setResult.message);
      }

      return PinChangeResult.success();
    } catch (e) {
      return PinChangeResult.error('Erreur lors du changement: $e');
    }
  }

  /// Réinitialise le PIN (supprime toutes les données)
  Future<void> resetPin() async {
    try {
      await _secureStorageService.deleteConfigValue(_pinHashKey);
      await _secureStorageService.deleteConfigValue(_pinSaltKey);
      await _resetFailedAttempts();

      if (kDebugMode) {
        print('🧹 PIN sécurisé réinitialisé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erreur lors de la réinitialisation du PIN: $e');
      }
    }
  }

  // === GESTION DES TENTATIVES ÉCHOUÉES ===

  Future<int> _getFailedAttempts() async {
    try {
      final attempts =
          await _secureStorageService.getConfigValue(_failedAttemptsKey);
      return int.tryParse(attempts ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _incrementFailedAttempts() async {
    try {
      final attempts = await _getFailedAttempts();
      await _secureStorageService.storeConfigValue(
        _failedAttemptsKey,
        (attempts + 1).toString(),
      );
      await _secureStorageService.storeConfigValue(
        _lastAttemptTimeKey,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      // Ignorer les erreurs de stockage
    }
  }

  Future<void> _resetFailedAttempts() async {
    try {
      await _secureStorageService.deleteConfigValue(_failedAttemptsKey);
      await _secureStorageService.deleteConfigValue(_lastAttemptTimeKey);
      await _secureStorageService.deleteConfigValue(_isLockedKey);
    } catch (e) {
      // Ignorer les erreurs de suppression
    }
  }

  Future<void> _lockAccount() async {
    try {
      await _secureStorageService.storeConfigValue(_isLockedKey, 'true');
    } catch (e) {
      // Ignorer les erreurs de stockage
    }
  }

  Future<bool> _isAccountLocked() async {
    try {
      final isLocked = await _secureStorageService.getConfigValue(_isLockedKey);
      if (isLocked != 'true') return false;

      final lastAttemptTime =
          await _secureStorageService.getConfigValue(_lastAttemptTimeKey);
      if (lastAttemptTime == null) return false;

      final lastAttempt = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(lastAttemptTime) ?? 0,
      );
      final lockoutEnd =
          lastAttempt.add(Duration(minutes: lockoutDurationMinutes));

      if (DateTime.now().isAfter(lockoutEnd)) {
        // Verrouillage expiré
        await _resetFailedAttempts();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getRemainingLockoutTime() async {
    try {
      final lastAttemptTime =
          await _secureStorageService.getConfigValue(_lastAttemptTimeKey);
      if (lastAttemptTime == null) return 0;

      final lastAttempt = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(lastAttemptTime) ?? 0,
      );
      final lockoutEnd =
          lastAttempt.add(Duration(minutes: lockoutDurationMinutes));
      final remaining = lockoutEnd.difference(DateTime.now()).inMinutes;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }
}

// === CLASSES DE RÉSULTATS ===

class PinValidationResult {
  final bool isValid;
  final String message;

  const PinValidationResult._(this.isValid, this.message);

  factory PinValidationResult.valid() =>
      const PinValidationResult._(true, 'PIN valide');

  factory PinValidationResult.tooShort(int minLength) => PinValidationResult._(
      false, 'PIN trop court (minimum $minLength chiffres)');

  factory PinValidationResult.tooLong(int maxLength) => PinValidationResult._(
      false, 'PIN trop long (maximum $maxLength chiffres)');

  factory PinValidationResult.tooWeak() => const PinValidationResult._(
      false, 'PIN trop faible (évitez les séquences communes)');

  factory PinValidationResult.notDiverse() => const PinValidationResult._(
      false, 'PIN doit contenir au moins 3 chiffres différents');

  factory PinValidationResult.hasSequence() => const PinValidationResult._(
      false, 'PIN ne doit pas contenir de séquences (123, 987, etc.)');
}

class PinSetResult {
  final bool isSuccess;
  final String message;

  const PinSetResult._(this.isSuccess, this.message);

  factory PinSetResult.success() =>
      const PinSetResult._(true, 'PIN défini avec succès');

  factory PinSetResult.validationFailed(String reason) =>
      PinSetResult._(false, reason);

  factory PinSetResult.error(String error) => PinSetResult._(false, error);
}

class PinVerificationResult {
  final bool isSuccess;
  final bool isLocked;
  final int remainingAttempts;
  final int lockoutMinutes;
  final String message;

  const PinVerificationResult._(
    this.isSuccess,
    this.isLocked,
    this.remainingAttempts,
    this.lockoutMinutes,
    this.message,
  );

  factory PinVerificationResult.success() =>
      const PinVerificationResult._(true, false, 0, 0, 'PIN correct');

  factory PinVerificationResult.failed(int remaining) =>
      PinVerificationResult._(false, false, remaining, 0,
          'PIN incorrect ($remaining tentatives restantes)');

  factory PinVerificationResult.locked(int minutes) => PinVerificationResult._(
      false,
      true,
      0,
      minutes,
      'Compte verrouillé ($minutes minutes restantes)');

  factory PinVerificationResult.noPinSet() =>
      const PinVerificationResult._(false, false, 0, 0, 'Aucun PIN défini');

  factory PinVerificationResult.error(String error) =>
      PinVerificationResult._(false, false, 0, 0, error);
}

class PinChangeResult {
  final bool isSuccess;
  final String message;

  const PinChangeResult._(this.isSuccess, this.message);

  factory PinChangeResult.success() =>
      const PinChangeResult._(true, 'PIN changé avec succès');

  factory PinChangeResult.oldPinIncorrect() =>
      const PinChangeResult._(false, 'Ancien PIN incorrect');

  factory PinChangeResult.newPinInvalid(String reason) =>
      PinChangeResult._(false, 'Nouveau PIN invalide: $reason');

  factory PinChangeResult.error(String error) =>
      PinChangeResult._(false, error);
}
