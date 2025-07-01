import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../services/room_service.dart';
import '../services/supabase_room_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/local_storage_service.dart';
import '../core/providers/service_providers.dart';

// État des salons
class RoomState {
  final List<Room> rooms;
  final Room? currentRoom;
  final bool isLoading;
  final String? error;
  final List<Message> messages;
  final bool isSupabaseEnabled;

  const RoomState({
    this.rooms = const [],
    this.currentRoom,
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.isSupabaseEnabled = true,
  });

  // Getters calculés
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

  bool get hasAnyRooms => rooms.isNotEmpty;
  bool get hasOnlyExpiredRooms =>
      rooms.isNotEmpty && rooms.every((r) => r.isExpired);

  int get totalActiveRooms => activeRooms.length;
  int get totalWaitingRooms => waitingRooms.length;
  int get totalExpiredRooms => expiredRooms.length;

  RoomState copyWith({
    List<Room>? rooms,
    Room? currentRoom,
    bool? isLoading,
    String? error,
    List<Message>? messages,
    bool? isSupabaseEnabled,
    bool clearCurrentRoom = false,
    bool clearError = false,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      currentRoom: clearCurrentRoom ? null : (currentRoom ?? this.currentRoom),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      messages: messages ?? this.messages,
      isSupabaseEnabled: isSupabaseEnabled ?? this.isSupabaseEnabled,
    );
  }
}

// StateNotifier pour gérer l'état des salons avec injection de dépendances
class RoomNotifier extends StateNotifier<RoomState> {
  final RoomService _roomService;
  final SupabaseAuthService _supabaseAuthService;
  final SupabaseRoomService _supabaseRoomService;

  RealtimeChannel? _messagesChannel;
  StreamSubscription<List<Room>>? _roomsSubscription;
  StreamSubscription<Room?>? _currentRoomSubscription;

