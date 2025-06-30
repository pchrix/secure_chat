// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: $enumDecode(_$RoomStatusEnumMap, json['status']),
      participantCount: (json['participantCount'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 2,
      creatorId: json['creatorId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'status': _$RoomStatusEnumMap[instance.status]!,
      'participantCount': instance.participantCount,
      'maxParticipants': instance.maxParticipants,
      'creatorId': instance.creatorId,
      'metadata': instance.metadata,
    };

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.active: 'active',
  RoomStatus.expired: 'expired',
};
