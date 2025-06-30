/// 🔐 Entité AuthState - État d'authentification
/// 
/// Représente l'état d'authentification de l'utilisateur dans le domaine métier.

import 'package:equatable/equatable.dart';
import 'user.dart';

/// État d'authentification de l'application
class AuthState extends Equatable {
  const AuthState({
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

  /// Statut d'authentification actuel
  final AuthStatus status;

  /// Utilisateur connecté (null si non connecté)
  final User? user;

  /// Token d'authentification
  final String? token;

  /// Token de rafraîchissement
  final String? refreshToken;

  /// Date d'expiration du token
  final DateTime? expiresAt;

  /// Date de dernière connexion
  final DateTime? lastLoginAt;

  /// Nombre de tentatives de connexion échouées
  final int loginAttempts;

  /// Indique si le compte est verrouillé
  final bool isLocked;

  /// Date jusqu'à laquelle le compte est verrouillé
  final DateTime? lockUntil;

  /// Indique si une vérification PIN est requise
  final bool requiresPinVerification;

  /// Indique si l'authentification biométrique est activée
  final bool biometricEnabled;

  /// Identifiant de session
  final String? sessionId;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  /// Vérifie si l'utilisateur est en cours d'authentification
  bool get isAuthenticating => status == AuthStatus.authenticating;

  /// Vérifie si l'utilisateur n'est pas authentifié
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Vérifie si le token est expiré
  bool get isTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Vérifie si le compte est actuellement verrouillé
  bool get isCurrentlyLocked {
    if (!isLocked || lockUntil == null) return false;
    return DateTime.now().isBefore(lockUntil!);
  }

  /// Temps restant avant déverrouillage (en minutes)
  int get minutesUntilUnlock {
    if (!isCurrentlyLocked) return 0;
    final now = DateTime.now();
    final difference = lockUntil!.difference(now);
    return difference.inMinutes;
  }

  /// Vérifie si une nouvelle tentative de connexion est autorisée
  bool get canAttemptLogin {
    return !isCurrentlyLocked && loginAttempts < 5; // Max 5 tentatives
  }

  /// Vérifie si le token doit être rafraîchi bientôt (dans les 5 prochaines minutes)
  bool get shouldRefreshToken {
    if (expiresAt == null) return false;
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt!.difference(now);
    return timeUntilExpiry.inMinutes <= 5;
  }

  /// Crée un état initial non authentifié
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Crée un état d'authentification en cours
  factory AuthState.authenticating() {
    return const AuthState(status: AuthStatus.authenticating);
  }

  /// Crée un état authentifié avec un utilisateur
  factory AuthState.authenticated({
    required User user,
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
    String? sessionId,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      lastLoginAt: DateTime.now(),
      sessionId: sessionId,
    );
  }

  /// Crée un état non authentifié
  factory AuthState.unauthenticated({String? reason}) {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Crée un état d'erreur
  factory AuthState.error({required String message}) {
    return AuthState(
      status: AuthStatus.error,
    );
  }

  /// Crée un état verrouillé
  factory AuthState.locked({
    required DateTime lockUntil,
    required int attempts,
  }) {
    return AuthState(
      status: AuthStatus.locked,
      isLocked: true,
      lockUntil: lockUntil,
      loginAttempts: attempts,
    );
  }

  /// Crée une copie avec des modifications
  AuthState copyWith({
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
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      isLocked: isLocked ?? this.isLocked,
      lockUntil: lockUntil ?? this.lockUntil,
      requiresPinVerification: requiresPinVerification ?? this.requiresPinVerification,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  /// Réinitialise les tentatives de connexion
  AuthState resetLoginAttempts() {
    return copyWith(
      loginAttempts: 0,
      isLocked: false,
      lockUntil: null,
    );
  }

  /// Incrémente les tentatives de connexion
  AuthState incrementLoginAttempts() {
    final newAttempts = loginAttempts + 1;
    
    // Verrouiller après 5 tentatives
    if (newAttempts >= 5) {
      final lockUntil = DateTime.now().add(const Duration(minutes: 15));
      return copyWith(
        loginAttempts: newAttempts,
        isLocked: true,
        lockUntil: lockUntil,
        status: AuthStatus.locked,
      );
    }
    
    return copyWith(loginAttempts: newAttempts);
  }

  @override
  List<Object?> get props => [
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
      ];

  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: ${user?.username}, '
        'isAuthenticated: $isAuthenticated, '
        'loginAttempts: $loginAttempts, '
        'isLocked: $isLocked'
        ')';
  }
}

/// Statuts d'authentification possibles
enum AuthStatus {
  /// État initial, avant toute tentative d'authentification
  initial,
  
  /// Authentification en cours
  authenticating,
  
  /// Utilisateur authentifié avec succès
  authenticated,
  
  /// Utilisateur non authentifié
  unauthenticated,
  
  /// Compte verrouillé après trop de tentatives
  locked,
  
  /// Erreur d'authentification
  error,
  
  /// Token expiré, rafraîchissement nécessaire
  tokenExpired,
  
  /// Vérification PIN requise
  pinRequired,
  
  /// Vérification biométrique requise
  biometricRequired,
}

/// Extension pour obtenir des informations sur le statut d'authentification
extension AuthStatusExtension on AuthStatus {
  /// Obtient une description lisible du statut
  String get description {
    switch (this) {
      case AuthStatus.initial:
        return 'Initialisation';
      case AuthStatus.authenticating:
        return 'Authentification en cours';
      case AuthStatus.authenticated:
        return 'Authentifié';
      case AuthStatus.unauthenticated:
        return 'Non authentifié';
      case AuthStatus.locked:
        return 'Compte verrouillé';
      case AuthStatus.error:
        return 'Erreur d\'authentification';
      case AuthStatus.tokenExpired:
        return 'Session expirée';
      case AuthStatus.pinRequired:
        return 'Code PIN requis';
      case AuthStatus.biometricRequired:
        return 'Authentification biométrique requise';
    }
  }

  /// Vérifie si le statut indique un état de chargement
  bool get isLoading {
    return this == AuthStatus.authenticating;
  }

  /// Vérifie si le statut indique une erreur
  bool get isError {
    return this == AuthStatus.error || this == AuthStatus.locked;
  }

  /// Vérifie si le statut indique un succès
  bool get isSuccess {
    return this == AuthStatus.authenticated;
  }
}
