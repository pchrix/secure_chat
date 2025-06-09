import 'dart:async';
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
  
  // Generate a user-specific ID based on device info
  // This is just a simulation - in a real app, you'd use more reliable device fingerprinting
  static Future<String> generateUserIdentifier() async {
    const deviceInfo = 'calculator-app-device'; // Just a placeholder
    final bytes = utf8.encode(deviceInfo);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Use first 16 chars of hash
  }
  
  // Generate a contact exchange code for sharing
  static Future<String> generateContactCode(String name) async {
    final userId = await generateUserIdentifier();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final publicKey = EncryptionService.generateRandomKey(); // In a real app, use actual crypto keys
    
    final contactData = {
      'u': userId,
      'n': name,
      'k': publicKey,
      't': timestamp,
    };
    
    return base64Url.encode(utf8.encode(jsonEncode(contactData)));
  }
  
  // Parse a contact exchange code
  static Map<String, dynamic>? parseContactCode(String code) {
    try {
      final decoded = utf8.decode(base64Url.decode(code));
      return jsonDecode(decoded);
    } catch (e) {
      return null;
    }
  }
  
  // Secure wipe of sensitive data from memory
  // Note: This is just a simulation, as Dart/Flutter doesn't provide true memory wiping
  static void secureWipe(String sensitiveData) {
    // In a real secure app, you'd implement proper memory wiping techniques
    // This is just a placeholder to show intent
  }
}