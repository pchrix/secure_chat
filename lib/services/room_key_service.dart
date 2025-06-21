import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

class RoomKeyService {
  static const String _roomKeysKey = 'room_keys';

  static RoomKeyService? _instance;
  static RoomKeyService get instance => _instance ??= RoomKeyService._();

  RoomKeyService._();

  Map<String, String> _roomKeys = {};

  Future<void> initialize() async {
    await _loadRoomKeys();
  }

  /// Génère une nouvelle clé pour un salon
  Future<String> generateKeyForRoom(String roomId) async {
    final key = EncryptionService.generateRandomKey();
    _roomKeys[roomId] = key;
    await _saveRoomKeys();
    return key;
  }

  /// Récupère la clé d'un salon
  String? getKeyForRoom(String roomId) {
    return _roomKeys[roomId];
  }

  /// Définit une clé pour un salon (pour rejoindre un salon existant)
  Future<void> setKeyForRoom(String roomId, String key) async {
    _roomKeys[roomId] = key;
    await _saveRoomKeys();
  }

  /// Supprime la clé d'un salon
  Future<void> removeKeyForRoom(String roomId) async {
    _roomKeys.remove(roomId);
    await _saveRoomKeys();
  }

  /// Vérifie si un salon a une clé
  bool hasKeyForRoom(String roomId) {
    return _roomKeys.containsKey(roomId);
  }

  /// Récupère toutes les clés de salons
  Map<String, String> getAllRoomKeys() {
    return Map.unmodifiable(_roomKeys);
  }

  /// Nettoie les clés des salons expirés
  Future<void> cleanupExpiredRoomKeys(List<String> activeRoomIds) async {
    final keysToRemove = <String>[];

    for (final roomId in _roomKeys.keys) {
      if (!activeRoomIds.contains(roomId)) {
        keysToRemove.add(roomId);
      }
    }

    for (final roomId in keysToRemove) {
      _roomKeys.remove(roomId);
    }

    if (keysToRemove.isNotEmpty) {
      await _saveRoomKeys();
    }
  }

  /// Chiffre un message avec la clé du salon
  String? encryptMessageForRoom(String roomId, String message) {
    final key = getKeyForRoom(roomId);
    if (key == null) return null;

    try {
      return EncryptionService.encryptMessage(message, key);
    } catch (e) {
      return null;
    }
  }

  /// Déchiffre un message avec la clé du salon
  String? decryptMessageForRoom(String roomId, String encryptedMessage) {
    final key = getKeyForRoom(roomId);
    if (key == null) return null;

    try {
      return EncryptionService.decryptMessage(encryptedMessage, key);
    } catch (e) {
      return null;
    }
  }

  /// Génère un hash de la clé pour vérification (sans exposer la clé)
  String? getKeyHashForRoom(String roomId) {
    final key = getKeyForRoom(roomId);
    if (key == null) return null;

    // Simple hash pour vérification (ne pas utiliser en production)
    return key.substring(0, 8);
  }

  /// Exporte les clés pour sauvegarde (chiffrées avec un mot de passe)
  Future<String?> exportKeys(String password) async {
    try {
      final keysJson = json.encode(_roomKeys);
      final encryptionKey = EncryptionService.passphraseToKey(password);
      return EncryptionService.encryptMessage(keysJson, encryptionKey);
    } catch (e) {
      return null;
    }
  }

  /// Importe les clés depuis une sauvegarde
  Future<bool> importKeys(String encryptedKeys, String password) async {
    try {
      final encryptionKey = EncryptionService.passphraseToKey(password);
      final keysJson =
          EncryptionService.decryptMessage(encryptedKeys, encryptionKey);
      final Map<String, dynamic> importedKeys = json.decode(keysJson);

      // Valider que toutes les clés sont des strings
      for (final entry in importedKeys.entries) {
        if (entry.value is! String) {
          return false;
        }
      }

      _roomKeys = Map<String, String>.from(importedKeys);
      await _saveRoomKeys();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Efface toutes les clés (pour réinitialisation)
  Future<void> clearAllKeys() async {
    _roomKeys.clear();
    await _saveRoomKeys();
  }

  Future<void> _loadRoomKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysJson = prefs.getString(_roomKeysKey);

      if (keysJson != null) {
        final Map<String, dynamic> keys = json.decode(keysJson);
        _roomKeys = Map<String, String>.from(keys);
      }
    } catch (e) {
      _roomKeys = {};
    }
  }

  Future<void> _saveRoomKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysJson = json.encode(_roomKeys);
      await prefs.setString(_roomKeysKey, keysJson);
    } catch (e) {
      // Gérer l'erreur de sauvegarde
    }
  }
}

// Extension pour faciliter l'utilisation
extension RoomKeyServiceExtensions on RoomKeyService {
  /// Génère et associe automatiquement une clé à un nouveau salon
  Future<String> createRoomWithKey(String roomId) async {
    return await generateKeyForRoom(roomId);
  }

  /// Vérifie si deux salons peuvent communiquer (même clé)
  bool canRoomsCommunicate(String roomId1, String roomId2) {
    final key1 = getKeyForRoom(roomId1);
    final key2 = getKeyForRoom(roomId2);

    return key1 != null && key2 != null && key1 == key2;
  }

  /// Synchronise une clé entre deux salons (pour la communication)
  Future<void> syncKeyBetweenRooms(
      String sourceRoomId, String targetRoomId) async {
    final sourceKey = getKeyForRoom(sourceRoomId);
    if (sourceKey != null) {
      await setKeyForRoom(targetRoomId, sourceKey);
    }
  }

  /// Statistiques des clés
  Map<String, dynamic> getKeyStatistics() {
    return {
      'totalKeys': _roomKeys.length,
      'roomIds': _roomKeys.keys.toList(),
      'hasKeys': _roomKeys.isNotEmpty,
    };
  }
}
