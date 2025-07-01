/// 🏠 Interface RoomRepository - Contrat pour l'accès aux données de salons
/// 
/// Cette interface définit les opérations disponibles pour la gestion des salons
/// et participants, indépendamment de l'implémentation (Supabase, local, etc.).
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/room.dart';
import '../entities/participant.dart';

/// Interface abstraite pour l'accès aux données de salons
abstract class RoomRepository {
  // ========== GESTION DES SALONS ==========

  /// Récupère tous les salons de l'utilisateur
  Future<Either<Failure, List<Room>>> getRooms();

  /// Récupère un salon par son ID
  Future<Either<Failure, Room?>> getRoom(String roomId);

  /// Crée un nouveau salon
  Future<Either<Failure, Room>> createRoom({
    required String creatorId,
    required String name,
    String? description,
    RoomType type = RoomType.ephemeral,
    int maxParticipants = 2,
    int? durationHours,
    bool enableEncryption = true,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
  });

  /// Met à jour un salon
  Future<Either<Failure, Room>> updateRoom({
    required String roomId,
    String? name,
    String? description,
    RoomStatus? status,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
  });

  /// Supprime un salon
  Future<Either<Failure, void>> deleteRoom(String roomId);

  /// Archive un salon
  Future<Either<Failure, void>> archiveRoom(String roomId);

  /// Expire un salon
  Future<Either<Failure, void>> expireRoom(String roomId);

  /// Génère un code d'invitation pour un salon
  Future<Either<Failure, String>> generateInviteCode(String roomId);

  /// Valide un code d'invitation
  Future<Either<Failure, Room?>> validateInviteCode(String inviteCode);

  /// Écoute les changements de salons
  Stream<Either<Failure, List<Room>>> watchRooms();

  /// Écoute les changements d'un salon spécifique
  Stream<Either<Failure, Room?>> watchRoom(String roomId);

  // ========== GESTION DES PARTICIPANTS ==========

  /// Récupère les participants d'un salon
  Future<Either<Failure, List<Participant>>> getParticipants(String roomId);

  /// Récupère un participant par son ID
  Future<Either<Failure, Participant?>> getParticipant({
    required String roomId,
    required String userId,
  });

  /// Ajoute un participant à un salon
  Future<Either<Failure, Participant>> addParticipant({
    required String roomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
    ParticipantRole role = ParticipantRole.guest,
    String? invitedBy,
    Map<String, bool>? permissions,
    Map<String, dynamic>? metadata,
  });

  /// Met à jour un participant
  Future<Either<Failure, Participant>> updateParticipant({
    required String roomId,
    required String userId,
    String? displayName,
    String? avatarUrl,
    ParticipantRole? role,
    ParticipantStatus? status,
    Map<String, bool>? permissions,
    Map<String, dynamic>? metadata,
  });

  /// Retire un participant d'un salon
  Future<Either<Failure, void>> removeParticipant({
    required String roomId,
    required String userId,
  });

  /// Exclut un participant d'un salon
  Future<Either<Failure, void>> kickParticipant({
    required String roomId,
    required String userId,
    required String kickedBy,
    String? reason,
  });

  /// Bannit un participant d'un salon
  Future<Either<Failure, void>> banParticipant({
    required String roomId,
    required String userId,
    required String bannedBy,
    String? reason,
    DateTime? bannedUntil,
  });

  /// Vérifie si un utilisateur est participant d'un salon
  Future<Either<Failure, bool>> isParticipant({
    required String roomId,
    required String userId,
  });

  /// Met à jour le statut en ligne d'un participant
  Future<Either<Failure, void>> updateParticipantOnlineStatus({
    required String roomId,
    required String userId,
    required bool isOnline,
  });

  /// Met à jour l'activité d'un participant
  Future<Either<Failure, void>> updateParticipantActivity({
    required String roomId,
    required String userId,
  });

  /// Écoute les changements de participants d'un salon
  Stream<Either<Failure, List<Participant>>> watchParticipants(String roomId);

  /// Écoute les changements d'un participant spécifique
  Stream<Either<Failure, Participant?>> watchParticipant({
    required String roomId,
    required String userId,
  });

  // ========== GESTION DU CHIFFREMENT ==========

  /// Génère une clé de chiffrement pour un salon
  Future<Either<Failure, String>> generateEncryptionKey(String roomId);

  /// Récupère la clé de chiffrement d'un salon
  Future<Either<Failure, String?>> getEncryptionKey(String roomId);

  /// Partage la clé de chiffrement avec un participant
  Future<Either<Failure, void>> shareEncryptionKey({
    required String roomId,
    required String userId,
    required String encryptionKey,
  });

  /// Supprime la clé de chiffrement d'un salon
  Future<Either<Failure, void>> deleteEncryptionKey(String roomId);

  // ========== RECHERCHE ET FILTRAGE ==========

  /// Recherche des salons par nom ou description
  Future<Either<Failure, List<Room>>> searchRooms({
    required String query,
    RoomType? type,
    RoomStatus? status,
    int? limit,
  });

  /// Récupère les salons récents
  Future<Either<Failure, List<Room>>> getRecentRooms({
    int limit = 20,
  });

  /// Récupère les salons actifs
  Future<Either<Failure, List<Room>>> getActiveRooms();

  /// Récupère les salons en attente
  Future<Either<Failure, List<Room>>> getWaitingRooms();

  /// Récupère les salons archivés
  Future<Either<Failure, List<Room>>> getArchivedRooms();

  /// Récupère les salons créés par un utilisateur
  Future<Either<Failure, List<Room>>> getRoomsByCreator(String creatorId);

  // ========== STATISTIQUES ET MÉTADONNÉES ==========

  /// Récupère les statistiques d'un salon
  Future<Either<Failure, Map<String, dynamic>>> getRoomStats(String roomId);

  /// Récupère le nombre de participants d'un salon
  Future<Either<Failure, int>> getParticipantCount(String roomId);

  /// Récupère l'historique d'activité d'un salon
  Future<Either<Failure, List<Map<String, dynamic>>>> getRoomActivity({
    required String roomId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });

  /// Nettoie les salons expirés
  Future<Either<Failure, int>> cleanupExpiredRooms();

  /// Synchronise les données avec le serveur
  Future<Either<Failure, void>> syncData();

  // ========== GESTION HORS LIGNE ==========

  /// Vérifie si le repository est en mode hors ligne
  bool get isOffline;

  /// Active/désactive le mode hors ligne
  Future<Either<Failure, void>> setOfflineMode(bool enabled);

  /// Récupère les salons en attente de synchronisation
  Future<Either<Failure, List<Room>>> getPendingRooms();

  /// Marque un salon comme synchronisé
  Future<Either<Failure, void>> markRoomAsSynced(String roomId);

  // ========== INVITATIONS ==========

  /// Envoie une invitation à rejoindre un salon
  Future<Either<Failure, void>> sendInvitation({
    required String roomId,
    required String invitedUserId,
    required String invitedBy,
    String? message,
  });

  /// Accepte une invitation à rejoindre un salon
  Future<Either<Failure, Room>> acceptInvitation({
    required String roomId,
    required String userId,
  });

  /// Refuse une invitation à rejoindre un salon
  Future<Either<Failure, void>> declineInvitation({
    required String roomId,
    required String userId,
  });

  /// Récupère les invitations en attente pour un utilisateur
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingInvitations(
    String userId,
  );
}
