import 'dart:convert';
import 'dart:math';

enum RoomStatus {
  waiting, // 0/1 - En attente du partenaire
  active, // 1/1 - Conversation active
  expired, // Salon expiré
}

class Room {
  final String id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final RoomStatus status;
  final int participantCount;
  final String? creatorId;
  final Map<String, dynamic> metadata;

  Room({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.participantCount,
    this.creatorId,
    this.metadata = const {},
  });

  /// Créer un nouveau salon avec ID unique
  factory Room.create({
    String? creatorId,
    int durationHours = 6,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return Room(
      id: _generateRoomId(),
      createdAt: now,
      expiresAt: now.add(Duration(hours: durationHours)),
      status: RoomStatus.waiting,
      participantCount: 0,
      creatorId: creatorId,
      metadata: metadata ?? {},
    );
  }

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
      !isExpired && participantCount < 2 && status == RoomStatus.waiting;

  /// Vérifier si le salon est plein (2/2)
  bool get isFull => participantCount >= 2;

  /// Obtenir le temps restant avant expiration
  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }

  /// Obtenir le statut formaté pour l'affichage
  String get statusDisplay {
    switch (status) {
      case RoomStatus.waiting:
        return '$participantCount/2 - En attente';
      case RoomStatus.active:
        return '2/2 - Connecté';
      case RoomStatus.expired:
        return 'Expiré';
    }
  }

  /// Obtenir l'icône correspondant au statut
  String get statusIcon {
    switch (status) {
      case RoomStatus.waiting:
        return '⏳';
      case RoomStatus.active:
        return '🔐';
      case RoomStatus.expired:
        return '❌';
    }
  }

  /// Créer une copie avec des modifications
  Room copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? expiresAt,
    RoomStatus? status,
    int? participantCount,
    String? creatorId,
    Map<String, dynamic>? metadata,
  }) {
    return Room(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
      creatorId: creatorId ?? this.creatorId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Rejoindre le salon (incrémenter le nombre de participants)
  Room join() {
    if (!canJoin) {
      throw Exception('Cannot join room: ${isExpired ? 'expired' : 'full'}');
    }
    return copyWith(
      participantCount: participantCount + 1,
      status:
          participantCount + 1 >= 2 ? RoomStatus.active : RoomStatus.waiting,
    );
  }

  /// Quitter le salon (décrémenter le nombre de participants)
  Room leave() {
    if (participantCount <= 0) {
      throw Exception('Cannot leave room: no participants');
    }
    return copyWith(
      participantCount: participantCount - 1,
      status: participantCount - 1 < 2 ? RoomStatus.waiting : RoomStatus.active,
    );
  }

  /// Marquer le salon comme expiré
  Room expire() {
    return copyWith(status: RoomStatus.expired);
  }

  /// Sérialiser vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'status': status.index,
      'participantCount': participantCount,
      'creatorId': creatorId,
      'metadata': metadata,
    };
  }

  /// Désérialiser depuis JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt']),
      status: RoomStatus.values[json['status']],
      participantCount: json['participantCount'],
      creatorId: json['creatorId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Sérialiser vers JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Désérialiser depuis JSON string
  factory Room.fromJsonString(String jsonString) {
    return Room.fromJson(jsonDecode(jsonString));
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

  /// Créer un salon depuis un code d'invitation
  static Room? fromInviteCode(String inviteCode) {
    try {
      final decoded = utf8.decode(base64Url.decode(inviteCode));
      final Map<String, dynamic> data = jsonDecode(decoded);

      return Room(
        id: data['roomId'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
        expiresAt: DateTime.fromMillisecondsSinceEpoch(data['expiresAt']),
        status: RoomStatus.waiting,
        participantCount: 0,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Room(id: $id, status: $status, participants: $participantCount, expires: $expiresAt)';
  }
}
