import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Service de chiffrement sécurisé utilisant AES-256-GCM
///
/// Cette classe remplace l'ancien système XOR vulnérable par un chiffrement
/// AES-256-GCM standard industrie, offrant confidentialité et authentification.
///
/// Fonctionnalités :
/// - Chiffrement AES-256-GCM avec nonce aléatoire
/// - Génération de clés cryptographiquement sécurisées
/// - Authentification intégrée (AEAD)
/// - Gestion d'erreurs robuste
class SecureEncryptionService {
  /// Algorithme de chiffrement AES-256-GCM
  static final _algorithm = AesGcm.with256bits();

  /// Longueur de la clé en octets (256 bits = 32 octets)
  static const int keyLength = 32;

  /// Longueur du nonce en octets (96 bits = 12 octets, recommandé par NIST)
  static const int nonceLength = 12;

  /// Longueur du tag d'authentification en octets (128 bits = 16 octets)
  static const int tagLength = 16;

  /// Génère une clé de chiffrement sécurisée de 256 bits
  ///
  /// Utilise un générateur cryptographiquement sécurisé pour créer
  /// une clé AES-256 imprévisible.
  ///
  /// Returns: Liste d'octets représentant la clé de 256 bits
  /// Throws: [Exception] si la génération échoue
  static Future<List<int>> generateSecureKey() async {
    try {
      final secretKey = await _algorithm.newSecretKey();
      return await secretKey.extractBytes();
    } catch (e) {
      throw Exception('Erreur lors de la génération de la clé sécurisée: $e');
    }
  }

  /// Chiffre un texte en clair avec AES-256-GCM
  ///
  /// [plaintext] Le texte à chiffrer
  /// [keyBytes] La clé de chiffrement de 256 bits
  ///
  /// Returns: Chaîne base64 contenant nonce + ciphertext + tag
  /// Throws: [ArgumentError] si les paramètres sont invalides
  /// Throws: [Exception] si le chiffrement échoue
  static Future<String> encrypt(String plaintext, List<int> keyBytes) async {
    if (plaintext.isEmpty) {
      throw ArgumentError('Le texte en clair ne peut pas être vide');
    }

    if (keyBytes.length != keyLength) {
      throw ArgumentError('La clé doit faire exactement $keyLength octets');
    }

    try {
      // Création de la clé secrète
      final secretKey = SecretKey(keyBytes);

      // Génération d'un nonce aléatoire
      final nonce = _algorithm.newNonce();

      // Chiffrement avec authentification
      final secretBox = await _algorithm.encrypt(
        utf8.encode(plaintext),
        secretKey: secretKey,
        nonce: nonce,
      );

      // Retour du résultat encodé en base64
      return base64.encode(secretBox.concatenation());
    } catch (e) {
      throw Exception('Erreur lors du chiffrement: $e');
    }
  }

  /// Déchiffre un texte chiffré avec AES-256-GCM
  ///
  /// [ciphertext] Le texte chiffré en base64 (nonce + ciphertext + tag)
  /// [keyBytes] La clé de déchiffrement de 256 bits
  ///
  /// Returns: Le texte en clair déchiffré
  /// Throws: [ArgumentError] si les paramètres sont invalides
  /// Throws: [Exception] si le déchiffrement ou l'authentification échoue
  static Future<String> decrypt(String ciphertext, List<int> keyBytes) async {
    if (ciphertext.isEmpty) {
      throw ArgumentError('Le texte chiffré ne peut pas être vide');
    }

    if (keyBytes.length != keyLength) {
      throw ArgumentError('La clé doit faire exactement $keyLength octets');
    }

    try {
      // Décodage du base64
      final encrypted = base64.decode(ciphertext);

      // Vérification de la longueur minimale
      final minLength = nonceLength + tagLength;
      if (encrypted.length < minLength) {
        throw ArgumentError('Données chiffrées trop courtes');
      }

      // Création de la clé secrète
      final secretKey = SecretKey(keyBytes);

      // Reconstruction du SecretBox
      final secretBox = SecretBox.fromConcatenation(
        encrypted,
        nonceLength: nonceLength,
        macLength: tagLength,
      );

      // Déchiffrement avec vérification d'authentification
      final decrypted = await _algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(decrypted);
    } on ArgumentError {
      rethrow; // Relancer les ArgumentError sans les wrapper
    } catch (e) {
      throw Exception('Erreur lors du déchiffrement: $e');
    }
  }

  /// Vérifie si une clé a la bonne longueur
  ///
  /// [keyBytes] La clé à vérifier
  ///
  /// Returns: true si la clé est valide, false sinon
  static bool isValidKey(List<int> keyBytes) {
    return keyBytes.length == keyLength;
  }

  /// Génère un nonce aléatoire pour tests ou usage avancé
  ///
  /// Returns: Nonce de 96 bits (12 octets)
  static List<int> generateNonce() {
    final random = Random.secure();
    return List.generate(nonceLength, (_) => random.nextInt(256));
  }
}
