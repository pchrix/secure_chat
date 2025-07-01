import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';
import 'secure_storage_service.dart';

class RoomKeyService {
  static const String _roomKeysKey = 'room_keys';

  static RoomKeyService? _instance;
  static RoomKeyService get instance => _instance ??= RoomKeyService._();

  RoomKeyService._();

  Map<String, String> _roomKeys = {};

  Future<void> initialize() async {
    // Initialiser le stockage sécurisé
    await SecureStorageService.initialize();

    // Migrer les clés existantes depuis SharedPreferences vers le stockage sécurisé
    await _migrateFromSharedPreferences();

    // Charger les clés depuis le stockage sécurisé
    await _loadRoomKeys();
  }

  /// Génère une nouvelle clé pour un salon
  Future<String> generateKeyForRoom(String roomId) async {
    final key = await EncryptionService.generateRandomKey();
    _roomKeys[roomId] = key;
    await SecureStorageService.storeRoomKey(roomId, key);
    return key;
  }

  /// Récupère la clé d'un salon
  Future<String?> getKeyForRoom(String roomId) async {
    // Vérifier d'abord le cache en mémoire
    if (_roomKeys.containsKey(roomId)) {
      return _roomKeys[roomId];
    }

    // Sinon, récupérer depuis le stockage sécurisé
    final key = await SecureStorageService.getRoomKey(roomId);
    if (key != null) {
      _roomKeys[roomId] = key; // Mettre en cache
    }
    return key;
  }

  /// Définit une clé pour un salon (pour rejoindre un salon existant)
  Future<void> setKeyForRoom(String roomId, String key) async {
    _roomKeys[roomId] = key;
    await SecureStorageService.storeRoomKey(roomId, key);
  }

  /// Supprime la clé d'un salon
  Future<void> removeKeyForRoom(String roomId) async {
    _roomKeys.remove(roomId);
    await SecureStorageService.removeRoomKey(roomId);
  }

  /// Vérifie si un salon a une clé
  Future<bool> hasKeyForRoom(String roomId) async {
    // Vérifier d'abord le cache en mémoire
    if (_roomKeys.containsKey(roomId)) {
      return true;
    }

    // Sinon, vérifier dans le stockage sécurisé
    return await SecureStorageService.hasRoomKey(roomId);
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
      await SecureStorageService.removeRoomKey(roomId);
    }
  }

  /// Chiffre un message avec la clé du salon
  Future<String?> encryptMessageForRoom(String roomId, String message) async {
    final key = await getKeyForRoom(roomId);
    if (key == null) return null;

    try {
      return await EncryptionService.encryptMessage(message, key);
    } catch (e) {
      return null;
    }
  }

  /// Déchiffre un message avec la clé du salon
  Future<String?> decryptMessageForRoom(
      String roomId, String encryptedMessage) async {
    final key = await getKeyForRoom(roomId);
    if (key == null) return null;

    try {
      return await EncryptionService.decryptMessage(encryptedMessage, key);
    } catch (e) {
      return null;
    }
  }

  /// Génère un hash de la clé pour vérification (sans exposer la clé)
  Future<String?> getKeyHashForRoom(String roomId) async {
    final key = await getKeyForRoom(roomId);
    if (key == null) return null;

    // Simple hash pour vérification (ne pas utiliser en production)
    return key.substring(0, 8);
  }

  /// Exporte les clés pour sauvegarde (chiffrées avec un mot de passe)
  Future<String?> exportKeys(String password) async {
    try {
      final keysJson = json.encode(_roomKeys);
      final encryptionKey = EncryptionService.passphraseToKey(password);
      return await EncryptionService.encryptMessage(keysJson, encryptionKey);
    } catch (e) {
      return null;
    }
  }

  /// Importe les clés depuis une sauvegarde
  Future<bool> importKeys(String encryptedKeys, String password) async {
    try {
      final encryptionKey = EncryptionService.passphraseToKey(password);
      final keysJson =
          await EncryptionService.decryptMessage(encryptedKeys, encryptionKey);
      final Map<String, dynamic> importedKeys = json.decode(keysJson);

      // Valider que toutes les clés sont des strings
      for (final entry in importedKeys.entries) {
        if (entry.value is! String) {
          return false;
        }
      }

      // Stocker chaque clé importée dans le stockage sécurisé
      for (final entry in importedKeys.entries) {
        await SecureStorageService.storeRoomKey(entry.key, entry.value);
        _roomKeys[entry.key] = entry.value;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Efface toutes les clés (pour réinitialisation)
  Future<void> clearAllKeys() async {
    _roomKeys.clear();
    await SecureStorageService.clearAllRoomKeys();
  }

  /// Migre les clés existantes depuis SharedPreferences vers le stockage sécurisé
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysJson = prefs.getString(_roomKeysKey);

      if (keysJson != null) {
        final Map<String, dynamic> keys = json.decode(keysJson);
        final roomKeys = Map<String, String>.from(keys);

        // Migrer chaque clé vers le stockage sécurisé
        for (final entry in roomKeys.entries) {
          await SecureStorageService.storeRoomKey(entry.key, entry.value);
        }

        // Supprimer les anciennes clés de SharedPreferences
        await prefs.remove(_roomKeysKey);

        // Migration réussie - log pour debug uniquement
        // print('✅ Migration de ${roomKeys.length} clés vers le stockage sécurisé terminée');
      }
    } catch (e) {
      // Erreur de migration - log pour debug uniquement
      // print('⚠️ Erreur lors de la migration: $e');
    }
  }

  /// Charge les clés depuis le stockage sécurisé
  Future<void> _loadRoomKeys() async {
    try {
      _roomKeys = await SecureStorageService.getAllRoomKeys();
    } catch (e) {
      _roomKeys = {};
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
  Future<bool> canRoomsCommunicate(String roomId1, String roomId2) async {
    final key1 = await getKeyForRoom(roomId1);
    final key2 = await getKeyForRoom(roomId2);

    return key1 != null && key2 != null && key1 == key2;
  }

  /// Synchronise une clé entre deux salons (pour la communication)
  Future<void> syncKeyBetweenRooms(
      String sourceRoomId, String targetRoomId) async {
    final sourceKey = await getKeyForRoom(sourceRoomId);
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
