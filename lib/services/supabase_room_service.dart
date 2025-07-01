import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/message.dart';
import 'supabase_auth_service.dart';

/// Service de gestion des salons avec Row Level Security et injection de dépendances
class SupabaseRoomService {
  /// Constructeur avec injection de dépendances
  /// [supabaseClient] Client Supabase injecté
  /// [authService] Service d'authentification injecté
  SupabaseRoomService({
    required SupabaseClient supabaseClient,
    required SupabaseAuthService authService,
  }) : _client = supabaseClient,
       _authService = authService;

  /// Client Supabase injecté
  final SupabaseClient _client;

  /// Service d'authentification injecté
  final SupabaseAuthService _authService;

  // === GESTION DES SALONS ===

  /// Créer un nouveau salon sécurisé
  Future<Room> createRoom({
    String? name,
    String? description,
    int durationHours = 6,
    int maxParticipants = 2,
    bool isPrivate = false,
  }) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final roomData = {
        'created_by': _authService.currentUser!.id,
        'name': name,
        'description': description,
        'expires_at': DateTime.now()
            .add(Duration(hours: durationHours))
            .toIso8601String(),
        'max_participants': maxParticipants,
        'status': 'waiting',
        'is_private': isPrivate,
      };

      final response =
          await _client.from('rooms').insert(roomData).select().single();

