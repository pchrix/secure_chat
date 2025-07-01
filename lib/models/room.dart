/// 🏠 Modèle Room avec Freezed pour SecureChat
///
/// Modèle immutable pour les salons de chat sécurisés avec gestion d'état.
/// Conforme aux meilleures pratiques Context7 + Exa pour Freezed.

import 'dart:convert';
import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// Statuts possibles d'un salon
enum RoomStatus {
  /// En attente de participants (0/1)
  waiting,

  /// Conversation active (2/2)
  active,

  /// Salon expiré
  expired,
}

/// Extension pour RoomStatus avec labels et icônes
extension RoomStatusExtension on RoomStatus {
  /// Label lisible du statut
  String get label {
    switch (this) {
      case RoomStatus.waiting:
        return 'En attente';
      case RoomStatus.active:
        return 'Actif';
      case RoomStatus.expired:
        return 'Expiré';
    }
  }

  /// Icône associée au statut
  String get icon {
    switch (this) {
      case RoomStatus.waiting:
        return '⏳';
      case RoomStatus.active:
        return '🔐';
      case RoomStatus.expired:
        return '❌';
    }
  }

  /// Couleur associée au statut
  String get color {
    switch (this) {
      case RoomStatus.waiting:
        return '#FFA500'; // Orange
      case RoomStatus.active:
        return '#00FF00'; // Vert
      case RoomStatus.expired:
        return '#FF0000'; // Rouge
    }
  }
}

/// Modèle immutable Room avec Freezed
@freezed
abstract class Room with _$Room {
  /// Constructeur privé pour méthodes personnalisées
  const Room._();

  /// Factory constructor principal
  const factory Room({
    /// ID unique du salon
    required String id,

    /// Nom du salon
    required String name,

    /// Date de création
    required DateTime createdAt,

    /// Date d'expiration
    required DateTime expiresAt,

    /// Statut du salon
    required RoomStatus status,

    /// Nombre de participants actuels
    required int participantCount,

    /// Nombre maximum de participants
    @Default(2) int maxParticipants,

    /// ID du créateur
    String? creatorId,

    /// Métadonnées additionnelles
    @Default({}) Map<String, dynamic> metadata,
  }) = _Room;

  /// Créer un nouveau salon avec ID unique
  factory Room.create({
    String? name,
    String? creatorId,
    int durationHours = 6,
    int maxParticipants = 2,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    final roomId = _generateRoomId();
    return Room(
      id: roomId,
      name: name ?? 'Salon $roomId',
      createdAt: now,
      expiresAt: now.add(Duration(hours: durationHours)),
      status: RoomStatus.waiting,
      participantCount: 0,
      maxParticipants: maxParticipants,
      creatorId: creatorId,
      metadata: metadata ?? {},
    );
  }

  /// Factory pour créer depuis JSON avec mapping personnalisé
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  /// Générer un ID unique de 8 caractères alphanumériques
  static String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
          8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Vérifier si le salon est expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Vérifier si le salon peut accepter un nouveau participant
  bool get canJoin =>
      !isExpired &&
      participantCount < maxParticipants &&
      status == RoomStatus.waiting;

  /// Vérifier si le salon est plein (2/2)
  bool get isFull => participantCount >= maxParticipants;

  /// Vérifier si le salon est actif
  bool get isActive => status == RoomStatus.active && !isExpired;

  /// Obtenir le temps restant avant expiration
  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  /// Pourcentage de remplissage du salon
  double get fillPercentage {
    if (maxParticipants == 0) return 0.0;
    return (participantCount / maxParticipants).clamp(0.0, 1.0);
  }

  /// Indique si le salon est presque plein (>= 80%)
  bool get isNearlyFull => fillPercentage >= 0.8;

  /// Obtenir le statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case RoomStatus.waiting:
        return '$participantCount/$maxParticipants - ${status.label}';
      case RoomStatus.active:
        return '$participantCount/$maxParticipants - ${status.label}';
      case RoomStatus.expired:
        return status.label;
    }
  }

  /// Obtenir l'icône correspondant au statut
  String get statusIcon => status.icon;

  /// Rejoindre le salon (incrémenter le nombre de participants)
  Room join() {
    if (!canJoin) {
      throw Exception('Cannot join room: ${isExpired ? 'expired' : 'full'}');
    }
    return copyWith(
      participantCount: participantCount + 1,
      status: participantCount + 1 >= maxParticipants
          ? RoomStatus.active
          : RoomStatus.waiting,
    );
  }

  /// Quitter le salon (décrémenter le nombre de participants)
  Room leave() {
    if (participantCount <= 0) {
      throw Exception('Cannot leave room: no participants');
    }
    return copyWith(
      participantCount: participantCount - 1,
      status: participantCount - 1 < maxParticipants
          ? RoomStatus.waiting
          : RoomStatus.active,
    );
  }

  /// Marquer le salon comme expiré
  Room expire() {
    return copyWith(status: RoomStatus.expired);
  }

  /// Activer le salon
  Room activate() {
    return copyWith(status: RoomStatus.active);
  }

  /// Ajouter un participant
  Room addParticipant() {
    if (isFull) {
      throw Exception('Room is already full');
    }
    final newCount = participantCount + 1;
    return copyWith(
      participantCount: newCount,
      status:
          newCount >= maxParticipants ? RoomStatus.active : RoomStatus.waiting,
    );
  }

  /// Supprimer un participant
  Room removeParticipant() {
    if (participantCount <= 0) {
      throw Exception('No participants to remove');
    }
    final newCount = participantCount - 1;
    return copyWith(
      participantCount: newCount,
      status:
          newCount < maxParticipants ? RoomStatus.waiting : RoomStatus.active,
    );
  }

  /// Ajouter des métadonnées
  Room addMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  /// Générer un code d'invitation partageable
  String generateInviteCode() {
    final inviteData = {
      'roomId': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
    return base64Url.encode(utf8.encode(jsonEncode(inviteData)));
  }

  /// Sérialiser vers JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Désérialiser depuis JSON string
  factory Room.fromJsonString(String jsonString) {
    return Room.fromJson(jsonDecode(jsonString));
  }

  /// Créer un salon depuis un code d'invitation
  static Room? fromInviteCode(String inviteCode) {
    try {
      final decoded = utf8.decode(base64Url.decode(inviteCode));
      final Map<String, dynamic> data = jsonDecode(decoded);

      return Room(
        id: data['roomId'],
        name: 'Salon ${data['roomId']}',
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(data['expiresAt']),
        status: RoomStatus.waiting,
        participantCount: 0,
        maxParticipants: 2,
      );
    } catch (e) {
      return null;
    }
  }
}
