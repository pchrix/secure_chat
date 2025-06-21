import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/message.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://wfcnymkoufwtsalnbgvb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmY255bWtvdWZ3dHNhbG5iZ3ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0NjgxMDMsImV4cCI6MjA2NjA0NDEwM30.0pbagW0K-nAkO_PZuH2ZXzs9kiCTAU2NLSmSIgZbxH0';

  static SupabaseClient get client => Supabase.instance.client;

  // Initialisation du service Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // === GESTION DES SALONS ===

  /// Créer un nouveau salon dans Supabase
  static Future<void> createRoom(Room room) async {
    try {
      await client.from('rooms').insert({
        'id': room.id,
        'created_at': room.createdAt.toIso8601String(),
        'expires_at': room.expiresAt.toIso8601String(),
        'status': room.status.name,
        'participant_count': 0,
        'max_participants': 10, // Limite par défaut
      });
    } catch (e) {
      throw Exception('Erreur lors de la création du salon: $e');
    }
  }

  /// Récupérer un salon par son ID
  static Future<Room?> getRoom(String roomId) async {
    try {
      final response =
          await client.from('rooms').select().eq('id', roomId).single();

      return Room(
        id: response['id'],
        createdAt: DateTime.parse(response['created_at']),
        expiresAt: DateTime.parse(response['expires_at']),
        status: RoomStatus.values.firstWhere(
          (status) => status.name == response['status'],
          orElse: () => RoomStatus.active,
        ),
        participantCount: response['participant_count'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour le statut d'un salon
  static Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    try {
      await client
          .from('rooms')
          .update({'status': status.name}).eq('id', roomId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du salon: $e');
    }
  }

  /// Supprimer un salon expiré
  static Future<void> deleteRoom(String roomId) async {
    try {
      // Supprimer d'abord tous les messages du salon
      await client.from('messages').delete().eq('room_id', roomId);

      // Puis supprimer le salon
      await client.from('rooms').delete().eq('id', roomId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du salon: $e');
    }
  }

  /// Lister les salons actifs
  static Future<List<Room>> getActiveRooms() async {
    try {
      final response = await client
          .from('rooms')
          .select()
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return response
          .map<Room>((data) => Room(
                id: data['id'],
                createdAt: DateTime.parse(data['created_at']),
                expiresAt: DateTime.parse(data['expires_at']),
                status: RoomStatus.values.firstWhere(
                  (status) => status.name == data['status'],
                  orElse: () => RoomStatus.active,
                ),
                participantCount: data['participant_count'] ?? 0,
              ))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des salons: $e');
    }
  }

  // === GESTION DES MESSAGES ===

  /// Sauvegarder un message chiffré
  static Future<void> saveMessage(Message message) async {
    try {
      await client.from('messages').insert({
        'id': message.id,
        'room_id': message.roomId,
        'content': message.content, // Contenu déjà chiffré
        'sender_id': message.senderId,
        'timestamp': message.timestamp.toIso8601String(),
        'message_type': message.type.name,
      });
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du message: $e');
    }
  }

  /// Récupérer les messages d'un salon
  static Future<List<Message>> getMessages(String roomId,
      {int limit = 50}) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return response
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
          .toList()
          .reversed
          .toList(); // Inverser pour avoir l'ordre chronologique
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  /// Supprimer les messages d'un salon
  static Future<void> deleteMessages(String roomId) async {
    try {
      await client.from('messages').delete().eq('room_id', roomId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression des messages: $e');
    }
  }

  // === GESTION DES CLÉS DE CHIFFREMENT ===

  /// Sauvegarder une clé de chiffrement (chiffrée)
  static Future<void> saveEncryptionKey(
      String roomId, String encryptedKey, String keyHash) async {
    try {
      await client.from('room_keys').upsert({
        'room_id': roomId,
        'encrypted_key': encryptedKey,
        'key_hash': keyHash,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la clé: $e');
    }
  }

  /// Récupérer une clé de chiffrement
  static Future<String?> getEncryptionKey(String roomId) async {
    try {
      final response = await client
          .from('room_keys')
          .select('encrypted_key')
          .eq('room_id', roomId)
          .single();

      return response['encrypted_key'];
    } catch (e) {
      return null;
    }
  }

  /// Supprimer une clé de chiffrement
  static Future<void> deleteEncryptionKey(String roomId) async {
    try {
      await client.from('room_keys').delete().eq('room_id', roomId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la clé: $e');
    }
  }

  // === NETTOYAGE AUTOMATIQUE ===

  /// Nettoyer les salons expirés
  static Future<void> cleanupExpiredRooms() async {
    try {
      final expiredRooms = await client
          .from('rooms')
          .select('id')
          .lt('expires_at', DateTime.now().toIso8601String());

      for (final room in expiredRooms) {
        await deleteRoom(room['id']);
      }
    } catch (e) {
      throw Exception('Erreur lors du nettoyage: $e');
    }
  }

  // === TEMPS RÉEL ===

  /// S'abonner aux nouveaux messages d'un salon
  static RealtimeChannel subscribeToMessages(
      String roomId, Function(Message) onMessage) {
    return client
        .channel('messages:$roomId')
        .onPostgresChanges(
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
              content: data['content'],
              senderId: data['sender_id'],
              timestamp: DateTime.parse(data['timestamp']),
              type: MessageType.values.firstWhere(
                (type) => type.name == data['message_type'],
                orElse: () => MessageType.text,
              ),
            );
            onMessage(message);
          },
        )
        .subscribe();
  }

  /// Se désabonner d'un canal
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
