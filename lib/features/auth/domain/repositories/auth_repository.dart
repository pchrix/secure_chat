/// 🔐 Interface AuthRepository - Contrat pour l'authentification
/// 
/// Définit les opérations d'authentification disponibles dans le domaine métier.
/// Cette interface sera implémentée dans la couche data.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/auth_state.dart';

/// Interface du repository d'authentification
abstract class AuthRepository {
  // 🔑 Authentification de base
  
  /// Connecte un utilisateur avec email et mot de passe
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Inscrit un nouvel utilisateur
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? displayName,
  });

  /// Déconnecte l'utilisateur actuel
  Future<Either<Failure, void>> signOut();

  /// Rafraîchit le token d'authentification
  Future<Either<Failure, String>> refreshToken({
    required String refreshToken,
  });

  // 👤 Gestion du profil utilisateur
  
  /// Obtient l'utilisateur actuellement connecté
  Future<Either<Failure, User?>> getCurrentUser();

  /// Met à jour le profil utilisateur
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    UserPreferences? preferences,
  });

  /// Change le mot de passe de l'utilisateur
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Supprime le compte utilisateur
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  });

  // 📧 Gestion des emails
  
  /// Envoie un email de vérification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Vérifie l'email avec un code
  Future<Either<Failure, void>> verifyEmail({
    required String verificationCode,
  });

  /// Envoie un email de réinitialisation de mot de passe
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Réinitialise le mot de passe avec un code
  Future<Either<Failure, void>> resetPasswordWithCode({
    required String email,
    required String resetCode,
    required String newPassword,
  });

  // 🔐 Authentification avancée
  
  /// Configure l'authentification PIN
  Future<Either<Failure, void>> setupPin({
    required String pin,
  });

  /// Vérifie le PIN
  Future<Either<Failure, bool>> verifyPin({
    required String pin,
  });

  /// Change le PIN
  Future<Either<Failure, void>> changePin({
    required String currentPin,
    required String newPin,
  });

  /// Supprime le PIN
  Future<Either<Failure, void>> removePin({
    required String currentPin,
  });

  /// Vérifie si l'authentification biométrique est disponible
  Future<Either<Failure, bool>> isBiometricAvailable();

  /// Active l'authentification biométrique
  Future<Either<Failure, void>> enableBiometricAuth();

  /// Désactive l'authentification biométrique
  Future<Either<Failure, void>> disableBiometricAuth();

  /// Authentifie avec la biométrie
  Future<Either<Failure, bool>> authenticateWithBiometric({
    String? reason,
  });

  // 🔄 Gestion des sessions
  
  /// Obtient l'état d'authentification actuel
  Future<Either<Failure, AuthState>> getAuthState();

  /// Vérifie si l'utilisateur est connecté
  Future<Either<Failure, bool>> isSignedIn();

  /// Vérifie la validité du token
  Future<Either<Failure, bool>> isTokenValid();

  /// Invalide toutes les sessions
  Future<Either<Failure, void>> invalidateAllSessions();

  /// Met à jour le statut en ligne de l'utilisateur
  Future<Either<Failure, void>> updateOnlineStatus({
    required bool isOnline,
  });

  // 📱 Gestion des appareils
  
  /// Enregistre un nouvel appareil
  Future<Either<Failure, void>> registerDevice({
    required String deviceId,
    required String deviceName,
    required String platform,
  });

  /// Désenregistre un appareil
  Future<Either<Failure, void>> unregisterDevice({
    required String deviceId,
  });

  /// Obtient la liste des appareils connectés
  Future<Either<Failure, List<UserDevice>>> getConnectedDevices();

  /// Déconnecte un appareil spécifique
  Future<Either<Failure, void>> signOutDevice({
    required String deviceId,
  });

  // 🔒 Sécurité et audit
  
  /// Obtient l'historique des connexions
  Future<Either<Failure, List<LoginAttempt>>> getLoginHistory({
    int? limit,
    DateTime? since,
  });

  /// Signale une activité suspecte
  Future<Either<Failure, void>> reportSuspiciousActivity({
    required String description,
    Map<String, dynamic>? metadata,
  });

  /// Vérifie s'il y a des connexions suspectes
  Future<Either<Failure, List<SuspiciousActivity>>> checkSuspiciousActivity();

  // 🔔 Streams pour les changements d'état
  
  /// Stream des changements d'état d'authentification
  Stream<AuthState> get authStateStream;

  /// Stream des changements d'utilisateur
  Stream<User?> get userStream;

  /// Stream des changements de statut en ligne
  Stream<bool> get onlineStatusStream;
}

/// Représente un appareil connecté
class UserDevice {
  const UserDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.lastUsedAt,
    required this.isCurrentDevice,
    this.location,
    this.ipAddress,
  });

  final String id;
  final String name;
  final String platform;
  final DateTime lastUsedAt;
  final bool isCurrentDevice;
  final String? location;
  final String? ipAddress;
}

/// Représente une tentative de connexion
class LoginAttempt {
  const LoginAttempt({
    required this.id,
    required this.timestamp,
    required this.success,
    required this.ipAddress,
    this.location,
    this.userAgent,
    this.failureReason,
  });

  final String id;
  final DateTime timestamp;
  final bool success;
  final String ipAddress;
  final String? location;
  final String? userAgent;
  final String? failureReason;
}

/// Représente une activité suspecte
class SuspiciousActivity {
  const SuspiciousActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.metadata,
  });

  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final SuspiciousActivitySeverity severity;
  final Map<String, dynamic>? metadata;
}

/// Niveaux de sévérité pour les activités suspectes
enum SuspiciousActivitySeverity {
  low,
  medium,
  high,
  critical,
}

/// Extension pour la sévérité des activités suspectes
extension SuspiciousActivitySeverityExtension on SuspiciousActivitySeverity {
  String get label {
    switch (this) {
      case SuspiciousActivitySeverity.low:
        return 'Faible';
      case SuspiciousActivitySeverity.medium:
        return 'Moyen';
      case SuspiciousActivitySeverity.high:
        return 'Élevé';
      case SuspiciousActivitySeverity.critical:
        return 'Critique';
    }
  }

  String get colorHex {
    switch (this) {
      case SuspiciousActivitySeverity.low:
        return '#10B981'; // Vert
      case SuspiciousActivitySeverity.medium:
        return '#F59E0B'; // Orange
      case SuspiciousActivitySeverity.high:
        return '#EF4444'; // Rouge
      case SuspiciousActivitySeverity.critical:
        return '#7C2D12'; // Rouge foncé
    }
  }
}
