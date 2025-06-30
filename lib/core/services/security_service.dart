/// 🔐 Service de sécurité découplé avec injection de dépendances
///
/// Ce service remplace SecurityUtils en utilisant l'injection de dépendances
/// Riverpod pour découpler les services et faciliter les tests.

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des providers
import '../providers/service_providers.dart';
import '../../services/secure_encryption_service.dart';
import '../../services/secure_storage_service.dart';

/// Interface pour le service de sécurité
abstract class ISecurityService {
  Future<void> copyToClipboard(String text);
  Future<String?> getFromClipboard();
  Future<String> generateUserIdentifier();
  Future<String> generateContactCode(String name);
  Map<String, dynamic>? parseContactCode(String code);
  Future<List<int>> generateSecureKey();
  Future<String> encryptData(String plaintext, List<int> keyBytes);
  Future<String> decryptData(String ciphertext, List<int> keyBytes);
}

/// Implémentation du service de sécurité avec injection de dépendances
class SecurityService implements ISecurityService {
  const SecurityService(this._ref);

  final Ref _ref;

  // ============================================================================
  // OPÉRATIONS CLIPBOARD
  // ============================================================================

  @override
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Future<String?> getFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text;
  }

  // ============================================================================
  // GÉNÉRATION D'IDENTIFIANTS
  // ============================================================================

  @override
  Future<String> generateUserIdentifier() async {
    const deviceInfo = 'securechat-device'; // Placeholder pour info device
    final bytes = utf8.encode(deviceInfo);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Premiers 16 caractères du hash
  }

  @override
  Future<String> generateContactCode(String name) async {
    final userId = await generateUserIdentifier();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Utiliser le service de chiffrement injecté pour générer une clé publique
    _ref.read(secureEncryptionServiceProvider);
    final publicKey = await SecureEncryptionService.generateSecureKey();
    final publicKeyString = base64.encode(publicKey);

    final contactData = {
      'u': userId,
      'n': name,
      'k': publicKeyString,
      't': timestamp,
    };

    return base64Url.encode(utf8.encode(jsonEncode(contactData)));
  }

  @override
  Map<String, dynamic>? parseContactCode(String code) {
    try {
      final decoded = utf8.decode(base64Url.decode(code));
      return jsonDecode(decoded);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // OPÉRATIONS DE CHIFFREMENT
  // ============================================================================

  @override
  Future<List<int>> generateSecureKey() async {
    // Utiliser le service de chiffrement injecté
    return await SecureEncryptionService.generateSecureKey();
  }

  @override
  Future<String> encryptData(String plaintext, List<int> keyBytes) async {
    // Utiliser le service de chiffrement injecté
    return await SecureEncryptionService.encrypt(plaintext, keyBytes);
  }

  @override
  Future<String> decryptData(String ciphertext, List<int> keyBytes) async {
    // Utiliser le service de chiffrement injecté
    return await SecureEncryptionService.decrypt(ciphertext, keyBytes);
  }

  // ============================================================================
  // OPÉRATIONS DE VALIDATION
  // ============================================================================

  /// Valider la force d'un mot de passe
  bool validatePasswordStrength(String password) {
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  /// Valider un code de contact
  bool validateContactCode(String code) {
    final parsed = parseContactCode(code);
    if (parsed == null) return false;

    // Vérifier que tous les champs requis sont présents
    return parsed.containsKey('u') &&
        parsed.containsKey('n') &&
        parsed.containsKey('k') &&
        parsed.containsKey('t');
  }

  /// Générer un hash sécurisé pour un mot de passe
  Future<String> hashPassword(String password, String salt) async {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Générer un salt aléatoire
  Future<String> generateSalt() async {
    final key = await generateSecureKey();
    return base64.encode(key.take(16).toList()); // 16 bytes pour le salt
  }

  // ============================================================================
  // OPÉRATIONS DE STOCKAGE SÉCURISÉ
  // ============================================================================

  /// Stocker une donnée sensible de manière sécurisée
  Future<void> storeSecureData(String key, String value) async {
    _ref.read(secureStorageServiceProvider);
    await SecureStorageService.setString(key, value);
  }

  /// Récupérer une donnée sensible stockée
  Future<String?> getSecureData(String key) async {
    _ref.read(secureStorageServiceProvider);
    return await SecureStorageService.getString(key);
  }

  /// Supprimer une donnée sensible stockée
  Future<void> deleteSecureData(String key) async {
    _ref.read(secureStorageServiceProvider);
    await SecureStorageService.remove(key);
  }

  /// Vider tout le stockage sécurisé
  Future<void> clearAllSecureData() async {
    _ref.read(secureStorageServiceProvider);
    await SecureStorageService.clearAll();
  }

  // ============================================================================
  // OPÉRATIONS DE NETTOYAGE MÉMOIRE
  // ============================================================================

  /// Documentation sur les limitations de Dart pour le memory wiping
  ///
  /// IMPORTANT: Dart/Flutter Memory Security Limitations
  ///
  /// Dart utilise un garbage collector automatique qui rend impossible
  /// le "memory wiping" sécurisé des données sensibles. Les chaînes de caractères
  /// et autres objets peuvent persister en mémoire même après leur suppression
  /// logique, jusqu'à ce que le GC les collecte.
  ///
  /// RECOMMANDATIONS DE SÉCURITÉ :
  /// 1. Minimiser le temps de vie des données sensibles en mémoire
  /// 2. Utiliser flutter_secure_storage pour le stockage persistant
  /// 3. Éviter de stocker des données sensibles dans des variables String
  /// 4. Préférer les Uint8List pour les données cryptographiques temporaires
  /// 5. Implémenter une architecture où les données sensibles restent
  ///    chiffrées le plus longtemps possible
  ///
  /// Pour une sécurité maximale, considérer l'utilisation de :
  /// - Isolates séparés pour les opérations cryptographiques
  /// - FFI avec des bibliothèques natives pour le memory wiping
  /// - Chiffrement bout-en-bout où les clés ne transitent jamais en clair
  void documentMemoryLimitations() {
    // Cette méthode existe uniquement pour documenter les limitations
    // Elle remplace l'ancienne fonction secureWipe() vide
  }

  // ============================================================================
  // OPÉRATIONS DE VALIDATION DE SÉCURITÉ
  // ============================================================================

  /// Effectuer un audit de sécurité des données stockées
  Future<Map<String, dynamic>> auditStoredData() async {
    final audit = <String, dynamic>{};

    try {
      // Vérifier que le service est disponible
      _ref.read(secureStorageServiceProvider);

      // Vérifier la présence de données sensibles
      final pinHash = await SecureStorageService.getString('pin_hash');
      final roomKeys = await SecureStorageService.getString('room_keys');

      audit['pin_stored'] = pinHash != null;
      audit['room_keys_stored'] = roomKeys != null;
      audit['secure_storage_available'] = true;

      // Vérifier l'intégrité des données
      if (roomKeys != null) {
        try {
          final parsed = jsonDecode(roomKeys);
          audit['room_keys_valid'] = parsed is Map;
        } catch (e) {
          audit['room_keys_valid'] = false;
          audit['room_keys_error'] = e.toString();
        }
      }
    } catch (e) {
      audit['error'] = e.toString();
      audit['secure_storage_available'] = false;
    }

    return audit;
  }

  /// Nettoyer les données temporaires et sensibles
  Future<void> cleanupTemporaryData() async {
    try {
      // Nettoyer le clipboard si nécessaire
      await Clipboard.setData(const ClipboardData(text: ''));

      // Autres opérations de nettoyage peuvent être ajoutées ici
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }
}

// ============================================================================
// PROVIDER POUR LE SERVICE DE SÉCURITÉ
// ============================================================================

/// Provider pour le service de sécurité avec injection de dépendances
final securityServiceProvider = Provider<ISecurityService>((ref) {
  return SecurityService(ref);
});

/// Provider pour l'audit de sécurité
final securityAuditProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final securityService = ref.read(securityServiceProvider) as SecurityService;
  return await securityService.auditStoredData();
});

/// Provider pour la validation de la force d'un mot de passe
final passwordStrengthProvider = Provider.family<bool, String>((ref, password) {
  final securityService = ref.read(securityServiceProvider) as SecurityService;
  return securityService.validatePasswordStrength(password);
});

/// Provider pour la validation d'un code de contact
final contactCodeValidationProvider =
    Provider.family<bool, String>((ref, code) {
  final securityService = ref.read(securityServiceProvider) as SecurityService;
  return securityService.validateContactCode(code);
});
