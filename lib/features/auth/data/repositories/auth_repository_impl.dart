/// 🏛️ Auth Repository Implementation - Implémentation du repository d'authentification
///
/// Implémente l'interface AuthRepository du domaine en utilisant les sources de données.
/// Gère la logique de transformation entre les couches Data et Domain.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implémentation du repository d'authentification
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Vérifier la connectivité réseau
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      final userModel = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.invalidCredentials());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      // Vérifier la connectivité réseau
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      final userModel = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.userAlreadyExists());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // La déconnexion peut fonctionner hors ligne
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure.sessionExpired());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.userNotFound());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final isSignedIn = await _remoteDataSource.isSignedIn();
      return Right(isSignedIn);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isTokenValid() async {
    try {
      final isValid = await _remoteDataSource.isTokenValid();
      return Right(isValid);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, AuthState>> getAuthState() async {
    try {
      final authStateModel = await _remoteDataSource.getAuthState();
      return Right(authStateModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.sessionExpired());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin({required String pin}) async {
    try {
      // Vérifier la connectivité réseau pour la vérification PIN
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      final isValid = await _remoteDataSource.verifyPin(pin: pin);
      return Right(isValid);
    } on AuthException catch (e) {
      return Left(AuthFailure.invalidPin());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> setupPin({required String pin}) async {
    try {
      // Vérifier la connectivité réseau
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      await _remoteDataSource.setupPin(pin: pin);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure.invalidPin());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      // Vérifier la connectivité réseau
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      await _remoteDataSource.changePin(
        currentPin: currentPin,
        newPin: newPin,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure.invalidPin());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> invalidateAllSessions() async {
    try {
      // Vérifier la connectivité réseau
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure.noConnection());
      }

      await _remoteDataSource.invalidateAllSessions();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure.sessionExpired());
    } on NetworkException catch (e) {
      return Left(NetworkFailure.noConnection());
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateOnlineStatus(
      {required bool isOnline}) async {
    try {
      // Cette opération peut être tentée même hors ligne
      // (elle sera mise en cache et synchronisée plus tard)
      await _remoteDataSource.updateOnlineStatus(isOnline: isOnline);
      return const Right(null);
    } on AuthException catch (e) {
      // On ignore les erreurs de mise à jour du statut en ligne
      // car ce n'est pas critique
      return const Right(null);
    } catch (e) {
      // On ignore aussi les autres erreurs pour cette opération
      return const Right(null);
    }
  }

  @override
  Stream<Either<Failure, AuthState>> get authStateChanges {
    try {
      return _remoteDataSource.authStateChanges.map((authStateModel) {
        return Right<Failure, AuthState>(authStateModel.toEntity());
      }).handleError((error) {
        if (error is AuthException) {
          return Left<Failure, AuthState>(AuthFailure.sessionExpired());
        } else if (error is NetworkException) {
          return Left<Failure, AuthState>(NetworkFailure.noConnection());
        } else {
          return Left<Failure, AuthState>(SystemFailure.unexpected(
            error: error.toString(),
            stackTrace: StackTrace.current,
          ));
        }
      });
    } catch (e) {
      return Stream.value(Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      )));
    }
  }
}
