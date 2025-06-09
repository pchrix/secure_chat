import 'dart:convert';
import 'package:uuid/uuid.dart';

class Contact {
  final String id;
  final String name;
  final String publicKey; // For demonstration - in a real app, this would be actual crypto keys
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.createdAt
  });
  
  factory Contact.create(String name, String publicKey) {
    return Contact(
      id: const Uuid().v4(),
      name: name,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
  }
  
  // Generate a shareable code that contains the contact info
  String generateShareCode() {
    final Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'key': publicKey,
      'created': createdAt.millisecondsSinceEpoch
    };
    return base64Encode(utf8.encode(jsonEncode(map)));
  }
  
  // Create a contact from a share code
  static Contact? fromShareCode(String shareCode) {
    try {
      final decodedJson = utf8.decode(base64Decode(shareCode));
      final Map<String, dynamic> map = jsonDecode(decodedJson);
      
      return Contact(
        id: map['id'],
        name: map['name'],
        publicKey: map['key'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created']),
      );
    } catch (e) {
      return null;
    }
  }
  
  // Serialize to JSON string
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'createdAt': createdAt.millisecondsSinceEpoch,
    });
  }
  
  // Deserialize from JSON string
  factory Contact.fromJson(String json) {
    final map = jsonDecode(json);
    return Contact(
      id: map['id'],
      name: map['name'],
      publicKey: map['publicKey'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}