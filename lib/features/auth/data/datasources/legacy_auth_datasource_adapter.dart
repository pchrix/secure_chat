/// 🔄 LegacyAuthDataSourceAdapter - Adaptateur pour migrer les services auth existants
///
/// Implémente AuthRemoteDataSource en utilisant les services existants :
/// - UnifiedAuthService pour l'authentification PIN
/// - SupabaseAuthService pour l'authentification email/password
///
/// Permet une migration progressive vers la nouvelle architecture Clean.

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/exceptions.dart';
import '../../../../services/unified_auth_service.dart';
import '../../../../services/supabase_auth_service.dart';
import '../../domain/entities/auth_state.dart' as domain;
import '../models/user_model.dart';
import '../models/auth_state_model.dart';
import 'auth_remote_datasource.dart';

/// Adaptateur qui fait le pont entre les anciens services et la nouvelle architecture
/// Avec injection de dépendances
class LegacyAuthDataSourceAdapter implements AuthRemoteDataSource {
  /// Constructeur avec injection de dépendances
  LegacyAuthDataSourceAdapter({
    required UnifiedAuthService unifiedAuthService,
    required SupabaseAuthService supabaseAuthService,
  }) : _unifiedAuthService = unifiedAuthService,
       _supabaseAuthService = supabaseAuthService;

  /// Services injectés
  final UnifiedAuthService _unifiedAuthService;
  final SupabaseAuthService _supabaseAuthService;
  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseAuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException.invalidCredentials();
      }

      return _mapSupabaseUserToUserModel(response.user!);
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseException(e);
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'SIGNIN_ERROR');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      final response = await _supabaseAuthService.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );

      if (response.user == null) {
        throw AuthException(
            message: 'Registration failed', code: 'REGISTRATION_FAILED');
      }

      return _mapSupabaseUserToUserModel(response.user!);
    } on supabase.AuthException catch (e) {
      throw _mapSupabaseException(e);
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'SIGNUP_ERROR');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseAuthService.signOut();
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'SIGNOUT_ERROR');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseAuthService.currentUser;
      if (user == null) return null;

      return _mapSupabaseUserToUserModel(user);
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'GET_USER_ERROR');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return _supabaseAuthService.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isTokenValid() async {
    try {
      // Vérifier si l'utilisateur Supabase est connecté et si le token est valide
      final user = _supabaseAuthService.currentUser;
      if (user == null) return false;

      // Vérifier l'expiration du token
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) return false;

      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      return DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthStateModel> getAuthState() async {
    try {
      final isSupabaseAuthenticated = await isSignedIn();
      final user = await getCurrentUser();

      // Vérifier l'état du PIN si l'utilisateur est connecté
      bool isPinVerified = false;
      if (isSupabaseAuthenticated) {
        // Vérifier si le PIN est configuré et prêt
        final pinState = await _unifiedAuthService.checkAuthState();
        isPinVerified = pinState.isReady && pinState.type.name == 'pinSet';
      }

      // Déterminer le statut global
      domain.AuthStatus status;
      if (!isSupabaseAuthenticated) {
        status = domain.AuthStatus.unauthenticated;
      } else if (!isPinVerified) {
        status = domain.AuthStatus.pinRequired;
      } else {
        status = domain.AuthStatus.authenticated;
      }

      return AuthStateModel(
        status: status,
        user: user?.toEntity(),
        token: _getCurrentToken(),
        refreshToken: _getCurrentRefreshToken(),
        expiresAt: _getTokenExpirationDate(),
        lastLoginAt: user != null ? DateTime.now() : null,
        requiresPinVerification: isSupabaseAuthenticated && !isPinVerified,
      );
    } catch (e) {
      return AuthStateModel(
        status: domain.AuthStatus.error,
        user: null,
      );
    }
  }

  @override
  Future<bool> verifyPin({required String pin}) async {
    try {
      await _unifiedAuthService.initialize();
      final result = await _unifiedAuthService.verifyPassword(pin);
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setupPin({required String pin}) async {
    try {
      await _unifiedAuthService.initialize();
      final result = await _unifiedAuthService.setPassword(pin);
      if (!result.isSuccess) {
        throw AuthException.invalidPin();
      }
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'SETUP_PIN_ERROR');
    }
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      await _unifiedAuthService.initialize();
      final result =
          await _unifiedAuthService.changePassword(currentPin, newPin);
      if (!result.isSuccess) {
        throw AuthException.invalidPin();
      }
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'CHANGE_PIN_ERROR');
    }
  }

  @override
  Future<void> invalidateAllSessions() async {
    try {
      await _supabaseAuthService.signOut();
      // Note: Supabase gère automatiquement l'invalidation des sessions
    } catch (e) {
      throw AuthException(
          message: e.toString(), code: 'INVALIDATE_SESSIONS_ERROR');
    }
  }

  @override
  Future<void> updateOnlineStatus({required bool isOnline}) async {
    try {
      // Cette fonctionnalité est déjà gérée par SupabaseAuthService
      // lors de la connexion/déconnexion
    } catch (e) {
      // Ignorer les erreurs de mise à jour du statut en ligne
      // car ce n'est pas critique
    }
  }

  @override
  Stream<AuthStateModel> get authStateChanges {
    return _supabaseAuthService.authStateChanges
        .asyncMap((supabaseAuthState) async {
      return await getAuthState();
    });
  }

  // ========== MÉTHODES PRIVÉES DE MAPPING ==========

  /// Mappe un utilisateur Supabase vers UserModel
  UserModel _mapSupabaseUserToUserModel(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String? ??
          user.email?.split('@').first ??
          'user',
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      isEmailConfirmed: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt:
          user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      lastSignInAt:
          user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
      metadata: user.userMetadata ?? {},
    );
  }

  /// Mappe une exception Supabase vers AuthException
  AuthException _mapSupabaseException(supabase.AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return AuthException.invalidCredentials();
        }
        return AuthException(
            message: 'Invalid input: ${e.message}', code: 'INVALID_INPUT');
      case '422':
        if (e.message.contains('User already registered')) {
          return AuthException.userAlreadyExists();
        }
        return AuthException(
            message: 'Registration failed: ${e.message}',
            code: 'REGISTRATION_FAILED');
      case '429':
        return AuthException.tooManyAttempts();
      default:
        return AuthException(message: e.message, code: 'UNKNOWN_ERROR');
    }
  }

  /// Obtient le token actuel
  String? _getCurrentToken() {
    try {
      return supabase.Supabase.instance.client.auth.currentSession?.accessToken;
    } catch (e) {
      return null;
    }
  }

  /// Obtient le refresh token actuel
  String? _getCurrentRefreshToken() {
    try {
      return supabase
          .Supabase.instance.client.auth.currentSession?.refreshToken;
    } catch (e) {
      return null;
    }
  }

  /// Obtient la date d'expiration du token
  DateTime? _getTokenExpirationDate() {
    try {
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session?.expiresAt == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(session!.expiresAt! * 1000);
    } catch (e) {
      return null;
    }
  }
}
