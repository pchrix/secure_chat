import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String text;
  final bool isEncrypted;
  final DateTime timestamp;
  final String? contactId; // If null, it's a draft or outgoing message

  Message({
    required this.id,
    required this.text,
    required this.isEncrypted,
    required this.timestamp,
    this.contactId,
  });
  
  factory Message.create({
    required String text,
    required bool isEncrypted,
    String? contactId,
  }) {
    return Message(
      id: const Uuid().v4(),
      text: text,
      isEncrypted: isEncrypted,
      timestamp: DateTime.now(),
      contactId: contactId,
    );
  }
  
  // Copy with method for creating modified copies
  Message copyWith({
    String? text,
    bool? isEncrypted,
    String? contactId,
  }) {
    return Message(
      id: id,
      text: text ?? this.text,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      timestamp: timestamp,
      contactId: contactId ?? this.contactId,
    );
  }
}