/// 💬 Entité Message - Représentation métier d'un message
/// 
/// Cette entité représente un message dans le domaine métier,
/// indépendamment de la source de données ou de la présentation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:equatable/equatable.dart';

/// Types de messages supportés
enum MessageType {
  text('text'),
  image('image'),
  file('file'),
  system('system');

  const MessageType(this.value);
  final String value;

  /// Obtient le libellé du type de message
  String get label {
    switch (this) {
      case MessageType.text:
        return 'Texte';
      case MessageType.image:
        return 'Image';
      case MessageType.file:
        return 'Fichier';
      case MessageType.system:
        return 'Système';
    }
  }

  /// Obtient l'icône associée au type
  String get icon {
    switch (this) {
      case MessageType.text:
        return '💬';
      case MessageType.image:
        return '🖼️';
      case MessageType.file:
        return '📎';
      case MessageType.system:
        return '⚙️';
    }
  }
}

/// Statut de chiffrement d'un message
enum EncryptionStatus {
  none('none'),
  encrypted('encrypted'),
  decrypted('decrypted'),
  failed('failed');

  const EncryptionStatus(this.value);
  final String value;

  /// Obtient le libellé du statut
  String get label {
    switch (this) {
      case EncryptionStatus.none:
        return 'Non chiffré';
      case EncryptionStatus.encrypted:
        return 'Chiffré';
      case EncryptionStatus.decrypted:
        return 'Déchiffré';
      case EncryptionStatus.failed:
        return 'Erreur chiffrement';
    }
  }

  /// Obtient l'icône du statut
  String get icon {
    switch (this) {
      case EncryptionStatus.none:
        return '🔓';
      case EncryptionStatus.encrypted:
        return '🔒';
      case EncryptionStatus.decrypted:
        return '🔓';
      case EncryptionStatus.failed:
        return '❌';
    }
  }
}

/// Entité représentant un message de chat
class Message extends Equatable {
  const Message({
    required this.id,
    required this.roomId,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.createdAt,
    this.type = MessageType.text,
    this.encryptionStatus = EncryptionStatus.none,
    this.originalContent,
    this.metadata = const {},
    this.replyToId,
    this.editedAt,
    this.isDeleted = false,
    this.deliveredAt,
    this.readAt,
  });

  /// Identifiant unique du message
  final String id;

  /// Identifiant du salon/conversation
  final String roomId;

  /// Contenu du message (peut être chiffré)
  final String content;

  /// Identifiant de l'expéditeur
  final String senderId;

  /// Horodatage du message
  final DateTime timestamp;

  /// Date de création
  final DateTime createdAt;

  /// Type de message
  final MessageType type;

  /// Statut de chiffrement
  final EncryptionStatus encryptionStatus;

  /// Contenu original avant chiffrement (optionnel)
  final String? originalContent;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// ID du message auquel ce message répond
  final String? replyToId;

  /// Date de dernière modification
  final DateTime? editedAt;

  /// Indique si le message est supprimé
  final bool isDeleted;

  /// Date de livraison
  final DateTime? deliveredAt;

  /// Date de lecture
  final DateTime? readAt;

  /// Vérifie si le message est chiffré
  bool get isEncrypted => encryptionStatus == EncryptionStatus.encrypted;

  /// Vérifie si le message est déchiffré
  bool get isDecrypted => encryptionStatus == EncryptionStatus.decrypted;

  /// Vérifie si le message a été modifié
  bool get isEdited => editedAt != null;

  /// Vérifie si le message a été livré
  bool get isDelivered => deliveredAt != null;

  /// Vérifie si le message a été lu
  bool get isRead => readAt != null;

  /// Vérifie si c'est une réponse à un autre message
  bool get isReply => replyToId != null;

  /// Obtient le contenu à afficher (déchiffré si possible, sinon chiffré)
  String get displayContent {
    if (isDeleted) return '[Message supprimé]';
    if (isDecrypted && originalContent != null) return originalContent!;
    return content;
  }

  /// Obtient la durée depuis l'envoi
  Duration get age => DateTime.now().difference(timestamp);

  /// Vérifie si le message est récent (moins de 5 minutes)
  bool get isRecent => age.inMinutes < 5;

  /// Crée une copie du message avec des modifications
  Message copyWith({
    String? id,
    String? roomId,
    String? content,
    String? senderId,
    DateTime? timestamp,
    DateTime? createdAt,
    MessageType? type,
    EncryptionStatus? encryptionStatus,
    String? originalContent,
    Map<String, dynamic>? metadata,
    String? replyToId,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      encryptionStatus: encryptionStatus ?? this.encryptionStatus,
      originalContent: originalContent ?? this.originalContent,
      metadata: metadata ?? this.metadata,
      replyToId: replyToId ?? this.replyToId,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Marque le message comme chiffré
  Message markAsEncrypted(String encryptedContent) {
    return copyWith(
      content: encryptedContent,
      encryptionStatus: EncryptionStatus.encrypted,
    );
  }

  /// Marque le message comme déchiffré
  Message markAsDecrypted(String decryptedContent) {
    return copyWith(
      originalContent: decryptedContent,
      encryptionStatus: EncryptionStatus.decrypted,
    );
  }

  /// Marque le message comme livré
  Message markAsDelivered() {
    return copyWith(deliveredAt: DateTime.now());
  }

  /// Marque le message comme lu
  Message markAsRead() {
    return copyWith(readAt: DateTime.now());
  }

  /// Marque le message comme supprimé
  Message markAsDeleted() {
    return copyWith(
      isDeleted: true,
      editedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        content,
        senderId,
        timestamp,
        createdAt,
        type,
        encryptionStatus,
        originalContent,
        metadata,
        replyToId,
        editedAt,
        isDeleted,
        deliveredAt,
        readAt,
      ];

  @override
  String toString() {
    return 'Message('
        'id: $id, '
        'roomId: $roomId, '
        'senderId: $senderId, '
        'type: $type, '
        'encryptionStatus: $encryptionStatus, '
        'timestamp: $timestamp'
        ')';
  }
}
