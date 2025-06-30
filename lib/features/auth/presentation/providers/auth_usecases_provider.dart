/// 🎯 AuthUseCasesProvider - Providers pour les cas d'usage d'authentification
/// 
/// Fournit les cas d'usage d'authentification via Riverpod pour une architecture Clean.
/// Chaque cas d'usage est exposé comme un provider indépendant.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/verify_pin_usecase.dart';
import '../../domain/usecases/setup_pin_usecase.dart';
import '../../domain/usecases/change_pin_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/get_auth_state_usecase.dart';
import 'auth_state_provider.dart';

/// Provider pour LoginUseCase
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provider pour LogoutUseCase
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Provider pour RegisterUseCase
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

/// Provider pour GetCurrentUserUseCase
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

/// Provider pour VerifyPinUseCase
final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyPinUseCase(repository);
});

/// Provider pour SetupPinUseCase
final setupPinUseCaseProvider = Provider<SetupPinUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SetupPinUseCase(repository);
});

/// Provider pour ChangePinUseCase
final changePinUseCaseProvider = Provider<ChangePinUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ChangePinUseCase(repository);
});

/// Provider pour RefreshTokenUseCase
final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

/// Provider pour GetAuthStateUseCase
final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetAuthStateUseCase(repository);
});

/// Provider pour exécuter une connexion
final executeLoginProvider = Provider.family<Future<void>, LoginParams>((ref, params) async {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final authNotifier = ref.read(authStateProvider.notifier);
  
  await authNotifier.signInWithEmailAndPassword(
    email: params.email,
    password: params.password,
  );
});

/// Provider pour exécuter une déconnexion
final executeLogoutProvider = Provider<Future<void>>((ref) async {
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final authNotifier = ref.read(authStateProvider.notifier);
  
  await authNotifier.signOut();
});

/// Provider pour exécuter une inscription
final executeRegisterProvider = Provider.family<Future<void>, RegisterParams>((ref, params) async {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final authNotifier = ref.read(authStateProvider.notifier);
  
  await authNotifier.signUpWithEmailAndPassword(
    email: params.email,
    password: params.password,
    username: params.username,
    displayName: params.displayName,
  );
});

/// Provider pour exécuter la vérification PIN
final executeVerifyPinProvider = Provider.family<Future<bool>, String>((ref, pin) async {
  final verifyPinUseCase = ref.watch(verifyPinUseCaseProvider);
  final authNotifier = ref.read(authStateProvider.notifier);
  
  return await authNotifier.verifyPin(pin: pin);
});

/// Provider pour exécuter la configuration PIN
final executeSetupPinProvider = Provider.family<Future<void>, String>((ref, pin) async {
  final setupPinUseCase = ref.watch(setupPinUseCaseProvider);
  final authNotifier = ref.read(authStateProvider.notifier);
  
  await authNotifier.setupPin(pin: pin);
});

/// Paramètres pour la connexion
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginParams &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode => Object.hash(email, password);
}

/// Paramètres pour l'inscription
class RegisterParams {
  final String email;
  final String password;
  final String username;
  final String? displayName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    this.displayName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterParams &&
        other.email == email &&
        other.password == password &&
        other.username == username &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(email, password, username, displayName);
}

/// Paramètres pour le changement de PIN
class ChangePinParams {
  final String currentPin;
  final String newPin;

  const ChangePinParams({
    required this.currentPin,
    required this.newPin,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangePinParams &&
        other.currentPin == currentPin &&
        other.newPin == newPin;
  }

  @override
  int get hashCode => Object.hash(currentPin, newPin);
}

/// Extensions utiles pour les providers de cas d'usage
extension AuthUseCasesProviderExtensions on WidgetRef {
  /// Raccourci pour exécuter une connexion
  Future<void> signIn(String email, String password) async {
    await read(executeLoginProvider(LoginParams(email: email, password: password)));
  }

  /// Raccourci pour exécuter une déconnexion
  Future<void> signOut() async {
    await read(executeLogoutProvider);
  }

  /// Raccourci pour exécuter une inscription
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    await read(executeRegisterProvider(RegisterParams(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    )));
  }

  /// Raccourci pour vérifier un PIN
  Future<bool> verifyPin(String pin) async {
    return await read(executeVerifyPinProvider(pin));
  }

  /// Raccourci pour configurer un PIN
  Future<void> setupPin(String pin) async {
    await read(executeSetupPinProvider(pin));
  }
}
