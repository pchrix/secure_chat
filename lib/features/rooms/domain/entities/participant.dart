/// 👤 Entité Participant - Représentation métier d'un participant de salon
/// 
/// Cette entité représente un participant dans le domaine métier,
/// indépendamment de la source de données ou de la présentation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:equatable/equatable.dart';

/// Rôle d'un participant dans un salon
enum ParticipantRole {
  creator('creator'),
  moderator('moderator'),
  member('member'),
  guest('guest');

  const ParticipantRole(this.value);
  final String value;

  /// Obtient le libellé du rôle
  String get label {
    switch (this) {
      case ParticipantRole.creator:
        return 'Créateur';
      case ParticipantRole.moderator:
        return 'Modérateur';
      case ParticipantRole.member:
        return 'Membre';
      case ParticipantRole.guest:
        return 'Invité';
    }
  }

  /// Obtient l'icône du rôle
  String get icon {
    switch (this) {
      case ParticipantRole.creator:
        return '👑';
      case ParticipantRole.moderator:
        return '🛡️';
      case ParticipantRole.member:
        return '👤';
      case ParticipantRole.guest:
        return '🎭';
    }
  }

  /// Vérifie si le rôle a des permissions d'administration
  bool get hasAdminPermissions {
    return this == ParticipantRole.creator || this == ParticipantRole.moderator;
  }

  /// Vérifie si le rôle peut inviter d'autres participants
  bool get canInvite {
    return hasAdminPermissions || this == ParticipantRole.member;
  }
}

/// Statut d'un participant dans un salon
enum ParticipantStatus {
  invited('invited'),
  joined('joined'),
  active('active'),
  away('away'),
  left('left'),
  kicked('kicked'),
  banned('banned');

  const ParticipantStatus(this.value);
  final String value;

  /// Obtient le libellé du statut
  String get label {
    switch (this) {
      case ParticipantStatus.invited:
        return 'Invité';
      case ParticipantStatus.joined:
        return 'Rejoint';
      case ParticipantStatus.active:
        return 'Actif';
      case ParticipantStatus.away:
        return 'Absent';
      case ParticipantStatus.left:
        return 'Parti';
      case ParticipantStatus.kicked:
        return 'Exclu';
      case ParticipantStatus.banned:
        return 'Banni';
    }
  }

  /// Obtient l'icône du statut
  String get icon {
    switch (this) {
      case ParticipantStatus.invited:
        return '📨';
      case ParticipantStatus.joined:
        return '🚪';
      case ParticipantStatus.active:
        return '🟢';
      case ParticipantStatus.away:
        return '🟡';
      case ParticipantStatus.left:
        return '🚶';
      case ParticipantStatus.kicked:
        return '🚫';
      case ParticipantStatus.banned:
        return '⛔';
    }
  }

  /// Vérifie si le participant est présent dans le salon
  bool get isPresent {
    return this == ParticipantStatus.joined || 
           this == ParticipantStatus.active || 
           this == ParticipantStatus.away;
  }

  /// Vérifie si le participant peut participer aux activités
  bool get canParticipate {
    return this == ParticipantStatus.active;
  }
}

/// Entité représentant un participant de salon
class Participant extends Equatable {
  const Participant({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.joinedAt,
    this.displayName,
    this.avatarUrl,
    this.role = ParticipantRole.guest,
    this.status = ParticipantStatus.invited,
    this.invitedBy,
    this.leftAt,
    this.lastSeenAt,
    this.permissions = const {},
    this.metadata = const {},
    this.isOnline = false,
    this.deviceInfo,
  });

  /// Identifiant unique du participant
  final String id;

  /// Identifiant du salon
  final String roomId;

  /// Identifiant de l'utilisateur
  final String userId;

  /// Nom d'affichage du participant
  final String? displayName;

  /// URL de l'avatar du participant
  final String? avatarUrl;

  /// Rôle du participant dans le salon
  final ParticipantRole role;

  /// Statut du participant
  final ParticipantStatus status;

  /// Date de rejointe du salon
  final DateTime joinedAt;

  /// Identifiant de l'utilisateur qui a invité ce participant
  final String? invitedBy;

  /// Date de départ du salon
  final DateTime? leftAt;

  /// Date de dernière activité
  final DateTime? lastSeenAt;

