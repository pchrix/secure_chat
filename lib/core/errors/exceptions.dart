/// 🚨 Exceptions personnalisées pour SecureChat
/// 
/// Définit des exceptions spécifiques pour différents types d'erreurs
/// qui peuvent survenir dans l'application.

/// Exception de base pour toutes les exceptions personnalisées
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

// 🌐 Exceptions réseau
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection available',
    code: 'NO_CONNECTION',
  );

  factory NetworkException.timeout() => const NetworkException(
    message: 'Connection timeout',
    code: 'TIMEOUT',
  );

  factory NetworkException.serverError({
    required int statusCode,
    String? serverMessage,
  }) => NetworkException(
    message: serverMessage ?? 'Server error ($statusCode)',
    code: 'SERVER_ERROR',
    details: {'statusCode': statusCode},
  );

  factory NetworkException.badRequest() => const NetworkException(
    message: 'Bad request',
    code: 'BAD_REQUEST',
  );

  factory NetworkException.unauthorized() => const NetworkException(
    message: 'Unauthorized access',
    code: 'UNAUTHORIZED',
  );

  factory NetworkException.forbidden() => const NetworkException(
    message: 'Forbidden access',
    code: 'FORBIDDEN',
  );

  factory NetworkException.notFound() => const NetworkException(
    message: 'Resource not found',
    code: 'NOT_FOUND',
  );
}

// 🔐 Exceptions d'authentification
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid credentials',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthException.userNotFound() => const AuthException(
    message: 'User not found',
    code: 'USER_NOT_FOUND',
  );

  factory AuthException.userAlreadyExists() => const AuthException(
    message: 'User already exists',
    code: 'USER_ALREADY_EXISTS',
  );

  factory AuthException.weakPassword() => const AuthException(
    message: 'Password is too weak',
    code: 'WEAK_PASSWORD',
  );

  factory AuthException.invalidEmail() => const AuthException(
    message: 'Invalid email address',
    code: 'INVALID_EMAIL',
  );

  factory AuthException.emailNotVerified() => const AuthException(
    message: 'Email not verified',
    code: 'EMAIL_NOT_VERIFIED',
  );

  factory AuthException.accountDisabled() => const AuthException(
    message: 'Account disabled',
    code: 'ACCOUNT_DISABLED',
  );

  factory AuthException.tooManyAttempts() => const AuthException(
    message: 'Too many login attempts',
    code: 'TOO_MANY_ATTEMPTS',
  );

  factory AuthException.sessionExpired() => const AuthException(
    message: 'Session expired',
    code: 'SESSION_EXPIRED',
  );

  factory AuthException.invalidPin() => const AuthException(
    message: 'Invalid PIN',
    code: 'INVALID_PIN',
  );

  factory AuthException.pinLocked() => const AuthException(
    message: 'PIN locked',
    code: 'PIN_LOCKED',
  );
}

// 🔒 Exceptions de chiffrement
class EncryptionException extends AppException {
  const EncryptionException({
    required super.message,
    super.code,
    super.details,
  });

  factory EncryptionException.keyGeneration() => const EncryptionException(
    message: 'Failed to generate encryption key',
    code: 'KEY_GENERATION_ERROR',
  );

  factory EncryptionException.encryptionError() => const EncryptionException(
    message: 'Failed to encrypt data',
    code: 'ENCRYPTION_ERROR',
  );

  factory EncryptionException.decryptionError() => const EncryptionException(
    message: 'Failed to decrypt data',
    code: 'DECRYPTION_ERROR',
  );

  factory EncryptionException.invalidKey() => const EncryptionException(
    message: 'Invalid encryption key',
    code: 'INVALID_KEY',
  );

  factory EncryptionException.corruptedData() => const EncryptionException(
    message: 'Data is corrupted or tampered',
    code: 'CORRUPTED_DATA',
  );

  factory EncryptionException.unsupportedAlgorithm() => const EncryptionException(
    message: 'Unsupported encryption algorithm',
    code: 'UNSUPPORTED_ALGORITHM',
  );
}

