import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:securechat/services/secure_encryption_service.dart';

class EncryptionService {
  // Generate a random encryption key using AES-256-GCM
  static Future<String> generateRandomKey({int length = 32}) async {
    final keyBytes = await SecureEncryptionService.generateSecureKey();
    return base64Url.encode(keyBytes);
  }

  // Convert a passphrase to a 256-bit encryption key
  static String passphraseToKey(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  // Encrypt a message using AES-256-GCM
  static Future<String> encryptMessage(String message, String keyString) async {
    try {
      final keyBytes = base64Url.decode(keyString);

      // Ensure key is exactly 32 bytes for AES-256
      List<int> finalKeyBytes;
      if (keyBytes.length == 32) {
        finalKeyBytes = keyBytes;
      } else if (keyBytes.length > 32) {
        finalKeyBytes = keyBytes.sublist(0, 32);
      } else {
        // Pad with zeros if too short
        finalKeyBytes = List<int>.from(keyBytes);
        while (finalKeyBytes.length < 32) {
          finalKeyBytes.add(0);
        }
      }

      return await SecureEncryptionService.encrypt(message, finalKeyBytes);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt a message using AES-256-GCM
  static Future<String> decryptMessage(
      String encryptedMessage, String keyString) async {
    try {
      final keyBytes = base64Url.decode(keyString);

      // Ensure key is exactly 32 bytes for AES-256 (same logic as encryption)
      List<int> finalKeyBytes;
      if (keyBytes.length == 32) {
        finalKeyBytes = keyBytes;
      } else if (keyBytes.length > 32) {
        finalKeyBytes = keyBytes.sublist(0, 32);
      } else {
        // Pad with zeros if too short
        finalKeyBytes = List<int>.from(keyBytes);
        while (finalKeyBytes.length < 32) {
          finalKeyBytes.add(0);
        }
      }

      return await SecureEncryptionService.decrypt(
          encryptedMessage, finalKeyBytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Verify if a string is a valid encrypted message (AES-GCM format)
  static bool isValidEncryptedMessage(String text) {
    try {
      // Try to decode as base64 - AES-GCM format
      final decoded = base64.decode(text);

      // Check minimum length: nonce (12) + tag (16) + at least 1 byte content
      return decoded.length >= 29;
    } catch (e) {
      // Also try legacy format for backward compatibility
      try {
        final decoded = utf8.decode(base64Url.decode(text));
        final Map<String, dynamic> parts = jsonDecode(decoded);
        return parts.containsKey('iv') && parts.containsKey('content');
      } catch (e2) {
        return false;
      }
    }
  }
}