  RoomNotifier({
    required RoomService roomService,
    required SupabaseAuthService supabaseAuthService,
    required SupabaseRoomService supabaseRoomService,
  }) : _roomService = roomService,
       _supabaseAuthService = supabaseAuthService,
       _supabaseRoomService = supabaseRoomService,
       super(const RoomState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _roomService.initialize();

      // MVP: Charger ou créer des données de démonstration
      await _loadOrCreateDemoData();

      // Écouter les changements de salons
      _roomsSubscription = _roomService.roomsStream.listen((rooms) {
        state = state.copyWith(rooms: rooms, clearError: true);
      });

      // Écouter les changements de salon actuel
      _currentRoomSubscription = _roomService.currentRoomStream.listen((room) {
        state = state.copyWith(currentRoom: room);
      });

      // L'état initial est déjà chargé par _loadOrCreateDemoData()
      final currentRoom = _roomService.currentRoom;
      if (currentRoom != null) {
        state = state.copyWith(currentRoom: currentRoom);
      }
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de l\'initialisation: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Room?> createRoom({int durationHours = 6}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      Room? room;

      // Essayer d'abord avec Supabase si l'utilisateur est connecté
      if (state.isSupabaseEnabled && _supabaseAuthService.isAuthenticated) {
        try {
          room = await _supabaseRoomService.createRoom(
            durationHours: durationHours,
          );
          debugPrint('✅ Salon créé avec Supabase RLS: ${room.id}');
        } catch (e) {
          debugPrint('❌ Erreur création Supabase: $e');
          state = state.copyWith(error: 'Erreur Supabase: $e');
          // Fallback vers le service local
        }
      } else {
        debugPrint(
            '⚠️ Supabase non disponible - utilisateur non connecté ou service désactivé');
      }

      // Fallback vers le service local si Supabase échoue
      room ??= await _roomService.createRoom(durationHours: durationHours);

      return room;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la création du salon: $e');
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Room?> joinRoom(String roomId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      Room? room;

      // Essayer d'abord avec Supabase si l'utilisateur est connecté
      if (state.isSupabaseEnabled && _supabaseAuthService.isAuthenticated) {
        try {
          room = await _supabaseRoomService.joinRoom(roomId);
          if (room != null) {
            debugPrint('Salon rejoint avec Supabase RLS: ${room.id}');
            // S'abonner aux messages en temps réel
            _subscribeToMessages(roomId);
          }
        } catch (e) {
          debugPrint('Erreur rejoindre Supabase: $e');
          // Fallback vers le service local
        }
      }

      // Fallback vers le service local si Supabase échoue
      room ??= await _roomService.joinRoom(roomId);

      return room;
    } on RoomNotFoundException {
      state = state.copyWith(error: 'Salon non trouvé');
      return null;
    } on RoomExpiredException {
      state = state.copyWith(error: 'Ce salon a expiré');
      return null;
    } on RoomFullException {
      state = state.copyWith(error: 'Ce salon est déjà complet');
      return null;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la connexion au salon: $e');
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Room?> createAndJoinRoom({int durationHours = 6}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      Room? room;

      // Essayer d'abord avec Supabase si l'utilisateur est connecté
      if (state.isSupabaseEnabled && _supabaseAuthService.isAuthenticated) {
        try {
          room = await _supabaseRoomService.createRoom(
            durationHours: durationHours,
          );
          debugPrint('✅ Salon créé et rejoint avec Supabase RLS: ${room.id}');
          // Définir comme salon actuel
          await _roomService.setCurrentRoom(room.id);
        } catch (e) {
          debugPrint('❌ Erreur création Supabase: $e');
          state = state.copyWith(error: 'Erreur Supabase: $e');
          // Fallback vers le service local
        }
      } else {
        debugPrint('⚠️ Supabase non disponible - utilisation du service local');
      }

      // Fallback vers le service local si Supabase échoue ou n'est pas disponible
      room ??= await _roomService.createAndJoinRoom(
        durationHours: durationHours,
      );

      debugPrint('✅ Salon créé et rejoint avec succès: ${room.id}');

      return room;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création du salon: $e');
      state = state.copyWith(error: 'Erreur lors de la création du salon: $e');
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Room?> joinAndSetCurrentRoom(String roomId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final room = await _roomService.joinAndSetCurrentRoom(roomId);
      return room;
    } on RoomNotFoundException {
      state = state.copyWith(error: 'Salon non trouvé');
      return null;
    } on RoomExpiredException {
      state = state.copyWith(error: 'Ce salon a expiré');
      return null;
    } on RoomFullException {
      state = state.copyWith(error: 'Ce salon est déjà complet');
      return null;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la connexion au salon: $e');
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setCurrentRoom(String? roomId) async {
    try {
      await _roomService.setCurrentRoom(roomId);
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la sélection du salon: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    state = state.copyWith(clearError: true);

    try {
      await _roomService.deleteRoom(roomId);
    } catch (e) {
      state =
          state.copyWith(error: 'Erreur lors de la suppression du salon: $e');
    }
  }

  Future<void> cleanupExpiredRooms() async {
    try {
      await _roomService.cleanupExpiredRooms();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du nettoyage: $e');
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    return await _roomService.getRoomById(roomId);
  }

  Duration? getCurrentRoomTimeRemaining() {
    return _roomService.getCurrentRoomTimeRemaining();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // === MÉTHODES SUPABASE ===

  /// S'abonner aux messages en temps réel d'un salon
  void _subscribeToMessages(String roomId) {
    _unsubscribeFromMessages(); // Se désabonner d'abord

    if (_supabaseAuthService.isAuthenticated) {
      _messagesChannel = _supabaseRoomService.subscribeToRoom(
        roomId,
        onNewMessage: (message) {
          final updatedMessages = [...state.messages, message];
          state = state.copyWith(messages: updatedMessages);
        },
      );
    }
  }

  /// Se désabonner des messages
  void _unsubscribeFromMessages() {
    if (_messagesChannel != null) {
      _supabaseRoomService.unsubscribe(_messagesChannel!);
      _messagesChannel = null;
    }
  }

  /// Charger ou créer des données de démonstration pour le MVP
  Future<void> _loadOrCreateDemoData() async {
    try {
      final existingRooms = await LocalStorageService.getRooms();
      if (existingRooms.isEmpty) {
        await LocalStorageService.createDemoData();
        if (kDebugMode) {
          print('📱 Données de démonstration créées pour le MVP');
        }
        // CORRECTION CRITIQUE: Recharger les données après création
        await _loadLocalRooms();
      } else {
        if (kDebugMode) {
          print(
              '📱 Données existantes trouvées: ${existingRooms.length} salon(s)');
        }
        // S'assurer que l'état est mis à jour avec les données existantes
        state = state.copyWith(rooms: existingRooms);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur création données démo: $e');
      }
      // Fallback: essayer de charger les données existantes quand même
      await _loadLocalRooms();
    }
  }

  /// Charger les salons depuis le stockage local
  Future<void> _loadLocalRooms() async {
    try {
      final localRooms = await LocalStorageService.getRooms();
      state = state.copyWith(rooms: localRooms, clearError: true);
      if (kDebugMode) {
        print(
            '✅ ${localRooms.length} salon(s) chargé(s) depuis le stockage local');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur chargement salons locaux: $e');
      }
      // En cas d'erreur, garder une liste vide plutôt que planter
      state = state.copyWith(rooms: [], error: 'Erreur de chargement: $e');
    }
  }

  /// Charger les messages d'un salon depuis le stockage local
  Future<void> loadMessages(String roomId) async {
    try {
      final localMessages = await LocalStorageService.getMessages(roomId);
      state = state.copyWith(messages: localMessages);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur chargement messages: $e');
      }
    }
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _currentRoomSubscription?.cancel();
    _unsubscribeFromMessages();
    super.dispose();
  }
}

// Provider global pour RoomState avec injection de dépendances - OPTIMISÉ
final roomProvider = StateNotifierProvider.autoDispose<RoomNotifier, RoomState>((ref) {
  final roomService = ref.watch(roomServiceProvider);
  final supabaseAuthService = ref.watch(supabaseAuthServiceProvider);
  final supabaseRoomService = ref.watch(supabaseRoomServiceProvider);

  final notifier = RoomNotifier(
    roomService: roomService,
    supabaseAuthService: supabaseAuthService,
    supabaseRoomService: supabaseRoomService,
  );

  // Garder en vie si des salons sont actifs pour éviter la perte de données critiques
  ref.listen(roomProvider.select((state) => state.activeRooms.isNotEmpty), (previous, next) {
    if (next) {
      ref.keepAlive();
    }
  });

  return notifier;
});

// Providers dérivés OPTIMISÉS avec select() pour éviter les rebuilds inutiles
final activeRoomsProvider = Provider.autoDispose<List<Room>>((ref) {
  return ref.watch(roomProvider.select((state) => state.activeRooms));
});

final waitingRoomsProvider = Provider.autoDispose<List<Room>>((ref) {
  return ref.watch(roomProvider.select((state) => state.waitingRooms));
});

final currentRoomProvider = Provider.autoDispose<Room?>((ref) {
  return ref.watch(roomProvider.select((state) => state.currentRoom));
});

final hasActiveRoomProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(roomProvider.select((state) => state.hasActiveRoom));
});

// Providers dérivés OPTIMISÉS supplémentaires avec select()
final expiredRoomsProvider = Provider.autoDispose<List<Room>>((ref) {
  return ref.watch(roomProvider.select((state) => state.expiredRooms));
});

final roomsLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(roomProvider.select((state) => state.isLoading));
});

final roomsErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(roomProvider.select((state) => state.error));
});

final messagesProvider = Provider.autoDispose<List<Message>>((ref) {
  return ref.watch(roomProvider.select((state) => state.messages));
});

final totalActiveRoomsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.totalActiveRooms));
});

final totalWaitingRoomsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.totalWaitingRooms));
});

final totalExpiredRoomsProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(roomProvider.select((state) => state.totalExpiredRooms));
});

// Providers FAMILY pour des cas d'usage spécifiques
final roomByIdProvider = Provider.autoDispose.family<Room?, String>((ref, roomId) {
  final rooms = ref.watch(roomProvider.select((state) => state.rooms));
  return rooms.cast<Room?>().firstWhere(
    (room) => room?.id == roomId,
    orElse: () => null,
  );
});

final roomMessagesCountProvider = Provider.autoDispose.family<int, String>((ref, roomId) {
  final room = ref.watch(roomByIdProvider(roomId));
  return room?.messageCount ?? 0;
});

final isRoomActiveProvider = Provider.autoDispose.family<bool, String>((ref, roomId) {
  final room = ref.watch(roomByIdProvider(roomId));
  return room?.status == RoomStatus.active && !(room?.isExpired ?? true);
});