// 💾 Exceptions de stockage
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });

  factory StorageException.readError({required String key}) => StorageException(
    message: 'Failed to read data',
    code: 'READ_ERROR',
    details: {'key': key},
  );

  factory StorageException.writeError({required String key}) => StorageException(
    message: 'Failed to write data',
    code: 'WRITE_ERROR',
    details: {'key': key},
  );

  factory StorageException.deleteError({required String key}) => StorageException(
    message: 'Failed to delete data',
    code: 'DELETE_ERROR',
    details: {'key': key},
  );

  factory StorageException.notFound({required String key}) => StorageException(
    message: 'Data not found',
    code: 'NOT_FOUND',
    details: {'key': key},
  );

  factory StorageException.insufficientSpace() => const StorageException(
    message: 'Insufficient storage space',
    code: 'INSUFFICIENT_SPACE',
  );

  factory StorageException.permissionDenied() => const StorageException(
    message: 'Storage permission denied',
    code: 'PERMISSION_DENIED',
  );

  factory StorageException.migrationError() => const StorageException(
    message: 'Data migration failed',
    code: 'MIGRATION_ERROR',
  );
}

// 📝 Exceptions de validation
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });

  factory ValidationException.invalidInput({
    required String field,
    required String reason,
  }) => ValidationException(
    message: 'Invalid input for field "$field": $reason',
    code: 'INVALID_INPUT',
    details: {'field': field, 'reason': reason},
  );

  factory ValidationException.requiredField({required String field}) => ValidationException(
    message: 'Field "$field" is required',
    code: 'REQUIRED_FIELD',
    details: {'field': field},
  );

  factory ValidationException.invalidFormat({
    required String field,
    required String expectedFormat,
  }) => ValidationException(
    message: 'Invalid format for "$field". Expected: $expectedFormat',
    code: 'INVALID_FORMAT',
    details: {'field': field, 'expectedFormat': expectedFormat},
  );

  factory ValidationException.outOfRange({
    required String field,
    required String range,
  }) => ValidationException(
    message: 'Value out of range for "$field". Allowed range: $range',
    code: 'OUT_OF_RANGE',
    details: {'field': field, 'range': range},
  );
}

// 🏠 Exceptions métier
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    super.code,
    super.details,
  });

  factory BusinessException.roomNotFound() => const BusinessException(
    message: 'Room not found',
    code: 'ROOM_NOT_FOUND',
  );

  factory BusinessException.roomFull() => const BusinessException(
    message: 'Room is full',
    code: 'ROOM_FULL',
  );

  factory BusinessException.accessDenied() => const BusinessException(
    message: 'Access denied',
    code: 'ACCESS_DENIED',
  );

  factory BusinessException.messageNotFound() => const BusinessException(
    message: 'Message not found',
    code: 'MESSAGE_NOT_FOUND',
  );

  factory BusinessException.invalidOperation() => const BusinessException(
    message: 'Invalid operation',
    code: 'INVALID_OPERATION',
  );

  factory BusinessException.rateLimitExceeded() => const BusinessException(
    message: 'Rate limit exceeded',
    code: 'RATE_LIMIT_EXCEEDED',
  );
}

// 🔧 Exceptions système
class SystemException extends AppException {
  const SystemException({
    required super.message,
    super.code,
    super.details,
  });

  factory SystemException.unexpected({
    required String error,
    StackTrace? stackTrace,
  }) => SystemException(
    message: 'Unexpected system error',
    code: 'UNEXPECTED_ERROR',
    details: {
      'error': error,
      'stackTrace': stackTrace?.toString(),
    },
  );

  factory SystemException.platformNotSupported() => const SystemException(
    message: 'Platform not supported',
    code: 'PLATFORM_NOT_SUPPORTED',
  );

  factory SystemException.featureNotAvailable() => const SystemException(
    message: 'Feature not available',
    code: 'FEATURE_NOT_AVAILABLE',
  );

  factory SystemException.configurationError() => const SystemException(
    message: 'Configuration error',
    code: 'CONFIGURATION_ERROR',
  );
}
