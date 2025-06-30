/// 🔐 Auth State Model - Modèle d'état d'authentification pour la couche Data
///
/// Modèle de données qui étend l'entité AuthState du domaine et ajoute
/// les fonctionnalités de sérialisation/désérialisation pour l'API.

import '../../domain/entities/auth_state.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

/// Modèle d'état d'authentification pour la couche Data
class AuthStateModel {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? lastLoginAt;
  final int loginAttempts;
  final bool isLocked;
  final DateTime? lockUntil;
  final bool requiresPinVerification;
  final bool biometricEnabled;
  final String? sessionId;

  const AuthStateModel({
    required this.status,
    this.user,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.lastLoginAt,
    this.loginAttempts = 0,
    this.isLocked = false,
    this.lockUntil,
    this.requiresPinVerification = false,
    this.biometricEnabled = false,
    this.sessionId,
  });

  /// Crée un AuthStateModel à partir d'un Map JSON
  factory AuthStateModel.fromJson(Map<String, dynamic> json) {
    return AuthStateModel(
      status: AuthStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AuthStatus.unauthenticated,
      ),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>).toEntity()
          : null,
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      loginAttempts: json['login_attempts'] as int? ?? 0,
      isLocked: json['is_locked'] as bool? ?? false,
      lockUntil: json['lock_until'] != null
          ? DateTime.parse(json['lock_until'] as String)
          : null,
      requiresPinVerification:
          json['requires_pin_verification'] as bool? ?? false,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      sessionId: json['session_id'] as String?,
    );
  }

  /// Convertit l'AuthStateModel en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'user': user != null ? UserModel.fromEntity(user!).toJson() : null,
      'token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'login_attempts': loginAttempts,
      'is_locked': isLocked,
      'lock_until': lockUntil?.toIso8601String(),
      'requires_pin_verification': requiresPinVerification,
      'biometric_enabled': biometricEnabled,
      'session_id': sessionId,
    };
  }

  /// Crée une copie de l'AuthStateModel avec des valeurs modifiées
  AuthStateModel copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? lastLoginAt,
    int? loginAttempts,
    bool? isLocked,
    DateTime? lockUntil,
    bool? requiresPinVerification,
    bool? biometricEnabled,
    String? sessionId,
  }) {
    return AuthStateModel(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockUntil: lockUntil ?? this.lockUntil,
      requiresPinVerification:
          requiresPinVerification ?? this.requiresPinVerification,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Convertit l'AuthStateModel en entité AuthState du domaine
  AuthState toEntity() {
    return AuthState(
      status: status,
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      lastLoginAt: lastLoginAt,
      loginAttempts: loginAttempts,
      isLocked: isLocked,
      lockUntil: lockUntil,
      requiresPinVerification: requiresPinVerification,
      biometricEnabled: biometricEnabled,
      sessionId: sessionId,
    );
  }

  /// Crée un état de chargement
  factory AuthStateModel.loading({User? user}) {
    return AuthStateModel(
      status:
          user != null ? AuthStatus.authenticated : AuthStatus.authenticating,
      user: user,
    );
  }

  /// Crée un état d'erreur
  factory AuthStateModel.error({
    required String errorMessage,
    User? user,
  }) {
    return AuthStateModel(
      status: AuthStatus.error,
      user: user,
    );
  }

  /// Crée un état authentifié
  factory AuthStateModel.authenticated({required User user}) {
    return AuthStateModel(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  /// Crée un état non authentifié
  factory AuthStateModel.unauthenticated() {
    return const AuthStateModel(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  /// Crée un état initial
  factory AuthStateModel.initial() {
    return const AuthStateModel(
      status: AuthStatus.initial,
      user: null,
    );
  }

  @override
  String toString() {
    return 'AuthStateModel('
        'status: $status, '
        'user: ${user?.id}, '
        'token: ${token != null ? '[HIDDEN]' : null}, '
        'sessionId: $sessionId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthStateModel &&
        other.status == status &&
        other.user == user &&
        other.token == token &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt &&
        other.lastLoginAt == lastLoginAt &&
        other.loginAttempts == loginAttempts &&
        other.isLocked == isLocked &&
        other.lockUntil == lockUntil &&
        other.requiresPinVerification == requiresPinVerification &&
        other.biometricEnabled == biometricEnabled &&
        other.sessionId == sessionId;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      user,
      token,
      refreshToken,
      expiresAt,
      lastLoginAt,
      loginAttempts,
      isLocked,
      lockUntil,
      requiresPinVerification,
      biometricEnabled,
      sessionId,
    );
  }
}

/// Extensions utiles pour AuthStateModel
extension AuthStateModelExtensions on AuthStateModel {
  /// Vérifie si l'état est dans un état stable (pas de chargement)
  bool get isStable => status != AuthStatus.authenticating;

  /// Vérifie si l'état a une erreur
  bool get hasError => status == AuthStatus.error;

  /// Vérifie si l'état est prêt (stable et sans erreur)
  bool get isReady => isStable && !hasError;

  /// Vérifie si l'utilisateur est connecté et vérifié
  bool get isUserVerified {
    return status == AuthStatus.authenticated &&
        user != null &&
        user!.isEmailVerified;
  }

  /// Obtient un message d'état lisible
  String get statusMessage {
    if (status == AuthStatus.authenticating) {
      return 'Chargement...';
    }

    if (hasError) {
      return status.description;
    }

    if (status == AuthStatus.authenticated && user != null) {
      if (!user!.isEmailVerified) {
        return 'Email non confirmé';
      }
      return 'Connecté en tant que ${user!.email}';
    }

    return 'Non connecté';
  }

  /// Obtient le niveau de sécurité de l'état
  AuthSecurityLevel get securityLevel {
    if (status != AuthStatus.authenticated || user == null) {
      return AuthSecurityLevel.none;
    }

    if (!user!.isEmailVerified) {
      return AuthSecurityLevel.low;
    }

    // Ici on pourrait ajouter d'autres vérifications
    // comme la 2FA, la vérification du téléphone, etc.
    return AuthSecurityLevel.medium;
  }

  /// Vérifie si l'état nécessite une action de l'utilisateur
  bool get requiresUserAction {
    if (status != AuthStatus.authenticated) return false;
    if (user == null) return true;
    if (!user!.isEmailVerified) return true;

    return false;
  }

  /// Obtient le message d'action requis
  String? get requiredActionMessage {
    if (!requiresUserAction) return null;

    if (user == null) {
      return 'Veuillez vous reconnecter';
    }

    if (!user!.isEmailVerified) {
      return 'Veuillez confirmer votre email';
    }

    return null;
  }
}

/// Niveaux de sécurité d'authentification
enum AuthSecurityLevel {
  none, // Non connecté
  low, // Connecté mais email non confirmé
  medium, // Connecté avec email confirmé
  high, // Connecté avec 2FA activé
  maximum, // Connecté avec toutes les sécurités activées
}

/// Extension pour AuthSecurityLevel
extension AuthSecurityLevelExtension on AuthSecurityLevel {
  /// Obtient une description du niveau de sécurité
  String get description {
    switch (this) {
      case AuthSecurityLevel.none:
        return 'Aucune sécurité';
      case AuthSecurityLevel.low:
        return 'Sécurité faible';
      case AuthSecurityLevel.medium:
        return 'Sécurité moyenne';
      case AuthSecurityLevel.high:
        return 'Sécurité élevée';
      case AuthSecurityLevel.maximum:
        return 'Sécurité maximale';
    }
  }

  /// Obtient la couleur associée au niveau de sécurité
  String get colorHex {
    switch (this) {
      case AuthSecurityLevel.none:
        return '#9CA3AF'; // Gris
      case AuthSecurityLevel.low:
        return '#EF4444'; // Rouge
      case AuthSecurityLevel.medium:
        return '#F59E0B'; // Orange
      case AuthSecurityLevel.high:
        return '#10B981'; // Vert
      case AuthSecurityLevel.maximum:
        return '#3B82F6'; // Bleu
    }
  }

  /// Obtient l'icône associée au niveau de sécurité
  String get icon {
    switch (this) {
      case AuthSecurityLevel.none:
        return '🔓';
      case AuthSecurityLevel.low:
        return '⚠️';
      case AuthSecurityLevel.medium:
        return '🔒';
      case AuthSecurityLevel.high:
        return '🛡️';
      case AuthSecurityLevel.maximum:
        return '🔐';
    }
  }

  /// Vérifie si le niveau est suffisant pour une action donnée
  bool isSufficientFor(AuthSecurityLevel required) {
    return index >= required.index;
  }
}
