/// 💬 Interface ChatRepository - Contrat pour l'accès aux données de chat
/// 
/// Cette interface définit les opérations disponibles pour la gestion des messages
/// et conversations, indépendamment de l'implémentation (Supabase, local, etc.).
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../entities/conversation.dart';

/// Interface abstraite pour l'accès aux données de chat
abstract class ChatRepository {
  // ========== GESTION DES CONVERSATIONS ==========

  /// Récupère toutes les conversations de l'utilisateur
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Récupère une conversation par son ID
  Future<Either<Failure, Conversation?>> getConversation(String conversationId);

  /// Crée une nouvelle conversation
  Future<Either<Failure, Conversation>> createConversation({
    required String creatorId,
    String? name,
    String? description,
    ConversationType type = ConversationType.ephemeral,
    int maxParticipants = 2,
    int? durationHours,
    Map<String, dynamic>? metadata,
  });

  /// Rejoint une conversation existante
  Future<Either<Failure, Conversation>> joinConversation({
    required String conversationId,
    required String userId,
  });

  /// Quitte une conversation
  Future<Either<Failure, void>> leaveConversation({
    required String conversationId,
    required String userId,
  });

  /// Met à jour une conversation
  Future<Either<Failure, Conversation>> updateConversation({
    required String conversationId,
    String? name,
    String? description,
    ConversationStatus? status,
    Map<String, dynamic>? metadata,
  });

  /// Archive une conversation
  Future<Either<Failure, void>> archiveConversation(String conversationId);

  /// Supprime une conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Écoute les changements de conversations
  Stream<Either<Failure, List<Conversation>>> watchConversations();

  /// Écoute les changements d'une conversation spécifique
  Stream<Either<Failure, Conversation?>> watchConversation(String conversationId);

  // ========== GESTION DES MESSAGES ==========

  /// Récupère les messages d'une conversation
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int? limit,
    String? beforeMessageId,
    String? afterMessageId,
  });

  /// Récupère un message par son ID
  Future<Either<Failure, Message?>> getMessage(String messageId);

  /// Envoie un nouveau message
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    Map<String, dynamic>? metadata,
  });

  /// Met à jour un message existant
  Future<Either<Failure, Message>> updateMessage({
    required String messageId,
    required String content,
    Map<String, dynamic>? metadata,
  });

  /// Supprime un message
  Future<Either<Failure, void>> deleteMessage(String messageId);

  /// Marque un message comme lu
  Future<Either<Failure, void>> markMessageAsRead({
    required String messageId,
    required String userId,
  });

  /// Marque tous les messages d'une conversation comme lus
  Future<Either<Failure, void>> markConversationAsRead({
    required String conversationId,
    required String userId,
  });

  /// Écoute les nouveaux messages d'une conversation
  Stream<Either<Failure, List<Message>>> watchMessages(String conversationId);

  /// Écoute les changements d'un message spécifique
  Stream<Either<Failure, Message?>> watchMessage(String messageId);

  // ========== GESTION DU CHIFFREMENT ==========

  /// Chiffre un message
  Future<Either<Failure, String>> encryptMessage({
    required String conversationId,
    required String content,
  });

  /// Déchiffre un message
  Future<Either<Failure, String>> decryptMessage({
    required String conversationId,
    required String encryptedContent,
  });

  /// Génère une clé de chiffrement pour une conversation
  Future<Either<Failure, String>> generateEncryptionKey(String conversationId);

  /// Récupère la clé de chiffrement d'une conversation
  Future<Either<Failure, String?>> getEncryptionKey(String conversationId);

  /// Supprime la clé de chiffrement d'une conversation
  Future<Either<Failure, void>> deleteEncryptionKey(String conversationId);

  // ========== GESTION DES PARTICIPANTS ==========

  /// Récupère les participants d'une conversation
  Future<Either<Failure, List<String>>> getParticipants(String conversationId);

  /// Ajoute un participant à une conversation
  Future<Either<Failure, void>> addParticipant({
    required String conversationId,
    required String userId,
  });

  /// Retire un participant d'une conversation
  Future<Either<Failure, void>> removeParticipant({
    required String conversationId,
    required String userId,
  });

  /// Vérifie si un utilisateur est participant d'une conversation
  Future<Either<Failure, bool>> isParticipant({
    required String conversationId,
    required String userId,
  });

  // ========== RECHERCHE ET FILTRAGE ==========

  /// Recherche des conversations par nom ou description
  Future<Either<Failure, List<Conversation>>> searchConversations({
    required String query,
    ConversationType? type,
    ConversationStatus? status,
    int? limit,
  });

  /// Recherche des messages par contenu
  Future<Either<Failure, List<Message>>> searchMessages({
    required String query,
    String? conversationId,
    MessageType? type,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });

  /// Récupère les conversations récentes
  Future<Either<Failure, List<Conversation>>> getRecentConversations({
    int limit = 20,
  });

  /// Récupère les conversations archivées
  Future<Either<Failure, List<Conversation>>> getArchivedConversations();

  // ========== STATISTIQUES ET MÉTADONNÉES ==========

  /// Récupère le nombre de messages non lus
  Future<Either<Failure, int>> getUnreadMessageCount({
    String? conversationId,
  });

  /// Récupère les statistiques d'une conversation
  Future<Either<Failure, Map<String, dynamic>>> getConversationStats(
    String conversationId,
  );

  /// Nettoie les conversations expirées
  Future<Either<Failure, int>> cleanupExpiredConversations();

  /// Synchronise les données avec le serveur
  Future<Either<Failure, void>> syncData();

  // ========== GESTION HORS LIGNE ==========

  /// Vérifie si le repository est en mode hors ligne
  bool get isOffline;

  /// Active/désactive le mode hors ligne
  Future<Either<Failure, void>> setOfflineMode(bool enabled);

  /// Récupère les messages en attente de synchronisation
  Future<Either<Failure, List<Message>>> getPendingMessages();

  /// Marque un message comme synchronisé
  Future<Either<Failure, void>> markMessageAsSynced(String messageId);
}
