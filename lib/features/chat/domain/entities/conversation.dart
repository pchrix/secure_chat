/// 💬 Entité Conversation - Représentation métier d'une conversation/salon
/// 
/// Cette entité représente une conversation dans le domaine métier,
/// indépendamment de la source de données ou de la présentation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:equatable/equatable.dart';

/// Statut d'une conversation
enum ConversationStatus {
  waiting('waiting'),
  active('active'),
  expired('expired'),
  archived('archived'),
  deleted('deleted');

  const ConversationStatus(this.value);
  final String value;

  /// Obtient le libellé du statut
  String get label {
    switch (this) {
      case ConversationStatus.waiting:
        return 'En attente';
      case ConversationStatus.active:
        return 'Active';
      case ConversationStatus.expired:
        return 'Expirée';
      case ConversationStatus.archived:
        return 'Archivée';
      case ConversationStatus.deleted:
        return 'Supprimée';
    }
  }

  /// Obtient l'icône du statut
  String get icon {
    switch (this) {
      case ConversationStatus.waiting:
        return '⏳';
      case ConversationStatus.active:
        return '🟢';
      case ConversationStatus.expired:
        return '🔴';
      case ConversationStatus.archived:
        return '📦';
      case ConversationStatus.deleted:
        return '🗑️';
    }
  }

  /// Vérifie si le statut permet l'envoi de messages
  bool get allowsMessaging {
    return this == ConversationStatus.active;
  }
}

/// Type de conversation
enum ConversationType {
  ephemeral('ephemeral'),
  persistent('persistent'),
  group('group'),
  direct('direct');

  const ConversationType(this.value);
  final String value;

  /// Obtient le libellé du type
  String get label {
    switch (this) {
      case ConversationType.ephemeral:
        return 'Éphémère';
      case ConversationType.persistent:
        return 'Persistante';
      case ConversationType.group:
        return 'Groupe';
      case ConversationType.direct:
        return 'Directe';
    }
  }
}

/// Entité représentant une conversation/salon de chat
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.createdAt,
    required this.creatorId,
    this.name,
    this.description,
    this.status = ConversationStatus.waiting,
    this.type = ConversationType.ephemeral,
    this.expiresAt,
    this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.participantCount = 0,
    this.maxParticipants = 2,
    this.unreadCount = 0,
    this.encryptionKeyId,
    this.metadata = const {},
    this.settings = const {},
    this.isArchived = false,
    this.isDeleted = false,
    this.updatedAt,
  });

  /// Identifiant unique de la conversation
  final String id;

  /// Date de création
  final DateTime createdAt;

  /// Identifiant du créateur
  final String creatorId;

  /// Nom de la conversation (optionnel)
  final String? name;

  /// Description de la conversation (optionnel)
  final String? description;

  /// Statut de la conversation
  final ConversationStatus status;

  /// Type de conversation
  final ConversationType type;

  /// Date d'expiration (pour les conversations éphémères)
  final DateTime? expiresAt;

  /// Date du dernier message
  final DateTime? lastMessageAt;

  /// Contenu du dernier message
  final String? lastMessageContent;

  /// Expéditeur du dernier message
  final String? lastMessageSenderId;

  /// Nombre de participants
  final int participantCount;

  /// Nombre maximum de participants
  final int maxParticipants;

  /// Nombre de messages non lus
  final int unreadCount;

  /// Identifiant de la clé de chiffrement
  final String? encryptionKeyId;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Paramètres de la conversation
  final Map<String, dynamic> settings;

  /// Indique si la conversation est archivée
  final bool isArchived;

  /// Indique si la conversation est supprimée
  final bool isDeleted;

  /// Date de dernière mise à jour
  final DateTime? updatedAt;

  /// Vérifie si la conversation a expiré
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Vérifie si la conversation est active
  bool get isActive => status == ConversationStatus.active && !isExpired;

  /// Vérifie si la conversation est complète (nombre max de participants atteint)
  bool get isFull => participantCount >= maxParticipants;

  /// Vérifie si la conversation peut accepter de nouveaux participants
  bool get canAcceptParticipants => !isFull && isActive;

  /// Vérifie si des messages peuvent être envoyés
  bool get allowsMessaging => status.allowsMessaging && !isExpired;

  /// Vérifie si la conversation a des messages non lus
  bool get hasUnreadMessages => unreadCount > 0;

  /// Vérifie si la conversation est chiffrée
  bool get isEncrypted => encryptionKeyId != null;

  /// Obtient le nom d'affichage de la conversation
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (type == ConversationType.ephemeral) return 'Salon éphémère';
    return 'Conversation $id';
  }

  /// Obtient la durée restante avant expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  /// Obtient la durée depuis la création
  Duration get age => DateTime.now().difference(createdAt);

  /// Vérifie si la conversation est récente (moins d'une heure)
  bool get isRecent => age.inHours < 1;

  /// Crée une copie de la conversation avec des modifications
  Conversation copyWith({
    String? id,
    DateTime? createdAt,
    String? creatorId,
    String? name,
    String? description,
    ConversationStatus? status,
    ConversationType? type,
    DateTime? expiresAt,
    DateTime? lastMessageAt,
    String? lastMessageContent,
    String? lastMessageSenderId,
    int? participantCount,
    int? maxParticipants,
    int? unreadCount,
    String? encryptionKeyId,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
    bool? isArchived,
    bool? isDeleted,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      expiresAt: expiresAt ?? this.expiresAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      unreadCount: unreadCount ?? this.unreadCount,
      encryptionKeyId: encryptionKeyId ?? this.encryptionKeyId,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ajoute un participant à la conversation
  Conversation addParticipant() {
    return copyWith(
      participantCount: participantCount + 1,
      status: participantCount + 1 >= maxParticipants 
          ? ConversationStatus.active 
          : status,
      updatedAt: DateTime.now(),
    );
  }

  /// Retire un participant de la conversation
  Conversation removeParticipant() {
    return copyWith(
      participantCount: (participantCount - 1).clamp(0, maxParticipants),
      updatedAt: DateTime.now(),
    );
  }

  /// Met à jour le dernier message
  Conversation updateLastMessage({
    required String content,
    required String senderId,
    DateTime? timestamp,
  }) {
    return copyWith(
      lastMessageAt: timestamp ?? DateTime.now(),
      lastMessageContent: content,
      lastMessageSenderId: senderId,
      updatedAt: DateTime.now(),
    );
  }

  /// Marque les messages comme lus
  Conversation markAsRead() {
    return copyWith(
      unreadCount: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Incrémente le nombre de messages non lus
  Conversation incrementUnreadCount() {
    return copyWith(
      unreadCount: unreadCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// Archive la conversation
  Conversation archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Supprime la conversation
  Conversation delete() {
    return copyWith(
      isDeleted: true,
      status: ConversationStatus.deleted,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        creatorId,
        name,
        description,
        status,
        type,
        expiresAt,
        lastMessageAt,
        lastMessageContent,
        lastMessageSenderId,
        participantCount,
        maxParticipants,
        unreadCount,
        encryptionKeyId,
        metadata,
        settings,
        isArchived,
        isDeleted,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Conversation('
        'id: $id, '
        'name: $name, '
        'status: $status, '
        'type: $type, '
        'participantCount: $participantCount, '
        'createdAt: $createdAt'
        ')';
  }
}
