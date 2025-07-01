import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/room.dart';
import '../../models/message.dart';
import '../../providers/room_provider_riverpod.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/providers/pin_state_provider.dart';

/// ============================================================================
/// PROVIDERS OPTIMISÉS POUR PERFORMANCE MAXIMALE
/// ============================================================================
/// 
/// Ce fichier contient des providers hautement optimisés utilisant :
/// - AutoDispose par défaut pour éviter les fuites mémoire
/// - Select() pour des rebuilds granulaires
/// - Family pour la paramètrisation
/// - KeepAlive conditionnel pour les données critiques
/// - Lazy loading pour les opérations coûteuses

// ============================================================================
// PROVIDERS DE PERFORMANCE POUR LES SALONS
// ============================================================================

/// Provider pour surveiller uniquement les changements de nombre de salons actifs
/// Évite les rebuilds quand le contenu des salons change
final activeRoomsCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.activeRooms.length));
});

/// Provider pour surveiller uniquement l'état de chargement des salons
/// Optimisé pour les indicateurs de loading
final roomsLoadingStateProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(roomProvider.select((state) => state.isLoading));
});

/// Provider pour surveiller uniquement les erreurs de salons
/// Optimisé pour l'affichage d'erreurs
final roomsErrorStateProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(roomProvider.select((state) => state.error));
});

/// Provider pour surveiller uniquement l'ID du salon actuel
/// Évite les rebuilds quand les détails du salon changent
final currentRoomIdProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(roomProvider.select((state) => state.currentRoom?.id));
});

/// Provider pour surveiller uniquement le nom du salon actuel
/// Optimisé pour l'affichage du titre
final currentRoomNameProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(roomProvider.select((state) => state.currentRoom?.name));
});

/// Provider pour surveiller uniquement le statut du salon actuel
/// Optimisé pour les indicateurs de statut
final currentRoomStatusProvider = Provider.autoDispose<RoomStatus?>((ref) {
  return ref.watch(roomProvider.select((state) => state.currentRoom?.status));
});

// ============================================================================
// PROVIDERS FAMILY POUR PARAMÈTRISATION OPTIMISÉE
// ============================================================================

/// Provider family pour obtenir un salon spécifique par ID
/// AutoDispose pour éviter l'accumulation en mémoire
final roomByIdProvider = Provider.autoDispose.family<Room?, String>((ref, roomId) {
  final rooms = ref.watch(roomProvider.select((state) => state.rooms));
  try {
    return rooms.firstWhere((room) => room.id == roomId);
  } catch (e) {
    return null;
  }
});

/// Provider family pour surveiller uniquement le nom d'un salon spécifique
final roomNameByIdProvider = Provider.autoDispose.family<String?, String>((ref, roomId) {
  return ref.watch(roomByIdProvider(roomId).select((room) => room?.name));
});

/// Provider family pour surveiller uniquement le statut d'un salon spécifique
final roomStatusByIdProvider = Provider.autoDispose.family<RoomStatus?, String>((ref, roomId) {
  return ref.watch(roomByIdProvider(roomId).select((room) => room?.status));
});

/// Provider family pour surveiller si un salon spécifique est expiré
final isRoomExpiredProvider = Provider.autoDispose.family<bool, String>((ref, roomId) {
  return ref.watch(roomByIdProvider(roomId).select((room) => room?.isExpired ?? true));
});

/// Provider family pour obtenir le nombre de messages d'un salon spécifique
final roomMessageCountProvider = Provider.autoDispose.family<int, String>((ref, roomId) {
  return ref.watch(roomByIdProvider(roomId).select((room) => room?.messageCount ?? 0));
});

// ============================================================================
// PROVIDERS DE PERFORMANCE POUR L'AUTHENTIFICATION
// ============================================================================

/// Provider pour surveiller uniquement l'état d'authentification (booléen)
/// Évite les rebuilds sur les changements d'utilisateur
final isUserAuthenticatedProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(authStateProvider.select((asyncState) {
    return asyncState.when(
      data: (state) => state.isAuthenticated,
      loading: () => false,
      error: (_, __) => false,
    );
  }));
});

