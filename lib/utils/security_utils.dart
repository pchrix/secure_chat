import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../services/encryption_service.dart';

class SecurityUtils {
  // Clipboard operations with security features
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  
  static Future<String?> getFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text;
  }
  
  /// Generate a user-specific ID based on device info
  static Future<String> generateUserIdentifier() async {
    const deviceInfo = 'securechat-device';
    final bytes = utf8.encode(deviceInfo);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  /// Generate a contact exchange code for sharing
  static Future<String> generateContactCode(String name) async {
    final userId = await generateUserIdentifier();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final publicKey = EncryptionService.generateRandomKey();
    
    final contactData = {
      'u': userId,
      'n': name,
      'k': publicKey,
      't': timestamp,
    };
    
    return base64Url.encode(utf8.encode(jsonEncode(contactData)));
  }
  
  /// Parse a contact exchange code
  static Map<String, dynamic>? parseContactCode(String code) {
    try {
      final decoded = utf8.decode(base64Url.decode(code));
      return jsonDecode(decoded);
    } catch (e) {
      return null;
    }
  }
  
  /// Secure wipe of sensitive data from memory
  /// Note: Dart/Flutter doesn't provide true memory wiping
  static void secureWipe(String sensitiveData) {
    // Memory wiping placeholder - limited by Dart/Flutter capabilities
  }
}