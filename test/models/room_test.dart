import 'package:flutter_test/flutter_test.dart';
import 'package:securechat/models/room.dart';

void main() {
  group('Room Model Tests', () {
    test('should create a new room with default values', () {
      final room = Room.create();

      expect(room.id.length, equals(8));
      expect(room.status, equals(RoomStatus.waiting));
      expect(room.participantCount, equals(0));
      expect(room.canJoin, isTrue);
      expect(room.isExpired, isFalse);
    });

    test('should generate unique room IDs', () {
      final room1 = Room.create();
      final room2 = Room.create();

      expect(room1.id, isNot(equals(room2.id)));
    });

    test('should allow joining when room is available', () {
      final room = Room.create();
      final firstJoin = room.join();
      final secondJoin = firstJoin.join();

      expect(firstJoin.participantCount, equals(1));
      expect(firstJoin.status, equals(RoomStatus.waiting));
      expect(firstJoin.canJoin, isTrue);

      expect(secondJoin.participantCount, equals(2));
      expect(secondJoin.status, equals(RoomStatus.active));
      expect(secondJoin.canJoin, isFalse);
    });

    test('should not allow joining when room is full', () {
      final room = Room.create().join().join(); // 2 participants

      expect(() => room.join(), throwsException);
    });

    test('should handle leaving correctly', () {
      final room = Room.create().join().join(); // 2 participants, active
      final leftRoom = room.leave(); // 1 participant, waiting

      expect(leftRoom.participantCount, equals(1));
      expect(leftRoom.status, equals(RoomStatus.waiting));
      expect(leftRoom.canJoin, isTrue);
    });

    test('should serialize and deserialize correctly', () {
      final originalRoom = Room.create(
        creatorId: 'test-creator',
        durationHours: 12,
        metadata: {'test': 'value'},
      );

      final json = originalRoom.toJson();
      final deserializedRoom = Room.fromJson(json);

      expect(deserializedRoom.id, equals(originalRoom.id));
      expect(deserializedRoom.creatorId, equals(originalRoom.creatorId));
      expect(deserializedRoom.status, equals(originalRoom.status));
      expect(deserializedRoom.metadata['test'], equals('value'));
    });

    test('should generate and parse invite codes', () {
      final room = Room.create();
      final inviteCode = room.generateInviteCode();
      final parsedRoom = Room.fromInviteCode(inviteCode);

      expect(parsedRoom, isNotNull);
      expect(parsedRoom!.id, equals(room.id));
      expect(parsedRoom.createdAt.millisecondsSinceEpoch,
          equals(room.createdAt.millisecondsSinceEpoch));
      expect(parsedRoom.expiresAt.millisecondsSinceEpoch,
          equals(room.expiresAt.millisecondsSinceEpoch));
    });

    test('should handle invalid invite codes', () {
      final parsedRoom = Room.fromInviteCode('invalid-code');
      expect(parsedRoom, isNull);
    });

    test('should correctly identify expired rooms', () {
      final expiredRoom = Room(
        id: 'TEST1234',
        name: 'Test Room',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: RoomStatus.waiting,
        participantCount: 0,
      );

      expect(expiredRoom.isExpired, isTrue);
      expect(expiredRoom.canJoin, isFalse);
    });

    test('should provide correct status displays', () {
      final waitingRoom = Room.create();
      final partialRoom = waitingRoom.join(); // 1 participant
      final activeRoom = partialRoom.join(); // 2 participants
      final expiredRoom = activeRoom.expire();

      expect(waitingRoom.statusDisplay, equals('0/2 - En attente'));
      expect(partialRoom.statusDisplay, equals('1/2 - En attente'));
      expect(activeRoom.statusDisplay, equals('2/2 - Connecté'));
      expect(expiredRoom.statusDisplay, equals('Expiré'));
    });

    test('should provide correct status icons', () {
      final waitingRoom = Room.create();
      final activeRoom =
          waitingRoom.join().join(); // 2 participants pour être actif
      final expiredRoom = activeRoom.expire();

      expect(waitingRoom.statusIcon, equals('⏳'));
      expect(activeRoom.statusIcon, equals('🔐'));
      expect(expiredRoom.statusIcon, equals('❌'));
    });
  });
}
