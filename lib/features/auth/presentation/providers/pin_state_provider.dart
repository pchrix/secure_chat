/// 🔐 PIN State Provider - Gestion d'état PIN avec Riverpod
///
/// Provider dédié à la gestion de l'état d'authentification PIN
/// Conforme aux meilleures pratiques Context7 et Clean Architecture

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/unified_auth_service.dart';
import '../../../../core/providers/service_providers.dart';

/// État de l'interface PIN
class PinState {
  final String currentPin;
  final bool isLoading;
  final bool isCheckingPassword;
  final String? errorMessage;
  final PinMode mode;
  final int currentStep;
  final String? confirmPin;

  const PinState({
    this.currentPin = '',
    this.isLoading = false,
    this.isCheckingPassword = false,
    this.errorMessage,
    this.mode = PinMode.authentication,
    this.currentStep = 0,
    this.confirmPin,
  });

  PinState copyWith({
    String? currentPin,
    bool? isLoading,
    bool? isCheckingPassword,
    String? errorMessage,
    PinMode? mode,
    int? currentStep,
    String? confirmPin,
  }) {
    return PinState(
      currentPin: currentPin ?? this.currentPin,
      isLoading: isLoading ?? this.isLoading,
      isCheckingPassword: isCheckingPassword ?? this.isCheckingPassword,
      errorMessage: errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
      currentStep: currentStep ?? this.currentStep,
      confirmPin: confirmPin ?? this.confirmPin,
    );
  }
}

/// Mode d'utilisation du PIN
enum PinMode {
  authentication, // Authentification normale
  setup, // Création d'un nouveau PIN
  change, // Changement de PIN existant
}

/// Notifier pour la gestion de l'état PIN avec injection de dépendances
class PinStateNotifier extends StateNotifier<PinState> {
  PinStateNotifier(this._authService) : super(const PinState()) {
    _checkPasswordStatus();
  }

  /// Service d'authentification injecté
  final UnifiedAuthService _authService;

  /// Vérifie le statut du mot de passe au démarrage
  Future<void> _checkPasswordStatus() async {
    state = state.copyWith(isCheckingPassword: true);

    try {
      await _authService.initialize();
      final hasPassword = await _authService.hasPasswordSet();

      if (!hasPassword) {
        // Aucun PIN configuré, passer en mode création
        state = state.copyWith(
          mode: PinMode.setup,
          isCheckingPassword: false,
        );
      } else {
        // PIN existant, mode authentification
        state = state.copyWith(
          mode: PinMode.authentication,
          isCheckingPassword: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCheckingPassword: false,
        errorMessage: 'Erreur lors de l\'initialisation',
      );
      if (kDebugMode) {
        print('❌ Erreur lors de la vérification du statut PIN: $e');
      }
    }
  }

  /// Met à jour le PIN actuel
  void updateCurrentPin(String pin) {
    state = state.copyWith(
      currentPin: pin,
      errorMessage: null, // Effacer l'erreur lors de la saisie
    );
  }

  /// Efface le PIN actuel
  void clearCurrentPin() {
    state = state.copyWith(currentPin: '');
  }

  /// Efface l'erreur
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Authentifie avec le PIN
  Future<bool> authenticateWithPin(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.verifyPassword(pin);

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de l\'authentification',
      );
      if (kDebugMode) {
        print('❌ Erreur d\'authentification PIN: $e');
      }
      return false;
    }
  }

  /// Configure un nouveau PIN (mode setup)
  Future<bool> setupPin(String pin, String confirmPin) async {
    if (pin != confirmPin) {
      state = state.copyWith(
        errorMessage: 'Les codes PIN ne correspondent pas',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authService.setPassword(pin);

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          mode: PinMode.authentication,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur lors de la création du PIN',
      );
      if (kDebugMode) {
        print('❌ Erreur de création PIN: $e');
      }
      return false;
    }
  }

  /// Passe à l'étape suivante (pour la création de PIN)
  void nextStep() {
    if (state.mode == PinMode.setup) {
      if (state.currentStep == 0) {
        // Passer à la confirmation
        state = state.copyWith(
          currentStep: 1,
          confirmPin: state.currentPin,
          currentPin: '',
        );
      }
    }
  }

  /// Revient à l'étape précédente
  void previousStep() {
    if (state.mode == PinMode.setup && state.currentStep > 0) {
      state = state.copyWith(
        currentStep: 0,
        currentPin: '',
        confirmPin: null,
        errorMessage: null,
      );
    }
  }

  /// Change le mode PIN
  void changeMode(PinMode mode) {
    state = state.copyWith(
      mode: mode,
      currentStep: 0,
      currentPin: '',
      confirmPin: null,
      errorMessage: null,
    );
  }

  /// Réinitialise l'état
  void reset() {
    state = const PinState();
    _checkPasswordStatus();
  }
}

/// Provider pour l'état PIN avec injection de dépendances
final pinStateProvider =
    StateNotifierProvider<PinStateNotifier, PinState>((ref) {
  final authService = ref.watch(unifiedAuthServiceProvider);
  return PinStateNotifier(authService);
});

/// Provider pour vérifier si un PIN est configuré - OPTIMISÉ
final hasPinConfiguredProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.watch(unifiedAuthServiceProvider);
  await authService.initialize();
  final hasPin = await authService.hasPasswordSet();

  // Garder en cache si un PIN est configuré pour éviter les re-vérifications
  if (hasPin) {
    ref.keepAlive();
  }

  return hasPin;
});

/// Provider pour l'état d'authentification - OPTIMISÉ
final authStatusProvider = FutureProvider.autoDispose<AuthState>((ref) async {
  final authService = ref.watch(unifiedAuthServiceProvider);
  await authService.initialize();
  final authState = await authService.checkAuthState();

  // Garder en cache si authentifié
  if (authState == AuthState.authenticated) {
    ref.keepAlive();
  }

  return authState;
});

/// Providers dérivés OPTIMISÉS pour des cas d'usage spécifiques
final isPinRequiredProvider = Provider.autoDispose<bool>((ref) {
  final hasPinAsync = ref.watch(hasPinConfiguredProvider);
  final authStatusAsync = ref.watch(authStatusProvider);

  return hasPinAsync.when(
    data: (hasPin) => authStatusAsync.when(
      data: (status) => hasPin && status != AuthState.authenticated,
      loading: () => false,
      error: (_, __) => false,
    ),
    loading: () => false,
    error: (_, __) => false,
  );
});

final canAccessAppProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(authStatusProvider.select((asyncState) {
    return asyncState.when(
      data: (status) => status == AuthState.authenticated,
      loading: () => false,
      error: (_, __) => false,
    );
  }));
});
