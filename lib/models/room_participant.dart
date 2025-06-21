import 'dart:convert';

enum ParticipantRole {
  creator,  // Créateur du salon
  guest,    // Invité
}

enum ParticipantStatus {
  invited,   // Invité mais pas encore connecté
  connected, // Connecté et actif
  left,      // A quitté le salon
}

class RoomParticipant {
  final String id;
  final String roomId;
  final String? userId;
  final String? displayName;
  final ParticipantRole role;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final Map<String, dynamic> metadata;

  RoomParticipant({
    required this.id,
    required this.roomId,
    this.userId,
    this.displayName,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.leftAt,
    this.metadata = const {},
  });

  /// Créer un nouveau participant créateur
  factory RoomParticipant.creator({
    required String id,
    required String roomId,
    String? userId,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) {
    return RoomParticipant(
      id: id,
      roomId: roomId,
      userId: userId,
      displayName: displayName,
      role: ParticipantRole.creator,
      status: ParticipantStatus.connected,
      joinedAt: DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  /// Créer un nouveau participant invité
  factory RoomParticipant.guest({
    required String id,
    required String roomId,
    String? userId,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) {
    return RoomParticipant(
      id: id,
      roomId: roomId,
      userId: userId,
      displayName: displayName,
      role: ParticipantRole.guest,
      status: ParticipantStatus.invited,
      joinedAt: DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  /// Vérifier si le participant est actif
  bool get isActive => status == ParticipantStatus.connected;

  /// Vérifier si le participant est le créateur
  bool get isCreator => role == ParticipantRole.creator;

  /// Vérifier si le participant est un invité
  bool get isGuest => role == ParticipantRole.guest;

  /// Obtenir le nom d'affichage ou un nom par défaut
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return isCreator ? 'Créateur' : 'Invité';
  }

  /// Obtenir le statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case ParticipantStatus.invited:
        return 'Invité';
      case ParticipantStatus.connected:
        return 'Connecté';
      case ParticipantStatus.left:
        return 'Parti';
    }
  }

  /// Obtenir l'icône correspondant au rôle
  String get roleIcon {
    switch (role) {
      case ParticipantRole.creator:
        return '👑';
      case ParticipantRole.guest:
        return '👤';
    }
  }

  /// Obtenir l'icône correspondant au statut
  String get statusIcon {
    switch (status) {
      case ParticipantStatus.invited:
        return '📨';
      case ParticipantStatus.connected:
        return '🟢';
      case ParticipantStatus.left:
        return '🔴';
    }
  }

  /// Créer une copie avec des modifications
  RoomParticipant copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? displayName,
    ParticipantRole? role,
    ParticipantStatus? status,
    DateTime? joinedAt,
    DateTime? leftAt,
    Map<String, dynamic>? metadata,
  }) {
    return RoomParticipant(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marquer le participant comme connecté
  RoomParticipant connect() {
    return copyWith(
      status: ParticipantStatus.connected,
      leftAt: null,
    );
  }

  /// Marquer le participant comme ayant quitté
  RoomParticipant leave() {
    return copyWith(
      status: ParticipantStatus.left,
      leftAt: DateTime.now(),
    );
  }

  /// Sérialiser vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'displayName': displayName,
      'role': role.index,
      'status': status.index,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'leftAt': leftAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// Désérialiser depuis JSON
  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      id: json['id'],
      roomId: json['roomId'],
      userId: json['userId'],
      displayName: json['displayName'],
      role: ParticipantRole.values[json['role']],
      status: ParticipantStatus.values[json['status']],
      joinedAt: DateTime.fromMillisecondsSinceEpoch(json['joinedAt']),
      leftAt: json['leftAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['leftAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Sérialiser vers JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Désérialiser depuis JSON string
  factory RoomParticipant.fromJsonString(String jsonString) {
    return RoomParticipant.fromJson(jsonDecode(jsonString));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomParticipant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomParticipant(id: $id, roomId: $roomId, role: $role, status: $status)';
  }
}
