import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import 'room_key_service.dart';

/// Service de gestion des salons avec injection de dépendances
/// Conforme aux meilleures pratiques Context7 Riverpod
class RoomService {
  static const String _roomsKey = 'secure_rooms';
  static const String _currentRoomKey = 'current_room_id';

  /// Constructeur avec injection de dépendances
  /// [roomKeyService] Service de gestion des clés de salon
  RoomService({
    required RoomKeyService roomKeyService,
  }) : _roomKeyService = roomKeyService;

  /// Service de gestion des clés injecté
  final RoomKeyService _roomKeyService;

  final StreamController<List<Room>> _roomsController =
      StreamController<List<Room>>.broadcast();
  final StreamController<Room?> _currentRoomController =
      StreamController<Room?>.broadcast();

  Stream<List<Room>> get roomsStream => _roomsController.stream;
  Stream<Room?> get currentRoomStream => _currentRoomController.stream;

  List<Room> _rooms = [];
  Room? _currentRoom;
  Timer? _expirationTimer;

  List<Room> get rooms => List.unmodifiable(_rooms);
  Room? get currentRoom => _currentRoom;

  Future<void> initialize() async {
    await _roomKeyService.initialize();
    await _loadRooms();
    await _loadCurrentRoom();
    _startExpirationTimer();
    _cleanupExpiredRooms();
  }

  Future<Room> createRoom({int durationHours = 6}) async {
    final room = Room.create(durationHours: durationHours);

    // Générer une clé de chiffrement pour ce salon
    await _roomKeyService.generateKeyForRoom(room.id);

    _rooms.add(room);
    await _saveRooms();
    _roomsController.add(_rooms);
    return room;
  }

  Future<Room?> joinRoom(String roomId) async {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) {
      throw RoomNotFoundException('Salon non trouvé');
    }

    final room = _rooms[roomIndex];

    if (room.isExpired) {
      throw RoomExpiredException('Ce salon a expiré');
    }

    if (room.status == RoomStatus.active) {
      throw RoomFullException('Ce salon est déjà complet');
    }

    final joinedRoom = room.join();
    _rooms[roomIndex] = joinedRoom;
    await _saveRooms();
    _roomsController.add(_rooms);

    return joinedRoom;
  }

  Future<void> setCurrentRoom(String? roomId) async {
    if (roomId == null) {
      _currentRoom = null;
    } else {
      _currentRoom = _rooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => throw RoomNotFoundException('Salon non trouvé'),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    if (roomId != null) {
      await prefs.setString(_currentRoomKey, roomId);
    } else {
      await prefs.remove(_currentRoomKey);
    }

    _currentRoomController.add(_currentRoom);
  }

  Future<void> deleteRoom(String roomId) async {
    _rooms.removeWhere((r) => r.id == roomId);

    // Supprimer la clé associée
    await _roomKeyService.removeKeyForRoom(roomId);

    if (_currentRoom?.id == roomId) {
      await setCurrentRoom(null);
    }

    await _saveRooms();
    _roomsController.add(_rooms);
  }

  Future<void> cleanupExpiredRooms() async {
    final initialCount = _rooms.length;
    _rooms.removeWhere((room) => room.isExpired);

    if (_rooms.length != initialCount) {
      // Nettoyer les clés des salons supprimés
      final activeRoomIds = _rooms.map((r) => r.id).toList();
      await _roomKeyService.cleanupExpiredRoomKeys(activeRoomIds);

      // Si le salon actuel a expiré
      if (_currentRoom?.isExpired == true) {
        await setCurrentRoom(null);
      }

      await _saveRooms();
      _roomsController.add(_rooms);
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  List<Room> getActiveRooms() {
    return _rooms
        .where((room) => room.status == RoomStatus.active && !room.isExpired)
        .toList();
  }

  List<Room> getWaitingRooms() {
    return _rooms
        .where((room) => room.status == RoomStatus.waiting && !room.isExpired)
        .toList();
  }

  List<Room> getExpiredRooms() {
    return _rooms.where((room) => room.isExpired).toList();
  }

  Future<void> _loadRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_roomsKey);

      if (roomsJson != null) {
        final List<dynamic> roomsList = json.decode(roomsJson);
        _rooms = roomsList.map((json) => Room.fromJson(json)).toList();
      }
    } catch (e) {
      _rooms = [];
    }
  }

  Future<void> _loadCurrentRoom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentRoomId = prefs.getString(_currentRoomKey);

      if (currentRoomId != null) {
        _currentRoom = _rooms.firstWhere(
          (r) => r.id == currentRoomId,
          orElse: () => throw StateError('Room not found'),
        );
      }
    } catch (e) {
      _currentRoom = null;
    }
  }

  Future<void> _saveRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = json.encode(_rooms.map((r) => r.toJson()).toList());
      await prefs.setString(_roomsKey, roomsJson);
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }

  void _startExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cleanupExpiredRooms(),
    );
  }

  void _cleanupExpiredRooms() {
    cleanupExpiredRooms();
  }

  /// Synchroniser un salon depuis Supabase
  Future<void> syncRoomFromSupabase(Room room) async {
    final existingIndex = _rooms.indexWhere((r) => r.id == room.id);

    if (existingIndex != -1) {
      _rooms[existingIndex] = room;
    } else {
      _rooms.add(room);
    }

    await _saveRooms();
    _roomsController.add(List.from(_rooms));
  }

  void dispose() {
    _expirationTimer?.cancel();
    _roomsController.close();
    _currentRoomController.close();
  }
}

// Exceptions personnalisées
class RoomException implements Exception {
  final String message;
  RoomException(this.message);

  @override
  String toString() => 'RoomException: $message';
}

class RoomNotFoundException extends RoomException {
  RoomNotFoundException(super.message);
}

class RoomExpiredException extends RoomException {
  RoomExpiredException(super.message);
}

class RoomFullException extends RoomException {
  RoomFullException(super.message);
}

// Extension pour faciliter l'utilisation
extension RoomServiceExtensions on RoomService {
  Future<Room> createAndJoinRoom({int durationHours = 6}) async {
    final room = await createRoom(durationHours: durationHours);
    await setCurrentRoom(room.id);
    return room;
  }

  Future<Room> joinAndSetCurrentRoom(String roomId) async {
    final room = await joinRoom(roomId);
    if (room == null) {
      throw RoomNotFoundException('Impossible de rejoindre le salon');
    }
    await setCurrentRoom(room.id);
    return room;
  }

  bool hasActiveRoom() {
    return _currentRoom != null &&
        _currentRoom!.status == RoomStatus.active &&
        !_currentRoom!.isExpired;
  }

  bool hasWaitingRoom() {
    return _currentRoom != null &&
        _currentRoom!.status == RoomStatus.waiting &&
        !_currentRoom!.isExpired;
  }

  Duration? getCurrentRoomTimeRemaining() {
    if (_currentRoom == null || _currentRoom!.isExpired) {
      return null;
    }
    return _currentRoom!.timeRemaining;
  }
}
