import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../services/room_service.dart';
import '../services/supabase_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService.instance;

  List<Room> _rooms = [];
  Room? _currentRoom;
  bool _isLoading = false;

  // Supabase integration
  RealtimeChannel? _messagesChannel;
  final List<Message> _messages = [];
  final bool _isSupabaseEnabled = true;
  String? _error;

  StreamSubscription<List<Room>>? _roomsSubscription;
  StreamSubscription<Room?>? _currentRoomSubscription;

  // Getters
  List<Room> get rooms => _rooms;
  Room? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Message> get messages => _messages;
  bool get isSupabaseEnabled => _isSupabaseEnabled;

  List<Room> get activeRooms => _rooms
      .where((r) => r.status == RoomStatus.active && !r.isExpired)
      .toList();

  List<Room> get waitingRooms => _rooms
      .where((r) => r.status == RoomStatus.waiting && !r.isExpired)
      .toList();

  List<Room> get expiredRooms => _rooms.where((r) => r.isExpired).toList();

  bool get hasActiveRoom =>
      _currentRoom != null &&
      _currentRoom!.status == RoomStatus.active &&
      !_currentRoom!.isExpired;

  bool get hasWaitingRoom =>
      _currentRoom != null &&
      _currentRoom!.status == RoomStatus.waiting &&
      !_currentRoom!.isExpired;

  RoomProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await _roomService.initialize();

      // Écouter les changements de salons
      _roomsSubscription = _roomService.roomsStream.listen((rooms) {
        _rooms = rooms;
        _clearError();
        notifyListeners();
      });

      // Écouter les changements de salon actuel
      _currentRoomSubscription = _roomService.currentRoomStream.listen((room) {
        _currentRoom = room;
        notifyListeners();
      });

      // Charger l'état initial
      _rooms = _roomService.rooms;
      _currentRoom = _roomService.currentRoom;
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Room?> createRoom({int durationHours = 6}) async {
    _setLoading(true);
    _clearError();

    try {
      // Créer le salon localement
      final room = await _roomService.createRoom(durationHours: durationHours);

      // Synchroniser avec Supabase si activé
      if (_isSupabaseEnabled) {
        try {
          await SupabaseService.createRoom(room);
          debugPrint('Salon synchronisé avec Supabase: ${room.id}');
        } catch (e) {
          debugPrint('Erreur synchronisation Supabase: $e');
          // Continue même si Supabase échoue
        }
      }

      return room;
    } catch (e) {
      _setError('Erreur lors de la création du salon: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Room?> joinRoom(String roomId) async {
    _setLoading(true);
    _clearError();

    try {
      // Essayer d'abord de récupérer depuis Supabase
      Room? room;
      if (_isSupabaseEnabled) {
        try {
          room = await SupabaseService.getRoom(roomId);
          if (room != null) {
            debugPrint('Salon trouvé dans Supabase: ${room.id}');
          }
        } catch (e) {
          debugPrint('Erreur récupération Supabase: $e');
        }
      }

      // Si pas trouvé dans Supabase, essayer localement
      room ??= await _roomService.joinRoom(roomId);

      // S'abonner aux messages en temps réel si Supabase est activé
      if (room != null && _isSupabaseEnabled) {
        _subscribeToMessages(roomId);
      }

      return room;
    } on RoomNotFoundException {
      _setError('Salon non trouvé');
      return null;
    } on RoomExpiredException {
      _setError('Ce salon a expiré');
      return null;
    } on RoomFullException {
      _setError('Ce salon est déjà complet');
      return null;
    } catch (e) {
      _setError('Erreur lors de la connexion au salon: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setCurrentRoom(String? roomId) async {
    try {
      await _roomService.setCurrentRoom(roomId);
    } catch (e) {
      _setError('Erreur lors de la sélection du salon: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    _clearError();

    try {
      await _roomService.deleteRoom(roomId);
    } catch (e) {
      _setError('Erreur lors de la suppression du salon: $e');
    }
  }

  Future<void> cleanupExpiredRooms() async {
    try {
      await _roomService.cleanupExpiredRooms();
    } catch (e) {
      _setError('Erreur lors du nettoyage: $e');
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    return await _roomService.getRoomById(roomId);
  }

  // Méthodes de convenance
  Future<Room?> createAndJoinRoom({int durationHours = 6}) async {
    _setLoading(true);
    _clearError();

    try {
      final room = await _roomService.createAndJoinRoom(
        durationHours: durationHours,
      );
      return room;
    } catch (e) {
      _setError('Erreur lors de la création du salon: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Room?> joinAndSetCurrentRoom(String roomId) async {
    _setLoading(true);
    _clearError();

    try {
      final room = await _roomService.joinAndSetCurrentRoom(roomId);
      return room;
    } on RoomNotFoundException {
      _setError('Salon non trouvé');
      return null;
    } on RoomExpiredException {
      _setError('Ce salon a expiré');
      return null;
    } on RoomFullException {
      _setError('Ce salon est déjà complet');
      return null;
    } catch (e) {
      _setError('Erreur lors de la connexion au salon: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Duration? getCurrentRoomTimeRemaining() {
    return _roomService.getCurrentRoomTimeRemaining();
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // === MÉTHODES SUPABASE ===

  /// S'abonner aux messages en temps réel d'un salon
  void _subscribeToMessages(String roomId) {
    _unsubscribeFromMessages(); // Se désabonner d'abord

    _messagesChannel = SupabaseService.subscribeToMessages(
      roomId,
      (message) {
        _messages.add(message);
        notifyListeners();
      },
    );
  }

  /// Se désabonner des messages
  void _unsubscribeFromMessages() {
    if (_messagesChannel != null) {
      SupabaseService.unsubscribe(_messagesChannel!);
      _messagesChannel = null;
    }
  }

  /// Synchroniser les salons avec Supabase
  Future<void> syncWithSupabase() async {
    if (!_isSupabaseEnabled) return;

    try {
      final supabaseRooms = await SupabaseService.getActiveRooms();

      // Fusionner avec les salons locaux
      for (final supabaseRoom in supabaseRooms) {
        final existingRoom = _rooms.firstWhere(
          (room) => room.id == supabaseRoom.id,
          orElse: () => supabaseRoom,
        );

        if (!_rooms.contains(existingRoom)) {
          _rooms.add(supabaseRoom);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur synchronisation Supabase: $e');
    }
  }

  /// Nettoyer les salons expirés avec Supabase
  Future<void> cleanupExpiredRoomsWithSupabase() async {
    if (_isSupabaseEnabled) {
      try {
        await SupabaseService.cleanupExpiredRooms();
      } catch (e) {
        debugPrint('Erreur nettoyage Supabase: $e');
      }
    }

    // Nettoyage local
    await _roomService.cleanupExpiredRooms();
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _currentRoomSubscription?.cancel();
    _unsubscribeFromMessages();
    super.dispose();
  }
}

// Extension pour faciliter l'utilisation dans les widgets
extension RoomProviderExtensions on RoomProvider {
  bool isCurrentRoom(String roomId) {
    return _currentRoom?.id == roomId;
  }

  Room? findRoomById(String roomId) {
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  List<Room> getRoomsByStatus(RoomStatus status) {
    return _rooms.where((r) => r.status == status && !r.isExpired).toList();
  }

  int get totalActiveRooms => activeRooms.length;
  int get totalWaitingRooms => waitingRooms.length;
  int get totalExpiredRooms => expiredRooms.length;

  bool get hasAnyRooms => _rooms.isNotEmpty;
  bool get hasOnlyExpiredRooms =>
      _rooms.isNotEmpty && _rooms.every((r) => r.isExpired);
}
