/// 🔐 AuthStateProvider - Gestion d'état d'authentification avec Riverpod
///
/// Provider principal pour gérer l'état d'authentification de l'application.
/// Utilise Clean Architecture avec Riverpod pour une gestion d'état robuste.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_state.dart' as domain;
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/legacy_auth_datasource_adapter.dart';
import '../../../../core/network/network_info.dart';

/// Provider pour AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

/// Provider pour AuthRemoteDataSource - Utilise l'adaptateur pour migration progressive
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return LegacyAuthDataSourceAdapter();
});

/// Provider pour NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// Provider pour l'état d'authentification actuel
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<domain.AuthState>>(
        (ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<domain.User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider pour vérifier si l'utilisateur est authentifié
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.isAuthenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider pour vérifier si l'authentification est en cours
final isAuthenticatingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.isAuthenticating,
    loading: () => true,
    error: (_, __) => false,
  );
});

/// Notifier pour gérer l'état d'authentification
class AuthStateNotifier extends StateNotifier<AsyncValue<domain.AuthState>> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initializeAuthState();
  }

  /// Initialise l'état d'authentification au démarrage
  Future<void> _initializeAuthState() async {
    try {
      final result = await _repository.getAuthState();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (authState) => state = AsyncValue.data(authState),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Connecte un utilisateur avec email et mot de passe
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) async {
          // Récupère l'état d'authentification mis à jour
          await _refreshAuthState();
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Inscrit un nouvel utilisateur
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (user) async {
          // Récupère l'état d'authentification mis à jour
          await _refreshAuthState();
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      final result = await _repository.signOut();

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) async {
          // Récupère l'état d'authentification mis à jour
          await _refreshAuthState();
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Vérifie un code PIN
  Future<bool> verifyPin({required String pin}) async {
    try {
      final result = await _repository.verifyPin(pin: pin);

      return result.fold(
        (failure) => false,
        (isValid) => isValid,
      );
    } catch (e) {
      return false;
    }
  }

  /// Configure un nouveau code PIN
  Future<void> setupPin({required String pin}) async {
    try {
      final result = await _repository.setupPin(pin: pin);

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) async {
          // Récupère l'état d'authentification mis à jour
          await _refreshAuthState();
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit l'état d'authentification
  Future<void> _refreshAuthState() async {
    try {
      final result = await _repository.getAuthState();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (authState) => state = AsyncValue.data(authState),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Rafraîchit l'état d'authentification (méthode publique)
  Future<void> refresh() async {
    await _refreshAuthState();
  }
}