  /// Permissions spécifiques du participant
  final Map<String, bool> permissions;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Indique si le participant est en ligne
  final bool isOnline;

  /// Informations sur l'appareil du participant
  final Map<String, dynamic>? deviceInfo;

  /// Vérifie si le participant est le créateur du salon
  bool get isCreator => role == ParticipantRole.creator;

  /// Vérifie si le participant est un modérateur
  bool get isModerator => role == ParticipantRole.moderator;

  /// Vérifie si le participant a des permissions d'administration
  bool get hasAdminPermissions => role.hasAdminPermissions;

  /// Vérifie si le participant peut inviter d'autres utilisateurs
  bool get canInvite => role.canInvite;

  /// Vérifie si le participant est présent dans le salon
  bool get isPresent => status.isPresent;

  /// Vérifie si le participant peut participer aux activités
  bool get canParticipate => status.canParticipate;

  /// Vérifie si le participant a quitté le salon
  bool get hasLeft => leftAt != null;

  /// Obtient la durée de présence dans le salon
  Duration get timeInRoom {
    final endTime = leftAt ?? DateTime.now();
    return endTime.difference(joinedAt);
  }

  /// Vérifie si le participant était récemment actif (moins de 5 minutes)
  bool get wasRecentlyActive {
    if (lastSeenAt == null) return false;
    final now = DateTime.now();
    return now.difference(lastSeenAt!).inMinutes < 5;
  }

  /// Obtient le nom d'affichage effectif
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return 'Utilisateur $userId';
  }

  /// Vérifie si le participant a une permission spécifique
  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }

  /// Crée une copie du participant avec des modifications
  Participant copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? displayName,
    String? avatarUrl,
    ParticipantRole? role,
    ParticipantStatus? status,
    DateTime? joinedAt,
    String? invitedBy,
    DateTime? leftAt,
    DateTime? lastSeenAt,
    Map<String, bool>? permissions,
    Map<String, dynamic>? metadata,
    bool? isOnline,
    Map<String, dynamic>? deviceInfo,
  }) {
    return Participant(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
      leftAt: leftAt ?? this.leftAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
      isOnline: isOnline ?? this.isOnline,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  /// Marque le participant comme actif
  Participant markAsActive() {
    return copyWith(
      status: ParticipantStatus.active,
      lastSeenAt: DateTime.now(),
      isOnline: true,
    );
  }

  /// Marque le participant comme absent
  Participant markAsAway() {
    return copyWith(
      status: ParticipantStatus.away,
      lastSeenAt: DateTime.now(),
    );
  }

  /// Marque le participant comme ayant quitté
  Participant markAsLeft() {
    return copyWith(
      status: ParticipantStatus.left,
      leftAt: DateTime.now(),
      isOnline: false,
    );
  }

  /// Marque le participant comme exclu
  Participant markAsKicked() {
    return copyWith(
      status: ParticipantStatus.kicked,
      leftAt: DateTime.now(),
      isOnline: false,
    );
  }

  /// Marque le participant comme banni
  Participant markAsBanned() {
    return copyWith(
      status: ParticipantStatus.banned,
      leftAt: DateTime.now(),
      isOnline: false,
    );
  }

  /// Met à jour l'activité du participant
  Participant updateActivity() {
    return copyWith(
      lastSeenAt: DateTime.now(),
      isOnline: true,
    );
  }

  /// Ajoute une permission au participant
  Participant addPermission(String permission) {
    final newPermissions = Map<String, bool>.from(permissions);
    newPermissions[permission] = true;
    return copyWith(permissions: newPermissions);
  }

  /// Retire une permission du participant
  Participant removePermission(String permission) {
    final newPermissions = Map<String, bool>.from(permissions);
    newPermissions.remove(permission);
    return copyWith(permissions: newPermissions);
  }

  @override
  List<Object?> get props => [
        id,
        roomId,
        userId,
        displayName,
        avatarUrl,
        role,
        status,
        joinedAt,
        invitedBy,
        leftAt,
        lastSeenAt,
        permissions,
        metadata,
        isOnline,
        deviceInfo,
      ];

  @override
  String toString() {
    return 'Participant('
        'id: $id, '
        'userId: $userId, '
        'roomId: $roomId, '
        'role: $role, '
        'status: $status, '
        'displayName: $displayName'
        ')';
  }
}
