/// 🚀 Providers optimisés avec .select et patterns avancés Riverpod
///
/// Ce fichier contient des providers optimisés pour éviter les rebuilds
/// inutiles et améliorer les performances de l'application.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des providers de base
import 'service_providers.dart';
import '../../providers/room_provider_riverpod.dart';

// ============================================================================
// PROVIDERS OPTIMISÉS AVEC SELECT
// ============================================================================

/// Provider pour écouter seulement l'état de chargement des salons
/// Évite les rebuilds quand seule la liste change
final roomsLoadingStateProvider = Provider<bool>((ref) {
  return ref.watch(roomProvider.select((state) => state.isLoading));
});

/// Provider pour écouter seulement le nombre de salons
/// Évite les rebuilds quand le contenu des salons change
final roomsCountProvider = Provider<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.rooms.length));
});

/// Provider pour écouter seulement l'ID du salon actuel
/// Évite les rebuilds quand les détails du salon changent
final currentRoomIdProvider = Provider<String?>((ref) {
  return ref.watch(roomProvider.select((state) => state.currentRoom?.id));
});

/// Provider pour écouter seulement le statut du salon actuel
/// Évite les rebuilds quand d'autres propriétés changent
final currentRoomStatusProvider = Provider<String?>((ref) {
  return ref.watch(
      roomProvider.select((state) => state.currentRoom?.status.toString()));
});

/// Provider pour écouter seulement si l'utilisateur est authentifié
/// Évite les rebuilds quand les détails utilisateur changent
final isUserAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(isAuthenticatedProvider);
});

/// Provider pour écouter seulement l'ID de l'utilisateur actuel
/// Évite les rebuilds quand d'autres données utilisateur changent
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider.select((user) => user?.id));
});

// ============================================================================
// PROVIDERS AVEC CANCELLATION ET CLEANUP
// ============================================================================

/// Provider pour recherche de salons avec annulation automatique
/// Optimisé avec autoDispose et cancellation
final roomSearchProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];

  // Simuler une recherche avec délai
  await Future.delayed(const Duration(milliseconds: 500));

  // Utiliser onDispose pour nettoyer si nécessaire
  ref.onDispose(() {
    // Nettoyage des ressources si nécessaire
  });

  // Retourner des résultats simulés
  return [
    {
      'id': 'room_${query}_1',
      'name': 'Salon contenant "$query"',
      'query': query,
      'timestamp': DateTime.now().toIso8601String(),
    }
  ];
});

/// Provider pour surveillance de la connectivité avec nettoyage
/// Optimisé avec autoDispose et onDispose
final connectivityProvider = StreamProvider.autoDispose<bool>((ref) {
  // Simuler un stream de connectivité
  late Stream<bool> connectivityStream;

  connectivityStream = Stream.periodic(
    const Duration(seconds: 5),
    (count) => count % 2 == 0, // Alterne entre true/false
  );

  // Nettoyer les ressources lors de la destruction
  ref.onDispose(() {
    // Ici on pourrait fermer des connexions, annuler des timers, etc.
  });

  return connectivityStream;
});

// ============================================================================
// PROVIDERS DE CACHE INTELLIGENT
// ============================================================================

/// Provider pour cache des données utilisateur avec expiration
/// Optimisé avec keepAlive conditionnel et invalidation automatique
final userCacheProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, userId) async {
  if (userId.isEmpty) return null;

  // Simuler la récupération des données
  await Future.delayed(const Duration(milliseconds: 200));

  final userData = {
    'id': userId,
    'name': 'User $userId',
    'cached_at': DateTime.now().toIso8601String(),
    'expires_at':
        DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
  };

  // Conserver en cache pendant 5 minutes
  ref.keepAlive();

  // Programmer l'invalidation automatique après 5 minutes
  Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });

  return userData;
});

/// Provider pour cache des paramètres avec persistance
/// Optimisé avec keepAlive permanent pour les données critiques
final appSettingsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // Simuler le chargement des paramètres
  await Future.delayed(const Duration(milliseconds: 100));

  final settings = {
    'theme': 'dark',
    'language': 'fr',
    'notifications': true,
    'loaded_at': DateTime.now().toIso8601String(),
  };

  // Conserver indéfiniment car ce sont des données critiques
  ref.keepAlive();

  return settings;
});

// ============================================================================
// PROVIDERS DE PERFORMANCE ET MÉTRIQUES
// ============================================================================

/// Provider pour mesurer les performances des opérations
/// Optimisé avec autoDispose et métriques
final performanceMetricsProvider = StateNotifierProvider.autoDispose<
    PerformanceMetricsNotifier, PerformanceMetrics>((ref) {
  return PerformanceMetricsNotifier();
});

/// Notifier pour les métriques de performance
class PerformanceMetricsNotifier extends StateNotifier<PerformanceMetrics> {
  PerformanceMetricsNotifier() : super(PerformanceMetrics.initial());

  void recordOperation(String operation, Duration duration) {
    state = state.copyWith(
      operations: {
        ...state.operations,
        operation: duration,
      },
      lastUpdate: DateTime.now(),
    );
  }

  void recordError(String operation, String error) {
    state = state.copyWith(
      errors: {
        ...state.errors,
        operation: error,
      },
      lastUpdate: DateTime.now(),
    );
  }

  void reset() {
    state = PerformanceMetrics.initial();
  }
}

/// Modèle pour les métriques de performance
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.operations,
    required this.errors,
    required this.lastUpdate,
  });

  final Map<String, Duration> operations;
  final Map<String, String> errors;
  final DateTime lastUpdate;

  factory PerformanceMetrics.initial() {
    return PerformanceMetrics(
      operations: {},
      errors: {},
      lastUpdate: DateTime.now(),
    );
  }

  PerformanceMetrics copyWith({
    Map<String, Duration>? operations,
    Map<String, String>? errors,
    DateTime? lastUpdate,
  }) {
    return PerformanceMetrics(
      operations: operations ?? this.operations,
      errors: errors ?? this.errors,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

// ============================================================================
// PROVIDERS DE BATCH ET OPTIMISATION RÉSEAU
// ============================================================================

/// Provider pour batch des requêtes de données utilisateur
/// Optimisé pour réduire les appels réseau
final batchUserDataProvider = FutureProvider.autoDispose
    .family<Map<String, Map<String, dynamic>>, List<String>>(
        (ref, userIds) async {
  if (userIds.isEmpty) return {};

  // Simuler un batch de requêtes
  await Future.delayed(const Duration(milliseconds: 300));

  final batchResult = <String, Map<String, dynamic>>{};

  for (final userId in userIds) {
    batchResult[userId] = {
      'id': userId,
      'name': 'User $userId',
      'batch_loaded': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  return batchResult;
});

/// Provider pour debounce des recherches
/// Optimisé pour éviter les requêtes trop fréquentes
final debouncedSearchProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];

  // Debounce de 300ms
  await Future.delayed(const Duration(milliseconds: 300));

  // Utiliser onDispose pour nettoyer si nécessaire
  ref.onDispose(() {
    // Nettoyage des ressources si nécessaire
  });

  // Retourner des résultats simulés
  return [
    'Résultat 1 pour "$query"',
    'Résultat 2 pour "$query"',
    'Résultat 3 pour "$query"',
  ];
});
