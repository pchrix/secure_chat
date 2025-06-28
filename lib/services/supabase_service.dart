import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../config/app_config.dart';

/// Exception personnalisée pour les erreurs Supabase
class SupabaseServiceException implements Exception {
  final String message;
  final String? code;
  final String? details;
  final SupabaseErrorType type;
  final DateTime timestamp;

  SupabaseServiceException(
    this.message, {
    this.code,
    this.details,
    this.type = SupabaseErrorType.unknown,
  }) : timestamp = DateTime.now();

  factory SupabaseServiceException._fromPostgrest(PostgrestException e) {
    _logError('PostgrestException', e.message, e.code, e.details?.toString());
    return SupabaseServiceException(
      'Erreur de base de données: ${e.message}',
      code: e.code,
      details: e.details?.toString(),
      type: SupabaseErrorType.database,
    );
  }

  factory SupabaseServiceException._fromTimeout() {
    _logError('TimeoutException', 'Délai d\'attente dépassé', null, null);
    return SupabaseServiceException(
      'Délai d\'attente dépassé. Vérifiez votre connexion internet.',
      type: SupabaseErrorType.timeout,
    );
  }

  factory SupabaseServiceException._fromConnection(String details) {
    _logError('ConnectionException', 'Erreur de connexion', null, details);
    return SupabaseServiceException(
      'Impossible de se connecter au serveur. Vérifiez votre connexion.',
      details: details,
      type: SupabaseErrorType.connection,
    );
  }

  static void _logError(
      String type, String message, String? code, String? details) {
    if (kDebugMode) {
      developer.log(
        '🔴 SupabaseError [$type]: $message',
        name: 'SupabaseService',
        error: {
          'type': type,
          'message': message,
          'code': code,
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  @override
  String toString() => message;
}

/// Types d'erreurs Supabase pour un meilleur handling
enum SupabaseErrorType {
  database,
  connection,
  timeout,
  authentication,
  permission,
  unknown,
}

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Initialisation sécurisée du service Supabase
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Vérifier si la configuration Supabase est disponible
    if (!AppConfig.isSupabaseConfigured) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('📱 Application en mode hors-ligne (MVP)');
        // ignore: avoid_print
        print(
            '💡 Pour activer Supabase, configurez les variables d\'environnement');
      }
      _isInitialized = true;
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.getSupabaseUrl(),
        anonKey: AppConfig.getSupabaseAnonKey(),
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _isInitialized = true;
      if (kDebugMode) {
        // ignore: avoid_print
        print('✅ Supabase initialisé avec succès');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️ Erreur d\'initialisation Supabase, mode hors-ligne activé');
        // ignore: avoid_print
        print('🔧 Erreur: $e');
      }
      // Marquer comme initialisé pour permettre le mode offline
      _isInitialized = true;
    }
  }

  // Vérifier si Supabase est réellement disponible
  static bool get isOnlineMode =>
      _isInitialized && AppConfig.isSupabaseConfigured;

  // Vérification de la connexion
  static Future<bool> checkConnection() async {
    if (!isOnlineMode) {
      return false;
    }

    try {
      await client.from('rooms').select().limit(1);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('❌ Connexion Supabase échouée: $e');
      }
      return false;
    }
  }

  // === GESTION DES SALONS ===

  /// Créer un nouveau salon dans Supabase
  static Future<void> createRoom(Room room) async {
    if (!_isInitialized) {
      throw SupabaseServiceException(
        'Service Supabase non initialisé',
        type: SupabaseErrorType.connection,
      );
    }

    if (!isOnlineMode) {
      throw SupabaseServiceException(
        'Mode hors-ligne actif. Impossible de créer un salon en ligne.',
        type: SupabaseErrorType.connection,
      );
    }

    try {
      developer.log('🔄 Création du salon ${room.id}', name: 'SupabaseService');

      await client.from('rooms').insert({
        'id': room.id,
        'created_at': room.createdAt.toIso8601String(),
        'expires_at': room.expiresAt.toIso8601String(),
        'status': room.status.name,
        'participant_count': 0,
        'max_participants': AppConfig.maxRoomParticipants,
      }).timeout(AppConfig.connectionTimeout);

      developer.log('✅ Salon ${room.id} créé avec succès',
          name: 'SupabaseService');
    } on TimeoutException {
      throw SupabaseServiceException._fromTimeout();
    } on PostgrestException catch (e) {
      throw SupabaseServiceException._fromPostgrest(e);
    } on SocketException catch (e) {
      throw SupabaseServiceException._fromConnection(e.toString());
    } catch (e) {
      developer.log('❌ Erreur création salon: $e', name: 'SupabaseService');
      throw SupabaseServiceException(
        'Erreur inattendue lors de la création du salon',
        details: e.toString(),
        type: SupabaseErrorType.unknown,
      );
    }
  }

  /// Récupérer un salon par son ID
  static Future<Room?> getRoom(String roomId) async {
    try {
      final response =
          await client.from('rooms').select().eq('id', roomId).single();

      return Room(
        id: response['id'],
        name: response['name'] ?? 'Salon ${response['id']}',
        createdAt: DateTime.parse(response['created_at']),
        expiresAt: DateTime.parse(response['expires_at']),
        status: RoomStatus.values.firstWhere(
          (status) => status.name == response['status'],
          orElse: () => RoomStatus.active,
        ),
        participantCount: response['participant_count'] ?? 0,
        maxParticipants: response['max_participants'] ?? 2,
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
                name: data['name'] ?? 'Salon ${data['id']}',
                createdAt: DateTime.parse(data['created_at']),
                expiresAt: DateTime.parse(data['expires_at']),
                status: RoomStatus.values.firstWhere(
                  (status) => status.name == data['status'],
                  orElse: () => RoomStatus.active,
                ),
                participantCount: data['participant_count'] ?? 0,
                maxParticipants: data['max_participants'] ?? 2,
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
