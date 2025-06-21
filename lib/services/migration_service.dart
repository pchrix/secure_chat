import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/room.dart';
import '../models/message.dart';
import '../services/supabase_service.dart';

class MigrationService {
  static const String _migrationVersionKey = 'migration_version';
  static const int _currentMigrationVersion = 1;

  /// Vérifier et exécuter les migrations nécessaires
  static Future<void> runMigrations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getInt(_migrationVersionKey) ?? 0;

      if (currentVersion < _currentMigrationVersion) {
        debugPrint(
            'Démarrage des migrations depuis la version $currentVersion');

        if (currentVersion < 1) {
          await _migrateToSupabase();
        }

        // Marquer la migration comme terminée
        await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);
        debugPrint(
            'Migrations terminées vers la version $_currentMigrationVersion');
      }
    } catch (e) {
      debugPrint('Erreur lors des migrations: $e');
      // Ne pas bloquer l'application si la migration échoue
    }
  }

  /// Migration vers Supabase (version 1)
  static Future<void> _migrateToSupabase() async {
    debugPrint('Migration vers Supabase en cours...');

    try {
      // Migrer les salons
      await _migrateRooms();

      // Migrer les clés de chiffrement
      await _migrateEncryptionKeys();

      // Migrer les messages (si stockés localement)
      await _migrateMessages();

      debugPrint('Migration vers Supabase terminée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la migration vers Supabase: $e');
      rethrow;
    }
  }

  /// Migrer les salons vers Supabase
  static Future<void> _migrateRooms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = prefs.getString('rooms');

      if (roomsJson != null) {
        final List<dynamic> roomsList = json.decode(roomsJson);

        for (final roomData in roomsList) {
          try {
            final room = Room.fromJson(roomData);

            // Ne migrer que les salons actifs et non expirés
            if (room.status == RoomStatus.active && !room.isExpired) {
              await SupabaseService.createRoom(room);
              debugPrint('Salon migré: ${room.id}');
            }
          } catch (e) {
            debugPrint('Erreur migration salon: $e');
            // Continuer avec les autres salons
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur migration des salons: $e');
    }
  }

  /// Migrer les clés de chiffrement vers Supabase
  static Future<void> _migrateEncryptionKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('room_key_')) {
          try {
            final roomId = key.replaceFirst('room_key_', '');
            final encryptedKey = prefs.getString(key);

            if (encryptedKey != null) {
              // Générer un hash de la clé pour la vérification
              final keyHash = encryptedKey.hashCode.toString();

              await SupabaseService.saveEncryptionKey(
                roomId,
                encryptedKey,
                keyHash,
              );

              debugPrint('Clé migrée pour le salon: $roomId');
            }
          } catch (e) {
            debugPrint('Erreur migration clé $key: $e');
            // Continuer avec les autres clés
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur migration des clés: $e');
    }
  }

  /// Migrer les messages vers Supabase (si stockés localement)
  static Future<void> _migrateMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('messages_')) {
          try {
            final roomId = key.replaceFirst('messages_', '');
            final messagesJson = prefs.getString(key);

            if (messagesJson != null) {
              final List<dynamic> messagesList = json.decode(messagesJson);

              for (final messageData in messagesList) {
                try {
                  final message = Message.fromJson(messageData);
                  await SupabaseService.saveMessage(message);
                } catch (e) {
                  debugPrint('Erreur migration message: $e');
                  // Continuer avec les autres messages
                }
              }

              debugPrint('Messages migrés pour le salon: $roomId');
            }
          } catch (e) {
            debugPrint('Erreur migration messages $key: $e');
            // Continuer avec les autres salons
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur migration des messages: $e');
    }
  }

  /// Nettoyer les données locales après migration réussie
  static Future<void> cleanupLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();

      for (final key in keys) {
        if (key.startsWith('room_key_') ||
            key.startsWith('messages_') ||
            key == 'rooms' ||
            key == 'current_room') {
          await prefs.remove(key);
        }
      }

      debugPrint('Nettoyage des données locales terminé');
    } catch (e) {
      debugPrint('Erreur lors du nettoyage: $e');
    }
  }

  /// Vérifier l'état de la migration
  static Future<bool> isMigrationComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final version = prefs.getInt(_migrationVersionKey) ?? 0;
      return version >= _currentMigrationVersion;
    } catch (e) {
      return false;
    }
  }

  /// Forcer une nouvelle migration (pour les tests)
  static Future<void> resetMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationVersionKey);
      debugPrint('Migration réinitialisée');
    } catch (e) {
      debugPrint('Erreur réinitialisation migration: $e');
    }
  }

  /// Sauvegarder les données avant migration
  static Future<void> backupLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backup = <String, dynamic>{};

      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('room_') ||
            key.startsWith('messages_') ||
            key == 'rooms' ||
            key == 'current_room') {
          backup[key] = prefs.get(key);
        }
      }

      // Sauvegarder avec timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('backup_$timestamp', json.encode(backup));

      debugPrint('Sauvegarde créée: backup_$timestamp');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Restaurer depuis une sauvegarde
  static Future<void> restoreFromBackup(String backupKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(backupKey);

      if (backupJson != null) {
        final backup = json.decode(backupJson) as Map<String, dynamic>;

        for (final entry in backup.entries) {
          final value = entry.value;
          if (value is String) {
            await prefs.setString(entry.key, value);
          } else if (value is int) {
            await prefs.setInt(entry.key, value);
          } else if (value is bool) {
            await prefs.setBool(entry.key, value);
          } else if (value is double) {
            await prefs.setDouble(entry.key, value);
          }
        }

        debugPrint('Restauration terminée depuis: $backupKey');
      }
    } catch (e) {
      debugPrint('Erreur lors de la restauration: $e');
    }
  }

  /// Lister les sauvegardes disponibles
  static Future<List<String>> getAvailableBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      return keys.where((key) => key.startsWith('backup_')).toList()
        ..sort((a, b) => b.compareTo(a)); // Plus récent en premier
    } catch (e) {
      return [];
    }
  }
}