/// Provider pour surveiller uniquement l'ID de l'utilisateur actuel
/// Optimisé pour les clés de cache
final currentUserIdProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(currentUserProvider.select((user) => user?.id));
});

/// Provider pour surveiller uniquement le nom de l'utilisateur actuel
/// Optimisé pour l'affichage du nom
final currentUserNameProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(currentUserProvider.select((user) => user?.name));
});

/// Provider pour surveiller uniquement l'email de l'utilisateur actuel
/// Optimisé pour l'affichage de l'email
final currentUserEmailProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(currentUserProvider.select((user) => user?.email));
});

// ============================================================================
// PROVIDERS DE PERFORMANCE POUR LES MESSAGES
// ============================================================================

/// Provider pour surveiller uniquement le nombre de messages
/// Évite les rebuilds quand le contenu des messages change
final messagesCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.messages.length));
});

/// Provider pour surveiller uniquement le dernier message
/// Optimisé pour les aperçus de conversation
final lastMessageProvider = Provider.autoDispose<Message?>((ref) {
  final messages = ref.watch(roomProvider.select((state) => state.messages));
  return messages.isNotEmpty ? messages.last : null;
});

/// Provider pour surveiller uniquement le texte du dernier message
/// Optimisé pour l'affichage d'aperçu
final lastMessageTextProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(lastMessageProvider.select((message) => message?.content));
});

/// Provider pour surveiller uniquement l'horodatage du dernier message
/// Optimisé pour l'affichage de la date
final lastMessageTimestampProvider = Provider.autoDispose<DateTime?>((ref) {
  return ref.watch(lastMessageProvider.select((message) => message?.timestamp));
});

// ============================================================================
// PROVIDERS COMBINÉS POUR CAS D'USAGE COMPLEXES
// ============================================================================

/// Provider pour surveiller si l'utilisateur peut envoyer des messages
/// Combine plusieurs états de manière optimisée
final canSendMessageProvider = Provider.autoDispose<bool>((ref) {
  final isAuthenticated = ref.watch(isUserAuthenticatedProvider);
  final currentRoomStatus = ref.watch(currentRoomStatusProvider);
  final isLoading = ref.watch(roomsLoadingStateProvider);
  
  return isAuthenticated && 
         currentRoomStatus == RoomStatus.active && 
         !isLoading;
});

/// Provider pour surveiller si l'utilisateur peut créer un salon
/// Optimisé pour l'état des boutons d'action
final canCreateRoomProvider = Provider.autoDispose<bool>((ref) {
  final isAuthenticated = ref.watch(isUserAuthenticatedProvider);
  final isLoading = ref.watch(roomsLoadingStateProvider);
  final activeRoomsCount = ref.watch(activeRoomsCountProvider);
  
  return isAuthenticated && !isLoading && activeRoomsCount < 10; // Limite arbitraire
});

/// Provider pour surveiller si l'interface doit afficher un état vide
/// Optimisé pour les écrans d'état vide
final shouldShowEmptyStateProvider = Provider.autoDispose<bool>((ref) {
  final isLoading = ref.watch(roomsLoadingStateProvider);
  final activeRoomsCount = ref.watch(activeRoomsCountProvider);
  final waitingRoomsCount = ref.watch(totalWaitingRoomsProvider);
  
  return !isLoading && activeRoomsCount == 0 && waitingRoomsCount == 0;
});

// ============================================================================
// PROVIDERS DE CACHE AVEC EXPIRATION AUTOMATIQUE
// ============================================================================

/// Provider de cache pour les données utilisateur avec expiration
/// Utilise keepAlive avec invalidation programmée
final userCacheProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, userId) async {
  if (userId.isEmpty) return null;

  // Simuler la récupération des données
  await Future.delayed(const Duration(milliseconds: 200));

  final userData = {
    'id': userId,
    'name': 'User $userId',
    'cached_at': DateTime.now().toIso8601String(),
    'expires_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
  };

  // Conserver en cache pendant 5 minutes
  ref.keepAlive();

  // Programmer l'invalidation automatique après 5 minutes
  Future.delayed(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });

  return userData;
});

/// Provider de cache pour les paramètres d'application
/// Garde en cache indéfiniment car ce sont des données critiques
final appSettingsCacheProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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
