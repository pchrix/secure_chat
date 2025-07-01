/// 🚀 Provider optimisé pour la gestion des salons avec Riverpod
/// 
/// Version optimisée du RoomProvider avec les meilleures pratiques :
/// - AutoDispose pour la gestion mémoire
/// - Family pour les données paramétrées
/// - Select pour éviter les rebuilds
/// - KeepAlive pour les données importantes
/// - Cancellation pour les opérations async

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des modèles et services
import '../../models/room.dart';
import '../../models/message.dart';
import '../../services/room_service.dart';
import '../../services/local_storage_service.dart';
import 'service_providers.dart';

// ============================================================================
// ÉTAT OPTIMISÉ AVEC FREEZED-LIKE PATTERN
// ============================================================================

/// État optimisé des salons avec immutabilité
class OptimizedRoomState {
  const OptimizedRoomState({
    this.rooms = const [],
    this.currentRoom,
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.lastUpdate,
  });

  final List<Room> rooms;
  final Room? currentRoom;
  final bool isLoading;
  final String? error;
  final List<Message> messages;
  final DateTime? lastUpdate;

  // Getters calculés optimisés
  List<Room> get activeRooms => rooms
      .where((r) => r.status == RoomStatus.active && !r.isExpired)
      .toList();

  List<Room> get waitingRooms => rooms
      .where((r) => r.status == RoomStatus.waiting && !r.isExpired)
      .toList();

  List<Room> get expiredRooms => rooms.where((r) => r.isExpired).toList();

  bool get hasActiveRoom =>
      currentRoom != null &&
      currentRoom!.status == RoomStatus.active &&
      !currentRoom!.isExpired;

  bool get hasWaitingRoom =>
      currentRoom != null &&
      currentRoom!.status == RoomStatus.waiting &&
      !currentRoom!.isExpired;

  int get totalRooms => rooms.length;
  int get activeRoomsCount => activeRooms.length;
  int get waitingRoomsCount => waitingRooms.length;

  // CopyWith optimisé
  OptimizedRoomState copyWith({
    List<Room>? rooms,
    Room? currentRoom,
    bool? isLoading,
    String? error,
    List<Message>? messages,
    DateTime? lastUpdate,
  }) {
    return OptimizedRoomState(
      rooms: rooms ?? this.rooms,
      currentRoom: currentRoom ?? this.currentRoom,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messages: messages ?? this.messages,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  // Méthodes utilitaires
  bool hasRoom(String roomId) => rooms.any((r) => r.id == roomId);
  Room? getRoomById(String roomId) => rooms.where((r) => r.id == roomId).firstOrNull;
}

// ============================================================================
// NOTIFIER OPTIMISÉ
// ============================================================================

/// Notifier optimisé pour la gestion des salons
class OptimizedRoomNotifier extends StateNotifier<OptimizedRoomState> {
  OptimizedRoomNotifier(this._ref) : super(const OptimizedRoomState()) {
    _initialize();
  }

  final Ref _ref;
  Timer? _refreshTimer;
  StreamSubscription? _roomSubscription;

  /// Initialisation avec gestion des ressources
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _loadRooms();
      _startPeriodicRefresh();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur d\'initialisation: $e',
      );
    }
  }

  /// Charger les salons avec optimisation
  Future<void> _loadRooms() async {
    try {
      final rooms = await LocalStorageService.getRooms();
      state = state.copyWith(
        rooms: rooms,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de chargement: $e',
      );
    }
  }

  /// Actualisation périodique optimisée
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _loadRooms();
      }
    });
  }

  /// Créer un salon avec optimisation
  Future<Room?> createRoom({int durationHours = 2}) async {
    state = state.copyWith(isLoading: true);

    try {
      final roomService = ref.read(roomServiceProvider);
      final room = await roomService.createRoom(durationHours: durationHours);
      
      final updatedRooms = [...state.rooms, room];
      state = state.copyWith(
        rooms: updatedRooms,
        currentRoom: room,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );
      
      return room;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de création: $e',
      );
      return null;
    }
  }

  /// Rejoindre un salon avec optimisation
  Future<bool> joinRoom(String roomId) async {
    final room = state.getRoomById(roomId);
    if (room == null) return false;

    state = state.copyWith(isLoading: true);
    
    try {
      final updatedRoom = room.join();
      final updatedRooms = state.rooms
          .map((r) => r.id == roomId ? updatedRoom : r)
          .toList();
      
      state = state.copyWith(
        rooms: updatedRooms,
        currentRoom: updatedRoom,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion: $e',
      );
      return false;
    }
  }

  /// Quitter un salon avec optimisation
  Future<bool> leaveRoom(String roomId) async {
    final room = state.getRoomById(roomId);
    if (room == null) return false;

    try {
      final updatedRoom = room.leave();
      final updatedRooms = state.rooms
          .map((r) => r.id == roomId ? updatedRoom : r)
          .toList();
      
      state = state.copyWith(
        rooms: updatedRooms,
        currentRoom: state.currentRoom?.id == roomId ? null : state.currentRoom,
        lastUpdate: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erreur de déconnexion: $e');
      return false;
    }
  }

  /// Actualiser les salons
  Future<void> refresh() async {
    await _loadRooms();
  }

  /// Nettoyer les ressources
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _roomSubscription?.cancel();
    super.dispose();
  }
}

