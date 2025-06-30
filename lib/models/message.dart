/// 📨 Modèle Message avec Freezed pour SecureChat
///
/// Modèle immutable pour les messages de chat avec chiffrement AES-256.
/// Conforme aux meilleures pratiques Context7 + Exa pour Freezed.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Types de messages supportés dans SecureChat
enum MessageType {
  /// Message texte standard
  text,

  /// Image partagée
  image,

  /// Fichier partagé
  file,

  /// Message système (notifications)
  system,
}

/// Extension pour MessageType avec labels et icônes
extension MessageTypeExtension on MessageType {
  /// Label lisible du type de message
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

  /// Icône associée au type de message
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

/// Modèle immutable Message avec Freezed
@freezed
abstract class Message with _$Message {
  /// Constructeur privé pour méthodes personnalisées
  const Message._();

  /// Factory constructor principal
  const factory Message({
    /// ID unique du message
    required String id,

    /// ID du salon
    required String roomId,

    /// Contenu du message (chiffré)
    required String content,

    /// ID de l'expéditeur
    required String senderId,

    /// Horodatage du message
    required DateTime timestamp,

    /// Type de message
    @Default(MessageType.text) MessageType type,

    /// Indique si le message est chiffré
    @Default(true) bool isEncrypted,

    /// Statut de lecture
    @Default(false) bool isRead,

    /// Métadonnées additionnelles
    @Default({}) Map<String, dynamic> metadata,
  }) = _Message;

  /// Factory constructor pour créer un nouveau message
  factory Message.create({
    required String roomId,
    required String content,
    required String senderId,
    MessageType type = MessageType.text,
    bool isEncrypted = true,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: const Uuid().v4(),
      roomId: roomId,
      content: content,
      senderId: senderId,
      timestamp: DateTime.now(),
      type: type,
      isEncrypted: isEncrypted,
      metadata: metadata ?? {},
    );
  }

  /// Factory pour créer depuis JSON avec mapping personnalisé
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// Méthodes métier personnalisées

  /// Âge du message en minutes
  int get ageInMinutes {
    return DateTime.now().difference(timestamp).inMinutes;
  }

  /// Indique si le message est récent (moins de 5 minutes)
  bool get isRecent {
    return ageInMinutes < 5;
  }

  /// Indique si le message est ancien (plus de 24h)
  bool get isOld {
    return DateTime.now().difference(timestamp).inHours > 24;
  }

  /// Contenu affiché (tronqué si trop long)
  String get displayContent {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }

  /// Indique si le message peut être supprimé
  bool get canBeDeleted {
    return ageInMinutes < 60; // Suppression possible dans l'heure
  }

  /// Marquer le message comme lu
  Message markAsRead() {
    return copyWith(isRead: true);
  }

  /// Marquer le message comme chiffré
  Message markAsEncrypted() {
    return copyWith(isEncrypted: true);
  }

  /// Marquer le message comme déchiffré
  Message markAsDecrypted() {
    return copyWith(isEncrypted: false);
  }

  /// Ajouter des métadonnées
  Message addMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }
}
