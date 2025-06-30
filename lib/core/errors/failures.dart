/// 🚨 Gestion centralisée des erreurs et échecs
/// 
/// Définit une hiérarchie d'erreurs typées pour une gestion d'erreurs
/// robuste et prévisible à travers toute l'application.

import 'package:equatable/equatable.dart';

/// Classe de base abstraite pour tous les échecs
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  /// Message d'erreur lisible par l'utilisateur
  final String message;
  
  /// Code d'erreur optionnel pour le debugging
  final String? code;
  
  /// Détails supplémentaires pour le debugging
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => 'Failure(message: $message, code: $code, details: $details)';
}

// 🌐 Échecs réseau
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'Aucune connexion internet disponible',
    code: 'NO_CONNECTION',
  );

  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Délai de connexion dépassé',
    code: 'TIMEOUT',
  );

  factory NetworkFailure.serverError({
    required int statusCode,
    String? serverMessage,
  }) => NetworkFailure(
    message: serverMessage ?? 'Erreur serveur ($statusCode)',
    code: 'SERVER_ERROR',
    details: {'statusCode': statusCode, 'serverMessage': serverMessage},
  );

  factory NetworkFailure.badRequest({
    required String reason,
  }) => NetworkFailure(
    message: 'Requête invalide: $reason',
    code: 'BAD_REQUEST',
    details: {'reason': reason},
  );

  factory NetworkFailure.unauthorized() => const NetworkFailure(
    message: 'Accès non autorisé',
    code: 'UNAUTHORIZED',
  );

  factory NetworkFailure.forbidden() => const NetworkFailure(
    message: 'Accès interdit',
    code: 'FORBIDDEN',
  );

  factory NetworkFailure.notFound() => const NetworkFailure(
    message: 'Ressource non trouvée',
    code: 'NOT_FOUND',
  );
}

// 🔐 Échecs d'authentification
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
    message: 'Identifiants invalides',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthFailure.userNotFound() => const AuthFailure(
    message: 'Utilisateur non trouvé',
    code: 'USER_NOT_FOUND',
  );

  factory AuthFailure.userAlreadyExists() => const AuthFailure(
    message: 'Un utilisateur avec cet email existe déjà',
    code: 'USER_ALREADY_EXISTS',
  );

  factory AuthFailure.weakPassword() => const AuthFailure(
    message: 'Le mot de passe est trop faible',
    code: 'WEAK_PASSWORD',
  );

  factory AuthFailure.invalidEmail() => const AuthFailure(
    message: 'Adresse email invalide',
    code: 'INVALID_EMAIL',
  );

  factory AuthFailure.emailNotVerified() => const AuthFailure(
    message: 'Email non vérifié',
    code: 'EMAIL_NOT_VERIFIED',
  );

  factory AuthFailure.accountDisabled() => const AuthFailure(
    message: 'Compte désactivé',
    code: 'ACCOUNT_DISABLED',
  );

  factory AuthFailure.tooManyAttempts() => const AuthFailure(
    message: 'Trop de tentatives de connexion. Réessayez plus tard.',
    code: 'TOO_MANY_ATTEMPTS',
  );

  factory AuthFailure.sessionExpired() => const AuthFailure(
    message: 'Session expirée. Veuillez vous reconnecter.',
    code: 'SESSION_EXPIRED',
  );

  factory AuthFailure.invalidPin() => const AuthFailure(
    message: 'Code PIN invalide',
    code: 'INVALID_PIN',
  );

  factory AuthFailure.pinLocked() => const AuthFailure(
    message: 'Code PIN verrouillé. Réessayez plus tard.',
    code: 'PIN_LOCKED',
  );
}

// 🔒 Échecs de chiffrement
class EncryptionFailure extends Failure {
  const EncryptionFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory EncryptionFailure.keyGeneration() => const EncryptionFailure(
    message: 'Erreur lors de la génération de la clé de chiffrement',
    code: 'KEY_GENERATION_ERROR',
  );

  factory EncryptionFailure.encryptionError() => const EncryptionFailure(
    message: 'Erreur lors du chiffrement des données',
    code: 'ENCRYPTION_ERROR',
  );

  factory EncryptionFailure.decryptionError() => const EncryptionFailure(
    message: 'Erreur lors du déchiffrement des données',
    code: 'DECRYPTION_ERROR',
  );

  factory EncryptionFailure.invalidKey() => const EncryptionFailure(
    message: 'Clé de chiffrement invalide',
    code: 'INVALID_KEY',
  );

  factory EncryptionFailure.corruptedData() => const EncryptionFailure(
    message: 'Données corrompues ou altérées',
    code: 'CORRUPTED_DATA',
  );

