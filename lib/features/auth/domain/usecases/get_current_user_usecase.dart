/// 👤 Use Case GetCurrentUser - Obtenir l'utilisateur actuel
///
/// Gère la logique métier pour récupérer l'utilisateur actuellement connecté.
/// Suit les meilleures pratiques Clean Architecture pour l'accès au contexte utilisateur.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../entities/auth_state.dart';
import '../repositories/auth_repository.dart';

/// Use case pour obtenir l'utilisateur actuellement connecté
class GetCurrentUserUseCase implements NoParamsUseCase<User?> {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call() async {
    try {
      // Récupération de l'utilisateur actuel via le repository
      return await repository.getCurrentUser();
    } catch (e) {
      // En cas d'erreur inattendue, on retourne un échec système
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Use case pour obtenir l'utilisateur actuel avec validation de session
class GetCurrentUserWithValidationUseCase
    implements UseCase<User, GetCurrentUserOptions> {
  final AuthRepository repository;

  const GetCurrentUserWithValidationUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(GetCurrentUserOptions params) async {
    try {
      // 1. Vérifier si l'utilisateur est connecté
      final isSignedInResult = await repository.isSignedIn();
      if (isSignedInResult.isLeft()) {
        return Left(isSignedInResult.fold(
            (failure) => failure, (_) => throw StateError('Unexpected')));
      }

      final isSignedIn = isSignedInResult.fold((_) => false, (value) => value);
      if (!isSignedIn) {
        return Left(AuthFailure.sessionExpired());
      }

      // 2. Vérifier la validité du token si demandé
      if (params.validateToken) {
        final isTokenValidResult = await repository.isTokenValid();
        if (isTokenValidResult.isLeft()) {
          return Left(isTokenValidResult.fold(
              (failure) => failure, (_) => throw StateError('Unexpected')));
        }

        final isTokenValid =
            isTokenValidResult.fold((_) => false, (value) => value);
        if (!isTokenValid) {
          return Left(AuthFailure.sessionExpired());
        }
      }

      // 3. Récupérer l'utilisateur actuel
      final userResult = await repository.getCurrentUser();
      if (userResult.isLeft()) {
        return Left(userResult.fold(
            (failure) => failure, (_) => throw StateError('Unexpected')));
      }

      final user = userResult.fold((_) => null, (value) => value);
      if (user == null) {
        return Left(AuthFailure.userNotFound());
      }

      // 4. Mettre à jour le statut en ligne si demandé
      if (params.updateOnlineStatus) {
        await repository.updateOnlineStatus(isOnline: true);
        // On ignore les erreurs de mise à jour du statut en ligne
        // car ce n'est pas critique pour récupérer l'utilisateur
      }

      return Right(user);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Use case pour vérifier si un utilisateur est connecté (simple)
class IsUserSignedInUseCase implements NoParamsUseCase<bool> {
  final AuthRepository repository;

  const IsUserSignedInUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    try {
      return await repository.isSignedIn();
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Use case pour obtenir l'état d'authentification complet
class GetAuthStateUseCase implements NoParamsUseCase<AuthState> {
  final AuthRepository repository;

  const GetAuthStateUseCase(this.repository);

  @override
  Future<Either<Failure, AuthState>> call() async {
    try {
      return await repository.getAuthState();
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }
}

/// Options pour la récupération de l'utilisateur actuel
class GetCurrentUserOptions {
  /// Valider la validité du token
  final bool validateToken;

  /// Mettre à jour le statut en ligne
  final bool updateOnlineStatus;

  /// Forcer le rafraîchissement depuis la source distante
  final bool forceRefresh;

  const GetCurrentUserOptions({
    this.validateToken = true,
    this.updateOnlineStatus = false,
    this.forceRefresh = false,
  });

  /// Options par défaut pour une récupération simple
  factory GetCurrentUserOptions.simple() {
    return const GetCurrentUserOptions(
      validateToken: false,
      updateOnlineStatus: false,
      forceRefresh: false,
    );
  }

  /// Options pour une récupération avec validation complète
  factory GetCurrentUserOptions.withValidation() {
    return const GetCurrentUserOptions(
      validateToken: true,
      updateOnlineStatus: true,
      forceRefresh: false,
    );
  }

  /// Options pour forcer un rafraîchissement
  factory GetCurrentUserOptions.forceRefresh() {
    return const GetCurrentUserOptions(
      validateToken: true,
      updateOnlineStatus: true,
      forceRefresh: true,
    );
  }

  @override
  String toString() {
    return 'GetCurrentUserOptions('
        'validateToken: $validateToken, '
        'updateOnlineStatus: $updateOnlineStatus, '
        'forceRefresh: $forceRefresh'
        ')';
  }
}

/// Interface pour le contexte utilisateur (inspiré des meilleures pratiques)
/// Cette interface peut être utilisée dans d'autres couches pour accéder
/// aux informations de l'utilisateur actuel de manière découplée
abstract class IUserContext {
  /// Indique si l'utilisateur est authentifié
  bool get isAuthenticated;

  /// ID de l'utilisateur actuel (null si non connecté)
  String? get userId;

  /// Utilisateur actuel complet (null si non connecté)
  User? get currentUser;

  /// Email de l'utilisateur actuel (null si non connecté)
  String? get userEmail;

  /// Nom d'affichage de l'utilisateur actuel
  String? get displayName;

  /// Vérifie si l'utilisateur a un rôle spécifique
  bool hasRole(String role);

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission);
}

/// Implémentation du contexte utilisateur basée sur l'état d'authentification
class UserContext implements IUserContext {
  final AuthState _authState;

  const UserContext(this._authState);

  @override
  bool get isAuthenticated => _authState.isAuthenticated;

  @override
  String? get userId => _authState.user?.id;

  @override
  User? get currentUser => _authState.user;

  @override
  String? get userEmail => _authState.user?.email;

  @override
  String? get displayName => _authState.user?.effectiveDisplayName;

  @override
  bool hasRole(String role) {
    // Implémentation basique - à étendre selon les besoins
    // Pour l'instant, on considère que tous les utilisateurs connectés
    // ont le rôle 'user'
    if (!isAuthenticated) return false;
    return role == 'user';
  }

  @override
  bool hasPermission(String permission) {
    // Implémentation basique - à étendre selon les besoins
    // Pour l'instant, on considère que tous les utilisateurs connectés
    // ont les permissions de base
    if (!isAuthenticated) return false;

    const basicPermissions = [
      'read_messages',
      'send_messages',
      'join_rooms',
      'create_rooms',
    ];

    return basicPermissions.contains(permission);
  }

  @override
  String toString() {
    return 'UserContext('
        'isAuthenticated: $isAuthenticated, '
        'userId: $userId, '
        'userEmail: $userEmail'
        ')';
  }
}
