import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
  file,
  system,
}

class Message {
  final String id;
  final String roomId;
  final String content; // Contenu chiffré
  final String senderId;
  final DateTime timestamp;
  final MessageType type;

  Message({
    required this.id,
    required this.roomId,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.type = MessageType.text,
  });

  factory Message.create({
    required String roomId,
    required String content,
    required String senderId,
    MessageType type = MessageType.text,
  }) {
    return Message(
      id: const Uuid().v4(),
      roomId: roomId,
      content: content,
      senderId: senderId,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  // Factory pour créer depuis JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      roomId: json['room_id'] ?? json['roomId'],
      content: json['content'],
      senderId: json['sender_id'] ?? json['senderId'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (type) => type.name == (json['message_type'] ?? json['type']),
        orElse: () => MessageType.text,
      ),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'content': content,
      'sender_id': senderId,
      'timestamp': timestamp.toIso8601String(),
      'message_type': type.name,
    };
  }

  // Copy with method for creating modified copies
  Message copyWith({
    String? roomId,
    String? content,
    String? senderId,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return Message(
      id: id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
