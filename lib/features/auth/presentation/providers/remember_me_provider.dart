/// 🔐 RememberMe Provider - Gestion d'état pour "Se souvenir de moi"
///
/// Provider Riverpod optimisé pour gérer l'état de la checkbox "Se souvenir de moi"
/// avec persistance locale et patterns Riverpod 2024.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// PROVIDER SIMPLE POUR REMEMBER ME
// ============================================================================

/// Provider pour l'état "Se souvenir de moi"
/// Utilise StateProvider pour un état simple bool
final rememberMeProvider = StateProvider<bool>((ref) {
  // Charger l'état initial depuis les préférences
  _loadRememberMeState(ref);
  return false; // Valeur par défaut
});

/// Provider pour charger l'état initial depuis SharedPreferences
final _rememberMeInitialStateProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('remember_me') ?? false;
});

// ============================================================================
// FONCTIONS UTILITAIRES
// ============================================================================

/// Charge l'état initial depuis SharedPreferences
void _loadRememberMeState(Ref ref) {
  ref.read(_rememberMeInitialStateProvider.future).then((initialValue) {
    ref.read(rememberMeProvider.notifier).state = initialValue;
  }).catchError((error) {
    // En cas d'erreur, garder la valeur par défaut (false)
    debugPrint('Erreur lors du chargement de remember_me: $error');
  });
}

/// Sauvegarde l'état dans SharedPreferences
Future<void> saveRememberMeState(bool value) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  } catch (error) {
    debugPrint('Erreur lors de la sauvegarde de remember_me: $error');
  }
}

// ============================================================================
// PROVIDER AVANCÉ AVEC PERSISTANCE
// ============================================================================

/// Notifier avancé pour Remember Me avec persistance automatique
class RememberMeNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Charger l'état initial
    _loadInitialState();
    return false;
  }

  /// Charge l'état initial depuis SharedPreferences
  Future<void> _loadInitialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getBool('remember_me') ?? false;
      state = savedValue;
    } catch (error) {
      debugPrint('Erreur lors du chargement de remember_me: $error');
      state = false;
    }
  }

  /// Met à jour l'état et le sauvegarde automatiquement
  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    await _saveState(newValue);
  }

  /// Met à jour l'état avec une valeur spécifique
  Future<void> setValue(bool value) async {
    state = value;
    await _saveState(value);
  }

  /// Sauvegarde l'état dans SharedPreferences
  Future<void> _saveState(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', value);
    } catch (error) {
      debugPrint('Erreur lors de la sauvegarde de remember_me: $error');
    }
  }

  /// Remet à zéro l'état
  Future<void> reset() async {
    state = false;
    await _saveState(false);
  }
}

/// Provider avancé avec persistance automatique
final rememberMeAdvancedProvider = NotifierProvider<RememberMeNotifier, bool>(
  RememberMeNotifier.new,
);

// ============================================================================
// EXTENSIONS UTILITAIRES
// ============================================================================

/// Extension pour faciliter l'utilisation du provider
extension RememberMeProviderExtension on WidgetRef {
  /// Lit l'état actuel de "Se souvenir de moi"
  bool get rememberMe => watch(rememberMeProvider);

  /// Met à jour l'état de "Se souvenir de moi"
  void setRememberMe(bool value) {
    read(rememberMeProvider.notifier).state = value;
    // Sauvegarder automatiquement
    saveRememberMeState(value);
  }

  /// Bascule l'état de "Se souvenir de moi"
  void toggleRememberMe() {
    final currentValue = read(rememberMeProvider);
    setRememberMe(!currentValue);
  }
}

/// Extension pour le provider avancé
extension RememberMeAdvancedProviderExtension on WidgetRef {
  /// Lit l'état actuel avec le provider avancé
  bool get rememberMeAdvanced => watch(rememberMeAdvancedProvider);

  /// Met à jour avec le provider avancé
  Future<void> setRememberMeAdvanced(bool value) async {
    await read(rememberMeAdvancedProvider.notifier).setValue(value);
  }

  /// Bascule avec le provider avancé
  Future<void> toggleRememberMeAdvanced() async {
    await read(rememberMeAdvancedProvider.notifier).toggle();
  }
}

// ============================================================================
// PROVIDER DE VALIDATION
// ============================================================================

/// Provider pour valider si l'utilisateur peut être connecté automatiquement
final canAutoLoginProvider = Provider<bool>((ref) {
  final rememberMe = ref.watch(rememberMeProvider);
  // Ici on pourrait ajouter d'autres conditions (token valide, etc.)
  return rememberMe;
});

/// Provider pour les données de connexion sauvegardées
final savedLoginDataProvider =
    FutureProvider<Map<String, String?>>((ref) async {
  final rememberMe = ref.watch(rememberMeProvider);

  if (!rememberMe) {
    return {'email': null, 'password': null};
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('saved_email'),
      'password': null, // Ne jamais sauvegarder le mot de passe
    };
  } catch (error) {
    debugPrint('Erreur lors du chargement des données de connexion: $error');
    return {'email': null, 'password': null};
  }
});

/// Sauvegarde l'email si "Se souvenir de moi" est activé
Future<void> saveLoginEmail(String email, bool rememberMe) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString('saved_email', email);
    } else {
      await prefs.remove('saved_email');
    }
  } catch (error) {
    debugPrint('Erreur lors de la sauvegarde de l\'email: $error');
  }
}
