import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/room.dart';
import '../models/message.dart';
import 'room_key_service.dart';

/// Service de stockage local pour le MVP avec injection de dépendances
/// Permet de tester l'app sans configuration Supabase
class LocalStorageService {
  static const String _roomsKey = 'local_rooms';
  static const String _messagesKey = 'local_messages';

  /// Constructeur avec injection de dépendances
  /// [roomKeyService] Service de gestion des clés de salon
  LocalStorageService({
    RoomKeyService? roomKeyService,
  }) : _roomKeyService = roomKeyService;

  /// Service de gestion des clés injecté (optionnel pour compatibilité)
  final RoomKeyService? _roomKeyService;

  /// Sauvegarder un salon localement
  static Future<void> saveRoom(Room room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_roomsKey) ?? '[]';
      final List<dynamic> rooms = jsonDecode(roomsJson);

      // Ajouter ou mettre à jour le salon
      final existingIndex = rooms.indexWhere((r) => r['id'] == room.id);
      final roomData = {
        'id': room.id,
        'name': room.name,
        'created_at': room.createdAt.toIso8601String(),
        'expires_at': room.expiresAt.toIso8601String(),
        'status': room.status.name,
        'participant_count': room.participantCount,
        'max_participants': room.maxParticipants,
      };

      if (existingIndex >= 0) {
        rooms[existingIndex] = roomData;
      } else {
        rooms.add(roomData);
      }

      await prefs.setString(_roomsKey, jsonEncode(rooms));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du salon: $e');
    }
  }

  /// Récupérer tous les salons locaux
  static Future<List<Room>> getRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString(_roomsKey) ?? '[]';
      final List<dynamic> rooms = jsonDecode(roomsJson);

      return rooms
          .map<Room>((data) => Room(
                id: data['id'],
                name: data['name'] ?? 'Salon ${data['id']}',
                createdAt: DateTime.parse(data['created_at']),
                expiresAt: DateTime.parse(data['expires_at']),
                status: RoomStatus.values.firstWhere(
                  (status) => status.name == data['status'],
                  orElse: () => RoomStatus.active,
                ),
                participantCount: data['participant_count'] ?? 1,
                maxParticipants: data['max_participants'] ?? 2,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder un message localement
  static Future<void> saveMessage(Message message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey) ?? '{}';
      final Map<String, dynamic> messagesByRoom = jsonDecode(messagesJson);

      final roomMessages =
          List<dynamic>.from(messagesByRoom[message.roomId] ?? []);

      roomMessages.add({
        'id': message.id,
        'room_id': message.roomId,
        'content': message.content,
        'sender_id': message.senderId,
        'timestamp': message.timestamp.toIso8601String(),
        'message_type': message.type.name,
      });

      messagesByRoom[message.roomId] = roomMessages;
      await prefs.setString(_messagesKey, jsonEncode(messagesByRoom));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du message: $e');
    }
  }

  /// Récupérer les messages d'un salon
  static Future<List<Message>> getMessages(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey) ?? '{}';
      final Map<String, dynamic> messagesByRoom = jsonDecode(messagesJson);

      final roomMessages = List<dynamic>.from(messagesByRoom[roomId] ?? []);

      return roomMessages
          .map<Message>((data) => Message(
                id: data['id'],
                roomId: data['room_id'],
                content: data['content'],
                senderId: data['sender_id'],
                timestamp: DateTime.parse(data['timestamp']),
                type: MessageType.values.firstWhere(
                  (type) => type.name == data['message_type'],
                  orElse: () => MessageType.text,
                ),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Supprimer un salon et ses messages
  static Future<void> deleteRoom(String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Supprimer le salon
      final roomsJson = prefs.getString(_roomsKey) ?? '[]';
      final List<dynamic> rooms = jsonDecode(roomsJson);
      rooms.removeWhere((r) => r['id'] == roomId);
      await prefs.setString(_roomsKey, jsonEncode(rooms));

      // Supprimer les messages
      final messagesJson = prefs.getString(_messagesKey) ?? '{}';
      final Map<String, dynamic> messagesByRoom = jsonDecode(messagesJson);
      messagesByRoom.remove(roomId);
      await prefs.setString(_messagesKey, jsonEncode(messagesByRoom));
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Nettoyer toutes les données locales
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roomsKey);
    await prefs.remove(_messagesKey);
  }

  /// Créer des données de démonstration pour tester l'app - SOLUTION CRITIQUE
  Future<void> createDemoData() async {
    // Vérifier si les données démo existent déjà
    final existingRooms = await getRooms();
    final demoExists = existingRooms.any((room) => room.id == 'demo-room');

    if (!demoExists) {
      // Créer un salon de démonstration
      final demoRoom = Room(
        id: 'demo-room',
        name: '🚀 Salon de démonstration',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: RoomStatus.active,
        participantCount: 2, // Simuler 2 participants connectés
        maxParticipants: 5,
      );

      await saveRoom(demoRoom);
      debugPrint('📱 Salon de démonstration créé: ${demoRoom.id}');
    }

    // CORRECTION CRITIQUE : Toujours vérifier et générer la clé
    if (_roomKeyService != null) {
      final hasKey = await _roomKeyService!.hasKeyForRoom('demo-room');
      if (!hasKey) {
        final generatedKey = await _roomKeyService!.generateKeyForRoom('demo-room');
        debugPrint(
            '🔑 Clé de chiffrement générée pour salon démo: ${generatedKey.substring(0, 8)}...');
      } else {
        debugPrint('🔑 Clé de chiffrement déjà présente pour salon démo');
      }
    }

    // Ajouter quelques messages de démonstration
    final demoMessages = [
      Message(
        id: 'demo-msg-1',
        roomId: 'demo-room',
        content: '👋 Bienvenue dans SecureChat!',
        senderId: 'demo-user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: MessageType.text,
      ),
      Message(
        id: 'demo-msg-2',
        roomId: 'demo-room',
        content: '🔒 Vos messages sont chiffrés de bout en bout',
        senderId: 'demo-user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        type: MessageType.text,
      ),
      Message(
        id: 'demo-msg-3',
        roomId: 'demo-room',
        content: '✨ Commencez à discuter en sécurité!',
        senderId: 'demo-user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        type: MessageType.text,
      ),
    ];

    for (final message in demoMessages) {
      await saveMessage(message);
    }
  }
}
