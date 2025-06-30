/// 🚪 Use Case SignOut - Déconnexion utilisateur
///
/// Gère la logique métier pour la déconnexion d'un utilisateur.
/// Nettoie les données de session et invalide les tokens.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la déconnexion d'un utilisateur
class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    try {
      // Déconnexion via le repository
      return await repository.signOut();
    } catch (e) {
      // En cas d'erreur inattendue, on retourne un échec système
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Use case pour la déconnexion avec options avancées
class SignOutWithOptionsUseCase implements UseCase<void, SignOutOptions> {
  final AuthRepository repository;

  const SignOutWithOptionsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SignOutOptions params) async {
    try {
      // Déconnexion de base
      final signOutResult = await repository.signOut();

      if (signOutResult.isLeft()) {
        return signOutResult;
      }

      // Actions supplémentaires selon les options
      if (params.invalidateAllSessions) {
        final invalidateResult = await repository.invalidateAllSessions();
        if (invalidateResult.isLeft()) {
          // Log l'erreur mais ne fait pas échouer la déconnexion
          // car l'utilisateur est déjà déconnecté localement
        }
      }

      if (params.clearLocalData) {
        // Ici on pourrait ajouter la logique pour nettoyer
        // les données locales (cache, préférences, etc.)
        // Pour l'instant, on considère que c'est fait par le repository
      }

      return const Right(null);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Options pour la déconnexion avancée
class SignOutOptions {
  /// Invalider toutes les sessions sur tous les appareils
  final bool invalidateAllSessions;

  /// Nettoyer toutes les données locales
  final bool clearLocalData;

  /// Raison de la déconnexion (pour les logs)
  final SignOutReason reason;

  const SignOutOptions({
    this.invalidateAllSessions = false,
    this.clearLocalData = false,
    this.reason = SignOutReason.userInitiated,
  });

  /// Options par défaut pour une déconnexion simple
  factory SignOutOptions.simple() {
    return const SignOutOptions();
  }

  /// Options pour une déconnexion complète (sécurité)
  factory SignOutOptions.complete() {
    return const SignOutOptions(
      invalidateAllSessions: true,
      clearLocalData: true,
      reason: SignOutReason.security,
    );
  }

  /// Options pour une déconnexion forcée (session expirée)
  factory SignOutOptions.forced() {
    return const SignOutOptions(
      invalidateAllSessions: false,
      clearLocalData: true,
      reason: SignOutReason.sessionExpired,
    );
  }

  @override
  String toString() {
    return 'SignOutOptions('
        'invalidateAllSessions: $invalidateAllSessions, '
        'clearLocalData: $clearLocalData, '
        'reason: $reason'
        ')';
  }
}

/// Raisons possibles pour une déconnexion
enum SignOutReason {
  /// Déconnexion initiée par l'utilisateur
  userInitiated,

  /// Déconnexion pour des raisons de sécurité
  security,

  /// Session expirée
  sessionExpired,

  /// Déconnexion automatique (inactivité)
  inactivity,

  /// Erreur d'authentification
  authError,

  /// Maintenance du système
  maintenance,
}

/// Extension pour obtenir des informations sur la raison de déconnexion
extension SignOutReasonExtension on SignOutReason {
  /// Obtient une description lisible de la raison
  String get description {
    switch (this) {
      case SignOutReason.userInitiated:
        return 'Déconnexion demandée par l\'utilisateur';
      case SignOutReason.security:
        return 'Déconnexion pour des raisons de sécurité';
      case SignOutReason.sessionExpired:
        return 'Session expirée';
      case SignOutReason.inactivity:
        return 'Déconnexion automatique due à l\'inactivité';
      case SignOutReason.authError:
        return 'Erreur d\'authentification';
      case SignOutReason.maintenance:
        return 'Maintenance du système';
    }
  }

  /// Indique si la déconnexion nécessite un message à l'utilisateur
  bool get requiresUserNotification {
    switch (this) {
      case SignOutReason.userInitiated:
        return false; // L'utilisateur sait qu'il se déconnecte
      case SignOutReason.security:
      case SignOutReason.sessionExpired:
      case SignOutReason.inactivity:
      case SignOutReason.authError:
      case SignOutReason.maintenance:
        return true; // L'utilisateur doit être informé
    }
  }

  /// Obtient le niveau de sévérité de la déconnexion
  SignOutSeverity get severity {
    switch (this) {
      case SignOutReason.userInitiated:
        return SignOutSeverity.normal;
      case SignOutReason.sessionExpired:
      case SignOutReason.inactivity:
        return SignOutSeverity.warning;
      case SignOutReason.security:
      case SignOutReason.authError:
        return SignOutSeverity.critical;
      case SignOutReason.maintenance:
        return SignOutSeverity.info;
    }
  }
}

/// Niveaux de sévérité pour les déconnexions
enum SignOutSeverity {
  normal,
  info,
  warning,
  critical,
}

/// Extension pour la sévérité des déconnexions
extension SignOutSeverityExtension on SignOutSeverity {
  /// Obtient la couleur associée à la sévérité
  String get colorHex {
    switch (this) {
      case SignOutSeverity.normal:
        return '#6B7280'; // Gris
      case SignOutSeverity.info:
        return '#3B82F6'; // Bleu
      case SignOutSeverity.warning:
        return '#F59E0B'; // Orange
      case SignOutSeverity.critical:
        return '#EF4444'; // Rouge
    }
  }

  /// Obtient l'icône associée à la sévérité
  String get icon {
    switch (this) {
      case SignOutSeverity.normal:
        return '👋';
      case SignOutSeverity.info:
        return 'ℹ️';
      case SignOutSeverity.warning:
        return '⚠️';
      case SignOutSeverity.critical:
        return '🚨';
    }
  }
}