      return Room(
        id: response['id'],
        name: response['name'] ?? 'Salon ${response['id']}',
        createdAt: DateTime.parse(response['created_at']),
        expiresAt: DateTime.parse(response['expires_at']),
        status: RoomStatus.values.firstWhere(
          (s) => s.name == response['status'],
          orElse: () => RoomStatus.waiting,
        ),
        participantCount: 1, // Le créateur est automatiquement participant
        maxParticipants: response['max_participants'],
        creatorId: response['created_by'],
        metadata: {
          'description': response['description'],
          'is_private': response['is_private'] ?? false,
        },
      );
    } on PostgrestException catch (e) {
      throw Exception('Erreur lors de la création du salon: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la création du salon: $e');
    }
  }

  /// Rejoindre un salon existant
  Future<Room?> joinRoom(String roomId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Vérifier si le salon existe et est accessible
      final roomResponse = await _client
          .from('rooms')
          .select('*, room_participants!inner(user_id)')
          .eq('id', roomId)
          .single();

      final room = Room(
        id: roomResponse['id'],
        name: roomResponse['name'] ?? 'Salon ${roomResponse['id']}',
        createdAt: DateTime.parse(roomResponse['created_at']),
        expiresAt: DateTime.parse(roomResponse['expires_at']),
        status: RoomStatus.values.firstWhere(
          (s) => s.name == roomResponse['status'],
          orElse: () => RoomStatus.waiting,
        ),
        participantCount: (roomResponse['room_participants'] as List).length,
        maxParticipants: roomResponse['max_participants'],
        creatorId: roomResponse['created_by'],
        metadata: {
          'description': roomResponse['description'],
          'is_private': roomResponse['is_private'] ?? false,
        },
      );

      // Vérifier si le salon est encore valide
      if (room.isExpired) {
        throw Exception('Ce salon a expiré');
      }

      if (room.participantCount >= room.maxParticipants) {
        throw Exception('Ce salon est complet');
      }

      // Vérifier si l'utilisateur n'est pas déjà participant
      final existingParticipant = await _client
          .from('room_participants')
          .select()
          .eq('room_id', roomId)
          .eq('user_id', _authService.currentUser!.id)
          .maybeSingle();

      if (existingParticipant == null) {
        // Ajouter l'utilisateur comme participant
        await _client.from('room_participants').insert({
          'room_id': roomId,
          'user_id': _authService.currentUser!.id,
          'role': 'participant',
        });

        // Mettre à jour le statut du salon si nécessaire
        if (room.status == RoomStatus.waiting &&
            room.participantCount + 1 >= 2) {
          await _client
              .from('rooms')
              .update({'status': 'active'}).eq('id', roomId);

          // Créer une nouvelle instance avec le statut mis à jour
          return room.copyWith(status: RoomStatus.active);
        }
      }

      return room;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw Exception('Salon non trouvé');
      }
      throw Exception('Erreur lors de la connexion au salon: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la connexion au salon: $e');
    }
  }

  /// Quitter un salon
  Future<void> leaveRoom(String roomId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Marquer la participation comme terminée
      await _client
          .from('room_participants')
          .update({'left_at': DateTime.now().toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', _authService.currentUser!.id);

      // Si c'était le créateur, marquer le salon comme expiré
      final room = await _client
          .from('rooms')
          .select('created_by')
          .eq('id', roomId)
          .single();

      if (room['created_by'] == _authService.currentUser!.id) {
        await _client
            .from('rooms')
            .update({'status': 'expired'}).eq('id', roomId);
      }
    } catch (e) {
      throw Exception('Erreur lors de la sortie du salon: $e');
    }
  }

  /// Obtenir les salons de l'utilisateur
  Future<List<Room>> getUserRooms() async {
    if (!_authService.isAuthenticated) {
      return [];
    }

    try {
      final response = await _client
          .from('rooms')
          .select('''
            *,
            room_participants!inner(user_id, left_at)
          ''')
          .eq('room_participants.user_id', _authService.currentUser!.id)
          .isFilter('room_participants.left_at', null)
          .order('created_at', ascending: false);

      return response
          .map<Room>((data) => Room(
                id: data['id'],
                name: data['name'] ?? 'Salon ${data['id']}',
                createdAt: DateTime.parse(data['created_at']),
                expiresAt: DateTime.parse(data['expires_at']),
                status: RoomStatus.values.firstWhere(
                  (s) => s.name == data['status'],
                  orElse: () => RoomStatus.waiting,
                ),
                participantCount: (data['room_participants'] as List).length,
                maxParticipants: data['max_participants'],
                creatorId: data['created_by'],
                metadata: {
                  'description': data['description'],
                  'is_private': data['is_private'] ?? false,
                },
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des salons: $e');
      }
      return [];
    }
  }

  /// Obtenir un salon par ID
  Future<Room?> getRoom(String roomId) async {
    try {
      final response = await _client.from('rooms').select('''
            *,
            room_participants(user_id, left_at)
          ''').eq('id', roomId).single();

      final activeParticipants = (response['room_participants'] as List)
          .where((p) => p['left_at'] == null)
          .length;

      return Room(
        id: response['id'],
        name: response['name'] ?? 'Salon ${response['id']}',
        createdAt: DateTime.parse(response['created_at']),
        expiresAt: DateTime.parse(response['expires_at']),
        status: RoomStatus.values.firstWhere(
          (s) => s.name == response['status'],
          orElse: () => RoomStatus.waiting,
        ),
        participantCount: activeParticipants,
        maxParticipants: response['max_participants'],
        creatorId: response['created_by'],
        metadata: {
          'description': response['description'],
          'is_private': response['is_private'] ?? false,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du salon: $e');
      }
      return null;
    }
  }

  // === GESTION DES MESSAGES ===

  /// Envoyer un message chiffré
  Future<Message> sendMessage({
    required String roomId,
    required String encryptedContent,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_authService.isAuthenticated) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final messageData = {
        'room_id': roomId,
        'sender_id': _authService.currentUser!.id,
        'encrypted_content': encryptedContent,
        'message_type': type.name,
        'metadata': metadata,
      };

      final response =
          await _client.from('messages').insert(messageData).select().single();

      return Message(
        id: response['id'],
        roomId: response['room_id'],
        content: response['encrypted_content'],
        senderId: response['sender_id'],
        timestamp: DateTime.parse(response['created_at']),
        type: MessageType.values.firstWhere(
          (t) => t.name == response['message_type'],
          orElse: () => MessageType.text,
        ),
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  /// Obtenir les messages d'un salon
  Future<List<Message>> getRoomMessages(String roomId,
      {int limit = 50}) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map<Message>((data) => Message(
                id: data['id'],
                roomId: data['room_id'],
                content: data['encrypted_content'],
                senderId: data['sender_id'],
                timestamp: DateTime.parse(data['created_at']),
                type: MessageType.values.firstWhere(
                  (t) => t.name == data['message_type'],
                  orElse: () => MessageType.text,
                ),
              ))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération des messages: $e');
      }
      return [];
    }
  }

  // === TEMPS RÉEL ===

  /// S'abonner aux changements de salon
  static RealtimeChannel subscribeToRoom(
    String roomId, {
    Function(Room)? onRoomUpdate,
    Function(Message)? onNewMessage,
  }) {
    final channel = _client.channel('room:$roomId');

    if (onRoomUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'rooms',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: roomId,
        ),
        callback: (payload) {
          final data = payload.newRecord;
          final room = Room(
            id: data['id'],
            name: data['name'] ?? 'Salon ${data['id']}',
            createdAt: DateTime.parse(data['created_at']),
            expiresAt: DateTime.parse(data['expires_at']),
            status: RoomStatus.values.firstWhere(
              (s) => s.name == data['status'],
              orElse: () => RoomStatus.waiting,
            ),
            participantCount: data['participant_count'] ?? 0,
            maxParticipants: data['max_participants'],
            creatorId: data['created_by'],
            metadata: {
              'description': data['description'],
              'is_private': data['is_private'] ?? false,
            },
          );
          onRoomUpdate(room);
        },
      );
    }

    if (onNewMessage != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'room_id',
          value: roomId,
        ),
        callback: (payload) {
          final data = payload.newRecord;
          final message = Message(
            id: data['id'],
            roomId: data['room_id'],
            content: data['encrypted_content'],
            senderId: data['sender_id'],
            timestamp: DateTime.parse(data['created_at']),
            type: MessageType.values.firstWhere(
              (t) => t.name == data['message_type'],
              orElse: () => MessageType.text,
            ),
          );
          onNewMessage(message);
        },
      );
    }

    channel.subscribe();
    return channel;
  }

  /// Se désabonner d'un canal
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
