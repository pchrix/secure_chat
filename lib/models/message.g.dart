// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'content': instance.content,
      'senderId': instance.senderId,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$MessageTypeEnumMap[instance.type]!,
      'isEncrypted': instance.isEncrypted,
      'isRead': instance.isRead,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.file: 'file',
  MessageType.system: 'system',
};
