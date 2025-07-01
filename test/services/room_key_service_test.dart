import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:securechat/services/room_key_service.dart';

void main() {
  group('RoomKeyService', () {
    late RoomKeyService roomKeyService;

    setUpAll(() async {
      // Initialiser les bindings Flutter pour flutter_secure_storage
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock du canal de méthode pour flutter_secure_storage
      final Map<String, String> mockStorage = {};

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              final key = methodCall.arguments['key'] as String;
              return mockStorage[key];
            case 'write':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as String;
              mockStorage[key] = value;
              return null;
            case 'delete':
              final key = methodCall.arguments['key'] as String;
              mockStorage.remove(key);
              return null;
            case 'readAll':
              return Map<String, String>.from(mockStorage);
            case 'deleteAll':
              mockStorage.clear();
              return null;
            default:
              return null;
          }
        },
      );
    });

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      roomKeyService = RoomKeyService.instance;
      await roomKeyService.initialize();
    });

    tearDown(() async {
      await roomKeyService.clearAllKeys();
    });

    test('should generate unique keys for different rooms', () async {
      const roomId1 = 'ROOM001';
      const roomId2 = 'ROOM002';

      final key1 = await roomKeyService.generateKeyForRoom(roomId1);
      final key2 = await roomKeyService.generateKeyForRoom(roomId2);

      expect(key1, isNotEmpty);
      expect(key2, isNotEmpty);
      expect(key1, isNot(equals(key2)));
    });

    test('should retrieve generated keys correctly', () async {
      const roomId = 'ROOM001';
      final generatedKey = await roomKeyService.generateKeyForRoom(roomId);

      final retrievedKey = await roomKeyService.getKeyForRoom(roomId);

      expect(retrievedKey, equals(generatedKey));
    });

    test('should return null for non-existent room keys', () async {
      const nonExistentRoomId = 'NONEXISTENT';

      final key = await roomKeyService.getKeyForRoom(nonExistentRoomId);

      expect(key, isNull);
    });

    test('should set and retrieve custom keys', () async {
      const roomId = 'ROOM001';
      const customKey = 'custom_test_key_123';

      await roomKeyService.setKeyForRoom(roomId, customKey);
      final retrievedKey = await roomKeyService.getKeyForRoom(roomId);

      expect(retrievedKey, equals(customKey));
    });

    test('should remove keys correctly', () async {
      const roomId = 'ROOM001';
      await roomKeyService.generateKeyForRoom(roomId);

      expect(await roomKeyService.hasKeyForRoom(roomId), isTrue);

      await roomKeyService.removeKeyForRoom(roomId);

      expect(await roomKeyService.hasKeyForRoom(roomId), isFalse);
      expect(await roomKeyService.getKeyForRoom(roomId), isNull);
    });

    test('should encrypt and decrypt messages correctly', () async {
      const roomId = 'ROOM001';
      const message = 'Hello, secure world!';

      await roomKeyService.generateKeyForRoom(roomId);

      final encrypted =
          await roomKeyService.encryptMessageForRoom(roomId, message);
      expect(encrypted, isNotNull);
      expect(encrypted, isNot(equals(message)));

      final decrypted =
          await roomKeyService.decryptMessageForRoom(roomId, encrypted!);
      expect(decrypted, equals(message));
    });

    test('should return null when encrypting with non-existent key', () async {
      const roomId = 'NONEXISTENT';
      const message = 'Test message';

      final encrypted =
          await roomKeyService.encryptMessageForRoom(roomId, message);

      expect(encrypted, isNull);
    });

    test('should return null when decrypting with non-existent key', () async {
      const roomId = 'NONEXISTENT';
      const encryptedMessage = 'fake_encrypted_message';

      final decrypted =
          await roomKeyService.decryptMessageForRoom(roomId, encryptedMessage);

      expect(decrypted, isNull);
    });

    test('should cleanup expired room keys', () async {
      const activeRoomId = 'ACTIVE001';
      const expiredRoomId = 'EXPIRED001';

      await roomKeyService.generateKeyForRoom(activeRoomId);
      await roomKeyService.generateKeyForRoom(expiredRoomId);

      expect(await roomKeyService.hasKeyForRoom(activeRoomId), isTrue);
      expect(await roomKeyService.hasKeyForRoom(expiredRoomId), isTrue);

      await roomKeyService.cleanupExpiredRoomKeys([activeRoomId]);

      expect(await roomKeyService.hasKeyForRoom(activeRoomId), isTrue);
      expect(await roomKeyService.hasKeyForRoom(expiredRoomId), isFalse);
    });

    test('should generate key hash for verification', () async {
      const roomId = 'ROOM001';
      await roomKeyService.generateKeyForRoom(roomId);

      final keyHash = await roomKeyService.getKeyHashForRoom(roomId);

      expect(keyHash, isNotNull);
      expect(keyHash!.length, equals(8));
    });

    test('should export and import keys correctly', () async {
      const roomId1 = 'ROOM001';
      const roomId2 = 'ROOM002';
      // Utiliser une clé simple pour le test
      const password = 'test_password_for_export_import_123456789012';

      await roomKeyService.generateKeyForRoom(roomId1);
      await roomKeyService.generateKeyForRoom(roomId2);

      final originalKeys = roomKeyService.getAllRoomKeys();

      final exportedKeys = await roomKeyService.exportKeys(password);
      expect(exportedKeys, isNotNull);

      await roomKeyService.clearAllKeys();
      expect(roomKeyService.getAllRoomKeys(), isEmpty);

      final importSuccess =
          await roomKeyService.importKeys(exportedKeys!, password);
      expect(importSuccess, isTrue);

      final importedKeys = roomKeyService.getAllRoomKeys();
      expect(importedKeys, equals(originalKeys));
    });

    test('should fail to import with wrong password', () async {
      const roomId = 'ROOM001';
      const correctPassword = 'correct_password_123456789012345678901234';
      const wrongPassword = 'wrong_password_123456789012345678901234567';

      await roomKeyService.generateKeyForRoom(roomId);

      final exportedKeys = await roomKeyService.exportKeys(correctPassword);
      expect(exportedKeys, isNotNull);

      await roomKeyService.clearAllKeys();

      final importSuccess =
          await roomKeyService.importKeys(exportedKeys!, wrongPassword);
      expect(importSuccess, isFalse);
      expect(roomKeyService.getAllRoomKeys(), isEmpty);
    });

    test('should provide correct statistics', () async {
      const roomId1 = 'ROOM001';
      const roomId2 = 'ROOM002';

      final initialStats = roomKeyService.getKeyStatistics();
      expect(initialStats['totalKeys'], equals(0));
      expect(initialStats['hasKeys'], isFalse);

      await roomKeyService.generateKeyForRoom(roomId1);
      await roomKeyService.generateKeyForRoom(roomId2);

      final finalStats = roomKeyService.getKeyStatistics();
      expect(finalStats['totalKeys'], equals(2));
      expect(finalStats['hasKeys'], isTrue);
      expect(finalStats['roomIds'], contains(roomId1));
      expect(finalStats['roomIds'], contains(roomId2));
    });

    test('should sync keys between rooms', () async {
      const sourceRoomId = 'SOURCE001';
      const targetRoomId = 'TARGET001';

      final sourceKey = await roomKeyService.generateKeyForRoom(sourceRoomId);

      await roomKeyService.syncKeyBetweenRooms(sourceRoomId, targetRoomId);

      final targetKey = await roomKeyService.getKeyForRoom(targetRoomId);
      expect(targetKey, equals(sourceKey));
      expect(
          await roomKeyService.canRoomsCommunicate(sourceRoomId, targetRoomId),
          isTrue);
    });

    test('should detect when rooms can communicate', () async {
      const roomId1 = 'ROOM001';
      const roomId2 = 'ROOM002';
      const roomId3 = 'ROOM003';

      await roomKeyService.generateKeyForRoom(roomId1);
      await roomKeyService.generateKeyForRoom(roomId2);

      // Rooms with different keys cannot communicate
      expect(
          await roomKeyService.canRoomsCommunicate(roomId1, roomId2), isFalse);

      // Sync keys
      await roomKeyService.syncKeyBetweenRooms(roomId1, roomId2);

      // Now they can communicate
      expect(
          await roomKeyService.canRoomsCommunicate(roomId1, roomId2), isTrue);

      // Room without key cannot communicate
      expect(
          await roomKeyService.canRoomsCommunicate(roomId1, roomId3), isFalse);
    });
  });
}