// ============================================================================
// PROVIDERS OPTIMISÉS
// ============================================================================

/// Provider principal optimisé pour les salons
final optimizedRoomProvider = StateNotifierProvider.autoDispose<OptimizedRoomNotifier, OptimizedRoomState>((ref) {
  final notifier = OptimizedRoomNotifier(ref);
  
  // Nettoyer les ressources lors de la destruction
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

/// Provider pour écouter seulement l'état de chargement
final roomLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.isLoading));
});

/// Provider pour écouter seulement le nombre de salons
final roomCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.totalRooms));
});

/// Provider pour écouter seulement les salons actifs
final activeRoomsProvider = Provider.autoDispose<List<Room>>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.activeRooms));
});

/// Provider pour écouter seulement les salons en attente
final waitingRoomsProvider = Provider.autoDispose<List<Room>>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.waitingRooms));
});

/// Provider pour écouter seulement le salon actuel
final currentRoomProvider = Provider.autoDispose<Room?>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.currentRoom));
});

/// Provider pour écouter seulement l'ID du salon actuel
final currentRoomIdProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.currentRoom?.id));
});

/// Provider pour écouter seulement les erreurs
final roomErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(optimizedRoomProvider.select((state) => state.error));
});

// ============================================================================
// PROVIDERS FAMILY POUR DONNÉES SPÉCIFIQUES
// ============================================================================

/// Provider pour un salon spécifique par ID
final roomByIdProvider = Provider.autoDispose.family<Room?, String>((ref, roomId) {
  final state = ref.watch(optimizedRoomProvider);
  return state.getRoomById(roomId);
});

/// Provider pour vérifier si un salon existe
final roomExistsProvider = Provider.autoDispose.family<bool, String>((ref, roomId) {
  final state = ref.watch(optimizedRoomProvider);
  return state.hasRoom(roomId);
});

/// Provider pour les messages d'un salon spécifique
final roomMessagesProvider = FutureProvider.autoDispose.family<List<Message>, String>((ref, roomId) async {
  if (roomId.isEmpty) return [];
  
  // Simuler le chargement des messages
  await Future.delayed(const Duration(milliseconds: 200));
  
  return [
    Message.create(
      roomId: roomId,
      content: 'Message de test pour le salon $roomId',
      senderId: 'user123',
    ),
  ];
});

// ============================================================================
// PROVIDERS DE CACHE ET PERFORMANCE
// ============================================================================

/// Provider pour cache des statistiques des salons
final roomStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final state = ref.watch(optimizedRoomProvider);
  
  // Calculer les statistiques
  final stats = {
    'total': state.totalRooms,
    'active': state.activeRoomsCount,
    'waiting': state.waitingRoomsCount,
    'expired': state.expiredRooms.length,
  };
  
  // Conserver en cache pendant 30 secondes
  ref.keepAlive();
  Timer(const Duration(seconds: 30), () {
    ref.invalidateSelf();
  });
  
  return stats;
});
