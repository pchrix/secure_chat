import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:securechat/services/secure_pin_service.dart';
import 'package:securechat/services/secure_storage_service.dart';

void main() {
  group('SecurePinService Tests', () {
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
      // Nettoyer le stockage avant chaque test
      await SecureStorageService.clearAll();
      await SecurePinService.initialize();
    });

    group('PIN Validation Tests', () {
      test('should reject PIN that is too short', () {
        final result = SecurePinService.validatePinStrength('12345');
        expect(result.isValid, isFalse);
        expect(result.message, contains('trop court'));
      });

      test('should reject PIN that is too long', () {
        final result = SecurePinService.validatePinStrength('1234567890123');
        expect(result.isValid, isFalse);
        expect(result.message, contains('trop long'));
      });

      test('should reject weak common PINs', () {
        final weakPins = ['123456', '000000', '111111', '123123'];

        for (final pin in weakPins) {
          final result = SecurePinService.validatePinStrength(pin);
          expect(result.isValid, isFalse,
              reason: 'PIN $pin should be rejected');
          expect(result.message, contains('trop faible'));
        }
      });

      test('should reject PINs with insufficient diversity', () {
        final result = SecurePinService.validatePinStrength('111122');
        expect(result.isValid, isFalse);
        expect(result.message, contains('3 chiffres différents'));
      });

      test('should reject PINs with long sequences', () {
        final sequentialPins = ['123456', '987654', '456789', '654321'];

        for (final pin in sequentialPins) {
          final result = SecurePinService.validatePinStrength(pin);
          expect(result.isValid, isFalse,
              reason: 'PIN $pin should be rejected');
          expect(result.message, contains('séquences'));
        }
      });

      test('should accept strong PINs', () {
        final strongPins = ['147258', '369852', '258147', '741963'];

        for (final pin in strongPins) {
          final result = SecurePinService.validatePinStrength(pin);
          if (!result.isValid) {
            // Debug: PIN $pin rejected: ${result.message}
          }
          expect(result.isValid, isTrue,
              reason: 'PIN $pin should be accepted: ${result.message}');
        }
      });
    });

    group('PIN Setting Tests', () {
      test('should set a valid PIN successfully', () async {
        final result = await SecurePinService.setPin('147258');
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('succès'));

        // Vérifier que le PIN a été stocké
        expect(await SecurePinService.hasPinSet(), isTrue);
      });

      test('should reject setting an invalid PIN', () async {
        final result = await SecurePinService.setPin('123456');
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('trop faible'));

        // Vérifier qu'aucun PIN n'a été stocké
        expect(await SecurePinService.hasPinSet(), isFalse);
      });

      test('should overwrite existing PIN', () async {
        // Définir un premier PIN
        await SecurePinService.setPin('147258');
        expect(await SecurePinService.hasPinSet(), isTrue);

        // Définir un nouveau PIN
        final result = await SecurePinService.setPin('369852');
        expect(result.isSuccess, isTrue);

        // Vérifier que le nouveau PIN fonctionne
        final verification = await SecurePinService.verifyPin('369852');
        expect(verification.isSuccess, isTrue);

        // Vérifier que l'ancien PIN ne fonctionne plus
        final oldVerification = await SecurePinService.verifyPin('147258');
        expect(oldVerification.isSuccess, isFalse);
      });
    });

    group('PIN Verification Tests', () {
      test('should verify correct PIN', () async {
        const pin = '147258';
        await SecurePinService.setPin(pin);

        final result = await SecurePinService.verifyPin(pin);
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('correct'));
      });

      test('should reject incorrect PIN', () async {
        await SecurePinService.setPin('147258');

        final result = await SecurePinService.verifyPin('999999');
        expect(result.isSuccess, isFalse);
        expect(result.remainingAttempts, equals(2)); // 3 - 1 = 2
      });

      test('should handle no PIN set', () async {
        final result = await SecurePinService.verifyPin('123456');
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Aucun PIN défini'));
      });

      test('should lock account after max failed attempts', () async {
        await SecurePinService.setPin('147258');

        // 3 tentatives échouées
        for (int i = 0; i < 3; i++) {
          await SecurePinService.verifyPin('wrong');
        }

        // La 4ème tentative devrait être verrouillée
        final result = await SecurePinService.verifyPin('147258');
        expect(result.isLocked, isTrue);
        expect(result.lockoutMinutes, greaterThan(0));
        expect(result.lockoutMinutes, lessThanOrEqualTo(5));
      });

      test('should reset failed attempts after correct PIN', () async {
        await SecurePinService.setPin('147258');

        // 2 tentatives échouées
        await SecurePinService.verifyPin('wrong1');
        await SecurePinService.verifyPin('wrong2');

        // PIN correct
        final correctResult = await SecurePinService.verifyPin('147258');
        expect(correctResult.isSuccess, isTrue);

        // Les tentatives échouées devraient être réinitialisées
        // 2 nouvelles tentatives échouées ne devraient pas verrouiller
        await SecurePinService.verifyPin('wrong3');
        final result = await SecurePinService.verifyPin('wrong4');
        expect(result.isLocked, isFalse);
        expect(result.remainingAttempts, equals(1)); // 3 - 2 = 1
      });
    });

    group('PIN Change Tests', () {
      test('should change PIN with correct old PIN', () async {
        const oldPin = '147258';
        const newPin = '369852';

        await SecurePinService.setPin(oldPin);

        final result = await SecurePinService.changePin(oldPin, newPin);
        expect(result.isSuccess, isTrue);

        // Vérifier que le nouveau PIN fonctionne
        final verification = await SecurePinService.verifyPin(newPin);
        expect(verification.isSuccess, isTrue);

        // Vérifier que l'ancien PIN ne fonctionne plus
        final oldVerification = await SecurePinService.verifyPin(oldPin);
        expect(oldVerification.isSuccess, isFalse);
      });

      test('should reject PIN change with incorrect old PIN', () async {
        await SecurePinService.setPin('147258');

        final result = await SecurePinService.changePin('wrong', '369852');
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Ancien PIN incorrect'));
      });

      test('should reject PIN change with invalid new PIN', () async {
        await SecurePinService.setPin('147258');

        final result = await SecurePinService.changePin('147258', '123456');
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Nouveau PIN invalide'));
      });
    });

    group('PIN Reset Tests', () {
      test('should reset PIN completely', () async {
        await SecurePinService.setPin('147258');
        expect(await SecurePinService.hasPinSet(), isTrue);

        await SecurePinService.resetPin();
        expect(await SecurePinService.hasPinSet(), isFalse);
      });

      test('should reset failed attempts when resetting PIN', () async {
        await SecurePinService.setPin('147258');

        // Générer des tentatives échouées
        await SecurePinService.verifyPin('wrong1');
        await SecurePinService.verifyPin('wrong2');

        // Réinitialiser le PIN
        await SecurePinService.resetPin();

        // Définir un nouveau PIN
        await SecurePinService.setPin('369852');

        // Vérifier que les tentatives échouées ont été réinitialisées
        await SecurePinService.verifyPin('wrong3');
        final result = await SecurePinService.verifyPin('wrong4');
        expect(result.remainingAttempts, equals(1)); // Devrait être 1, pas 0
      });
    });

    group('Security Tests', () {
      test('should use different salts for same PIN', () async {
        const pin = '147258';

        // Définir le PIN une première fois
        await SecurePinService.setPin(pin);
        final firstHash =
            await SecureStorageService.getConfigValue('secure_pin_hash');
        final firstSalt =
            await SecureStorageService.getConfigValue('secure_pin_salt');

        // Réinitialiser et redéfinir le même PIN
        await SecurePinService.resetPin();
        await SecurePinService.setPin(pin);
        final secondHash =
            await SecureStorageService.getConfigValue('secure_pin_hash');
        final secondSalt =
            await SecureStorageService.getConfigValue('secure_pin_salt');

        // Les salts et hashes devraient être différents
        expect(firstSalt, isNot(equals(secondSalt)));
        expect(firstHash, isNot(equals(secondHash)));
      });

      test('should handle concurrent verification attempts', () async {
        await SecurePinService.setPin('147258');

        // Tentatives de vérification concurrentes
        final futures = <Future>[];

        // Quelques tentatives correctes
        for (int i = 0; i < 3; i++) {
          futures.add(SecurePinService.verifyPin('147258'));
        }

        // Quelques tentatives incorrectes
        for (int i = 0; i < 2; i++) {
          futures.add(SecurePinService.verifyPin('wrong'));
        }

        final results = await Future.wait(futures);

        // Vérifier que les tentatives correctes ont réussi
        final successCount = results.where((r) => r.isSuccess).length;
        expect(successCount, equals(3));

        // Vérifier que les tentatives incorrectes ont échoué
        final failureCount =
            results.where((r) => !r.isSuccess && !r.isLocked).length;
        expect(failureCount, equals(2));
      });
    });
  });
}
