/// ⏰ Subscription Timer Provider - Gestion du timer d'abonnement
/// 
/// Provider Riverpod optimisé pour gérer le timer de subscription avec
/// patterns Riverpod 2024 et gestion automatique du lifecycle.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MODÈLE D'ÉTAT DU TIMER
// ============================================================================

/// État du timer de subscription
class SubscriptionTimerState {
  const SubscriptionTimerState({
    required this.remainingTime,
    required this.isActive,
    required this.isExpired,
  });

  final Duration remainingTime;
  final bool isActive;
  final bool isExpired;

  /// État initial par défaut
  factory SubscriptionTimerState.initial() {
    return const SubscriptionTimerState(
      remainingTime: Duration(days: 23, hours: 14, minutes: 32),
      isActive: true,
      isExpired: false,
    );
  }

  /// Copie avec modifications
  SubscriptionTimerState copyWith({
    Duration? remainingTime,
    bool? isActive,
    bool? isExpired,
  }) {
    return SubscriptionTimerState(
      remainingTime: remainingTime ?? this.remainingTime,
      isActive: isActive ?? this.isActive,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  /// Formatage du temps restant
  String get formattedTime {
    final days = remainingTime.inDays;
    final hours = remainingTime.inHours % 24;
    final minutes = remainingTime.inMinutes % 60;

    if (days > 0) {
      return '${days}j ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Pourcentage de temps écoulé (pour progress bar)
  double get progressPercentage {
    const totalDuration = Duration(days: 30); // Durée totale d'abonnement
    final elapsed = totalDuration - remainingTime;
    return elapsed.inMinutes / totalDuration.inMinutes;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionTimerState &&
          runtimeType == other.runtimeType &&
          remainingTime == other.remainingTime &&
          isActive == other.isActive &&
          isExpired == other.isExpired;

  @override
  int get hashCode =>
      remainingTime.hashCode ^ isActive.hashCode ^ isExpired.hashCode;

  @override
  String toString() {
    return 'SubscriptionTimerState{remainingTime: $remainingTime, isActive: $isActive, isExpired: $isExpired}';
  }
}

// ============================================================================
// NOTIFIER POUR LE TIMER
// ============================================================================

/// Notifier pour gérer le timer de subscription
class SubscriptionTimerNotifier extends Notifier<SubscriptionTimerState> {
  Timer? _timer;

  @override
  SubscriptionTimerState build() {
    // Nettoyer le timer lors de la destruction du provider
    ref.onDispose(() {
      _timer?.cancel();
      debugPrint('SubscriptionTimer: Timer cancelled on dispose');
    });

    // Démarrer le timer automatiquement
    _startTimer();

    return SubscriptionTimerState.initial();
  }

  /// Démarre le timer périodique
  void _startTimer() {
    _timer?.cancel(); // Annuler le timer existant s'il y en a un

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final currentState = state;

      if (currentState.remainingTime.inMinutes > 0) {
        // Décrémenter le temps restant
        final newRemainingTime = Duration(
          minutes: currentState.remainingTime.inMinutes - 1,
        );

        state = currentState.copyWith(
          remainingTime: newRemainingTime,
          isExpired: newRemainingTime.inMinutes <= 0,
        );

        debugPrint('SubscriptionTimer: ${newRemainingTime.inMinutes} minutes restantes');
      } else {
        // Timer expiré
        state = currentState.copyWith(
          isActive: false,
          isExpired: true,
        );
        timer.cancel();
        debugPrint('SubscriptionTimer: Abonnement expiré');
      }
    });

    debugPrint('SubscriptionTimer: Timer démarré');
  }

  /// Pause le timer
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isActive: false);
    debugPrint('SubscriptionTimer: Timer mis en pause');
  }

  /// Reprend le timer
  void resume() {
    if (!state.isExpired) {
      _startTimer();
      state = state.copyWith(isActive: true);
      debugPrint('SubscriptionTimer: Timer repris');
    }
  }

  /// Remet à zéro le timer avec une nouvelle durée
  void reset({Duration? newDuration}) {
    _timer?.cancel();
    
    final duration = newDuration ?? const Duration(days: 30);
    state = SubscriptionTimerState(
      remainingTime: duration,
      isActive: true,
      isExpired: false,
    );

    _startTimer();
    debugPrint('SubscriptionTimer: Timer remis à zéro avec $duration');
  }

  /// Ajoute du temps à l'abonnement
  void addTime(Duration additionalTime) {
    final newRemainingTime = state.remainingTime + additionalTime;
    state = state.copyWith(
      remainingTime: newRemainingTime,
      isExpired: false,
    );

    // Redémarrer le timer s'il était expiré
    if (!state.isActive) {
      _startTimer();
      state = state.copyWith(isActive: true);
    }

    debugPrint('SubscriptionTimer: ${additionalTime.inMinutes} minutes ajoutées');
  }

  /// Force l'expiration du timer (pour tests)
  void forceExpire() {
    _timer?.cancel();
    state = state.copyWith(
      remainingTime: Duration.zero,
      isActive: false,
      isExpired: true,
    );
    debugPrint('SubscriptionTimer: Expiration forcée');
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider principal pour le timer de subscription
final subscriptionTimerProvider = NotifierProvider<SubscriptionTimerNotifier, SubscriptionTimerState>(
  SubscriptionTimerNotifier.new,
);

/// Provider pour le temps restant formaté
final formattedTimeProvider = Provider<String>((ref) {
  final timerState = ref.watch(subscriptionTimerProvider);
  return timerState.formattedTime;
});

/// Provider pour le pourcentage de progression
final progressPercentageProvider = Provider<double>((ref) {
  final timerState = ref.watch(subscriptionTimerProvider);
  return timerState.progressPercentage;
});

/// Provider pour vérifier si l'abonnement est actif
final isSubscriptionActiveProvider = Provider<bool>((ref) {
  final timerState = ref.watch(subscriptionTimerProvider);
  return timerState.isActive && !timerState.isExpired;
});

/// Provider pour vérifier si l'abonnement est expiré
final isSubscriptionExpiredProvider = Provider<bool>((ref) {
  final timerState = ref.watch(subscriptionTimerProvider);
  return timerState.isExpired;
});

/// Provider pour les minutes restantes (pour alertes)
final remainingMinutesProvider = Provider<int>((ref) {
  final timerState = ref.watch(subscriptionTimerProvider);
  return timerState.remainingTime.inMinutes;
});

// ============================================================================
// PROVIDERS D'ALERTES
// ============================================================================

/// Provider pour alertes de temps faible
final lowTimeAlertProvider = Provider<bool>((ref) {
  final remainingMinutes = ref.watch(remainingMinutesProvider);
  return remainingMinutes <= 60; // Alerte si moins d'1 heure
});

/// Provider pour alertes critiques
final criticalTimeAlertProvider = Provider<bool>((ref) {
  final remainingMinutes = ref.watch(remainingMinutesProvider);
  return remainingMinutes <= 10; // Alerte critique si moins de 10 minutes
});

/// Provider pour le niveau d'alerte
enum AlertLevel { none, low, critical }

final alertLevelProvider = Provider<AlertLevel>((ref) {
  final remainingMinutes = ref.watch(remainingMinutesProvider);
  
  if (remainingMinutes <= 10) {
    return AlertLevel.critical;
  } else if (remainingMinutes <= 60) {
    return AlertLevel.low;
  } else {
    return AlertLevel.none;
  }
});

// ============================================================================
// EXTENSIONS UTILITAIRES
// ============================================================================

/// Extension pour faciliter l'utilisation du timer
extension SubscriptionTimerExtension on WidgetRef {
  /// Accès rapide à l'état du timer
  SubscriptionTimerState get subscriptionTimer => watch(subscriptionTimerProvider);

  /// Accès rapide au temps formaté
  String get formattedSubscriptionTime => watch(formattedTimeProvider);

  /// Accès rapide au notifier
  SubscriptionTimerNotifier get subscriptionTimerNotifier => 
      read(subscriptionTimerProvider.notifier);

  /// Vérifie si l'abonnement est actif
  bool get isSubscriptionActive => watch(isSubscriptionActiveProvider);

  /// Vérifie si l'abonnement est expiré
  bool get isSubscriptionExpired => watch(isSubscriptionExpiredProvider);

  /// Obtient le niveau d'alerte
  AlertLevel get alertLevel => watch(alertLevelProvider);
}