  factory EncryptionFailure.unsupportedAlgorithm() => const EncryptionFailure(
    message: 'Algorithme de chiffrement non supporté',
    code: 'UNSUPPORTED_ALGORITHM',
  );
}

// 💾 Échecs de stockage
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageFailure.readError({required String key}) => StorageFailure(
    message: 'Erreur lors de la lecture des données',
    code: 'READ_ERROR',
    details: {'key': key},
  );

  factory StorageFailure.writeError({required String key}) => StorageFailure(
    message: 'Erreur lors de l\'écriture des données',
    code: 'WRITE_ERROR',
    details: {'key': key},
  );

  factory StorageFailure.deleteError({required String key}) => StorageFailure(
    message: 'Erreur lors de la suppression des données',
    code: 'DELETE_ERROR',
    details: {'key': key},
  );

  factory StorageFailure.notFound({required String key}) => StorageFailure(
    message: 'Données non trouvées',
    code: 'NOT_FOUND',
    details: {'key': key},
  );

  factory StorageFailure.insufficientSpace() => const StorageFailure(
    message: 'Espace de stockage insuffisant',
    code: 'INSUFFICIENT_SPACE',
  );

  factory StorageFailure.permissionDenied() => const StorageFailure(
    message: 'Permission d\'accès au stockage refusée',
    code: 'PERMISSION_DENIED',
  );

  factory StorageFailure.migrationError() => const StorageFailure(
    message: 'Erreur lors de la migration des données',
    code: 'MIGRATION_ERROR',
  );
}

// 📝 Échecs de validation
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory ValidationFailure.invalidInput({
    required String field,
    required String reason,
  }) => ValidationFailure(
    message: 'Champ "$field" invalide: $reason',
    code: 'INVALID_INPUT',
    details: {'field': field, 'reason': reason},
  );

  factory ValidationFailure.requiredField({required String field}) => ValidationFailure(
    message: 'Le champ "$field" est obligatoire',
    code: 'REQUIRED_FIELD',
    details: {'field': field},
  );

  factory ValidationFailure.invalidFormat({
    required String field,
    required String expectedFormat,
  }) => ValidationFailure(
    message: 'Format invalide pour "$field". Format attendu: $expectedFormat',
    code: 'INVALID_FORMAT',
    details: {'field': field, 'expectedFormat': expectedFormat},
  );

  factory ValidationFailure.outOfRange({
    required String field,
    required String range,
  }) => ValidationFailure(
    message: 'Valeur hors limites pour "$field". Plage autorisée: $range',
    code: 'OUT_OF_RANGE',
    details: {'field': field, 'range': range},
  );
}

// 🏠 Échecs métier (business logic)
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory BusinessFailure.roomNotFound() => const BusinessFailure(
    message: 'Salon non trouvé',
    code: 'ROOM_NOT_FOUND',
  );

  factory BusinessFailure.roomFull() => const BusinessFailure(
    message: 'Le salon est complet',
    code: 'ROOM_FULL',
  );

  factory BusinessFailure.accessDenied() => const BusinessFailure(
    message: 'Accès refusé à cette ressource',
    code: 'ACCESS_DENIED',
  );

  factory BusinessFailure.messageNotFound() => const BusinessFailure(
    message: 'Message non trouvé',
    code: 'MESSAGE_NOT_FOUND',
  );

  factory BusinessFailure.invalidOperation() => const BusinessFailure(
    message: 'Opération non autorisée dans le contexte actuel',
    code: 'INVALID_OPERATION',
  );

  factory BusinessFailure.rateLimitExceeded() => const BusinessFailure(
    message: 'Limite de fréquence dépassée. Veuillez patienter.',
    code: 'RATE_LIMIT_EXCEEDED',
  );
}

// 🔧 Échecs système
class SystemFailure extends Failure {
  const SystemFailure({
    required super.message,
    super.code,
    super.details,
  });

  factory SystemFailure.unexpected({
    required String error,
    StackTrace? stackTrace,
  }) => SystemFailure(
    message: 'Erreur système inattendue',
    code: 'UNEXPECTED_ERROR',
    details: {
      'error': error,
      'stackTrace': stackTrace?.toString(),
    },
  );

  factory SystemFailure.platformNotSupported() => const SystemFailure(
    message: 'Plateforme non supportée',
    code: 'PLATFORM_NOT_SUPPORTED',
  );

  factory SystemFailure.featureNotAvailable() => const SystemFailure(
    message: 'Fonctionnalité non disponible',
    code: 'FEATURE_NOT_AVAILABLE',
  );

  factory SystemFailure.configurationError() => const SystemFailure(
    message: 'Erreur de configuration',
    code: 'CONFIGURATION_ERROR',
  );
}
