/// 🔐 PIN State Provider - Gestion d'état PIN avec Riverpod
///
/// Provider dédié à la gestion de l'état d'authentification PIN
/// Conforme aux meilleures pratiques Context7 et Clean Architecture

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/unified_auth_service.dart';

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

/// Notifier pour la gestion de l'état PIN
class PinStateNotifier extends StateNotifier<PinState> {
  PinStateNotifier() : super(const PinState()) {
    _checkPasswordStatus();
  }

  /// Vérifie le statut du mot de passe au démarrage
  Future<void> _checkPasswordStatus() async {
    state = state.copyWith(isCheckingPassword: true);

    try {
      await UnifiedAuthService.initialize();
      final hasPassword = await UnifiedAuthService.hasPasswordSet();

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
      final result = await UnifiedAuthService.verifyPassword(pin);

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
      final result = await UnifiedAuthService.setPassword(pin);

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

/// Provider pour l'état PIN
final pinStateProvider =
    StateNotifierProvider<PinStateNotifier, PinState>((ref) {
  return PinStateNotifier();
});

/// Provider pour vérifier si un PIN est configuré
final hasPinConfiguredProvider = FutureProvider<bool>((ref) async {
  await UnifiedAuthService.initialize();
  return await UnifiedAuthService.hasPasswordSet();
});

/// Provider pour l'état d'authentification
final authStatusProvider = FutureProvider<AuthState>((ref) async {
  await UnifiedAuthService.initialize();
  return await UnifiedAuthService.checkAuthState();
});
