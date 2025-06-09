import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Generate a random encryption key
  static String generateRandomKey({int length = 32}) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Convert a passphrase to a 256-bit encryption key
  static String passphraseToKey(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes);
  }

  // Encrypt a message using AES-256
  static String encryptMessage(String message, String keyString) {
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

      final key = encrypt.Key(Uint8List.fromList(finalKeyBytes));
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(message, iv: iv);

      // Combine IV and encrypted content for easy decryption later
      final combined = jsonEncode({
        'iv': base64.encode(iv.bytes),
        'content': encrypted.base64,
      });

      return base64Url.encode(utf8.encode(combined));
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt a message using AES-256
  static String decryptMessage(String encryptedMessage, String keyString) {
    try {
      final decoded = utf8.decode(base64Url.decode(encryptedMessage));
      final Map<String, dynamic> parts = jsonDecode(decoded);

      final iv = encrypt.IV.fromBase64(parts['iv']);
      final encrypted = encrypt.Encrypted.fromBase64(parts['content']);

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

      final key = encrypt.Key(Uint8List.fromList(finalKeyBytes));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Verify if a string is a valid encrypted message
  static bool isValidEncryptedMessage(String text) {
    try {
      final decoded = utf8.decode(base64Url.decode(text));
      final Map<String, dynamic> parts = jsonDecode(decoded);

      return parts.containsKey('iv') && parts.containsKey('content');
    } catch (e) {
      return false;
    }
  }
}
