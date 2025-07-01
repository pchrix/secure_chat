/// 🏠 Entité Room - Représentation métier d'un salon/room
/// 
/// Cette entité représente un salon dans le domaine métier,
/// indépendamment de la source de données ou de la présentation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:equatable/equatable.dart';

/// Statut d'un salon
enum RoomStatus {
  waiting('waiting'),
  active('active'),
  expired('expired'),
  archived('archived'),
  deleted('deleted');

  const RoomStatus(this.value);
  final String value;

  /// Obtient le libellé du statut
  String get label {
    switch (this) {
      case RoomStatus.waiting:
        return 'En attente';
      case RoomStatus.active:
        return 'Actif';
      case RoomStatus.expired:
        return 'Expiré';
      case RoomStatus.archived:
        return 'Archivé';
      case RoomStatus.deleted:
        return 'Supprimé';
    }
  }

  /// Obtient l'icône du statut
  String get icon {
    switch (this) {
      case RoomStatus.waiting:
        return '⏳';
      case RoomStatus.active:
        return '🟢';
      case RoomStatus.expired:
        return '🔴';
      case RoomStatus.archived:
        return '📦';
      case RoomStatus.deleted:
        return '🗑️';
    }
  }

  /// Vérifie si le statut permet de rejoindre le salon
  bool get allowsJoining {
    return this == RoomStatus.waiting;
  }

  /// Vérifie si le statut permet l'activité
  bool get allowsActivity {
    return this == RoomStatus.active;
  }
}

/// Type de salon
enum RoomType {
  ephemeral('ephemeral'),
  persistent('persistent'),
  private('private'),
  public('public');

  const RoomType(this.value);
  final String value;

  /// Obtient le libellé du type
  String get label {
    switch (this) {
      case RoomType.ephemeral:
        return 'Éphémère';
      case RoomType.persistent:
        return 'Persistant';
      case RoomType.private:
        return 'Privé';
      case RoomType.public:
        return 'Public';
    }
  }
}

/// Entité représentant un salon/room
class Room extends Equatable {
  const Room({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.creatorId,
    this.description,
    this.status = RoomStatus.waiting,
    this.type = RoomType.ephemeral,
    this.expiresAt,
    this.participantCount = 0,
    this.maxParticipants = 2,
    this.encryptionKeyId,
    this.inviteCode,
    this.metadata = const {},
    this.settings = const {},
    this.isArchived = false,
    this.isDeleted = false,
    this.lastActivityAt,
    this.updatedAt,
  });

  /// Identifiant unique du salon
  final String id;

  /// Nom du salon
  final String name;

  /// Description du salon (optionnel)
  final String? description;

  /// Date de création
  final DateTime createdAt;

  /// Identifiant du créateur
  final String creatorId;

  /// Statut du salon
  final RoomStatus status;

  /// Type de salon
  final RoomType type;

  /// Date d'expiration (pour les salons éphémères)
  final DateTime? expiresAt;

  /// Nombre de participants actuels
  final int participantCount;

  /// Nombre maximum de participants
  final int maxParticipants;

  /// Identifiant de la clé de chiffrement
  final String? encryptionKeyId;

  /// Code d'invitation pour rejoindre le salon
  final String? inviteCode;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Paramètres du salon
  final Map<String, dynamic> settings;

  /// Indique si le salon est archivé
  final bool isArchived;

  /// Indique si le salon est supprimé
  final bool isDeleted;

  /// Date de dernière activité
  final DateTime? lastActivityAt;

  /// Date de dernière mise à jour
  final DateTime? updatedAt;

  /// Vérifie si le salon a expiré
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Vérifie si le salon est actif
  bool get isActive => status == RoomStatus.active && !isExpired;

  /// Vérifie si le salon est en attente
  bool get isWaiting => status == RoomStatus.waiting && !isExpired;

  /// Vérifie si le salon est complet (nombre max de participants atteint)
  bool get isFull => participantCount >= maxParticipants;

  /// Vérifie si le salon peut accepter de nouveaux participants
  bool get canJoin => !isFull && status.allowsJoining && !isExpired;

  /// Vérifie si des activités peuvent avoir lieu dans le salon
  bool get allowsActivity => status.allowsActivity && !isExpired;

  /// Vérifie si le salon est chiffré
  bool get isEncrypted => encryptionKeyId != null;

  /// Vérifie si le salon a un code d'invitation
  bool get hasInviteCode => inviteCode != null && inviteCode!.isNotEmpty;

  /// Obtient la durée restante avant expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  /// Obtient la durée depuis la création
  Duration get age => DateTime.now().difference(createdAt);

  /// Vérifie si le salon est récent (moins d'une heure)
  bool get isRecent => age.inHours < 1;

  /// Obtient le pourcentage de remplissage
  double get fillPercentage => participantCount / maxParticipants;

  /// Vérifie si le salon est presque plein (>= 80%)
  bool get isNearlyFull => fillPercentage >= 0.8;

  /// Obtient le nom d'affichage du salon
  String get displayName {
    if (name.isNotEmpty) return name;
    return 'Salon $id';
  }

  /// Crée une copie du salon avec des modifications
  Room copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? creatorId,
    RoomStatus? status,
    RoomType? type,
    DateTime? expiresAt,
    int? participantCount,
    int? maxParticipants,
    String? encryptionKeyId,
    String? inviteCode,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? settings,
    bool? isArchived,
    bool? isDeleted,
    DateTime? lastActivityAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      type: type ?? this.type,
      expiresAt: expiresAt ?? this.expiresAt,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      encryptionKeyId: encryptionKeyId ?? this.encryptionKeyId,
      inviteCode: inviteCode ?? this.inviteCode,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ajoute un participant au salon
  Room addParticipant() {
    return copyWith(
      participantCount: (participantCount + 1).clamp(0, maxParticipants),
      status: participantCount + 1 >= maxParticipants 
          ? RoomStatus.active 
          : status,
      lastActivityAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Retire un participant du salon
  Room removeParticipant() {
    return copyWith(
      participantCount: (participantCount - 1).clamp(0, maxParticipants),
      status: participantCount - 1 < maxParticipants 
          ? RoomStatus.waiting 
          : status,
      lastActivityAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Active le salon
  Room activate() {
    return copyWith(
      status: RoomStatus.active,
      lastActivityAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Expire le salon
  Room expire() {
    return copyWith(
      status: RoomStatus.expired,
      updatedAt: DateTime.now(),
    );
  }

  /// Archive le salon
  Room archive() {
    return copyWith(
      isArchived: true,
      status: RoomStatus.archived,
      updatedAt: DateTime.now(),
    );
  }

  /// Supprime le salon
  Room delete() {
    return copyWith(
      isDeleted: true,
      status: RoomStatus.deleted,
      updatedAt: DateTime.now(),
    );
  }

  /// Met à jour l'activité du salon
  Room updateActivity() {
    return copyWith(
      lastActivityAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        creatorId,
        status,
        type,
        expiresAt,
        participantCount,
        maxParticipants,
        encryptionKeyId,
        inviteCode,
        metadata,
        settings,
        isArchived,
        isDeleted,
        lastActivityAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Room('
        'id: $id, '
        'name: $name, '
        'status: $status, '
        'type: $type, '
        'participantCount: $participantCount/$maxParticipants, '
        'createdAt: $createdAt'
        ')';
  }
}
