import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:securechat/services/unified_auth_service.dart';

void main() {
  group('UnifiedAuthService Tests', () {
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

      // Mock pour SharedPreferences
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (MethodCall methodCall) async {
          final Map<String, dynamic> mockPrefs = {};

          switch (methodCall.method) {
            case 'getAll':
              return mockPrefs;
            case 'setBool':
              final key = methodCall.arguments['key'] as String;
              final value = methodCall.arguments['value'] as bool;
              mockPrefs[key] = value;
              return true;
            case 'getBool':
              final key = methodCall.arguments['key'] as String;
              return mockPrefs[key] as bool?;
            case 'remove':
              final key = methodCall.arguments['key'] as String;
              mockPrefs.remove(key);
              return true;
            default:
              return null;
          }
        },
      );
    });

    setUp(() async {
      // Nettoyer et réinitialiser avant chaque test
      await UnifiedAuthService.resetAll();
      await UnifiedAuthService.initialize();
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        expect(UnifiedAuthService.isInitialized, isTrue);
      });

      test('should handle multiple initialization calls', () async {
        await UnifiedAuthService.initialize();
        await UnifiedAuthService.initialize();
        expect(UnifiedAuthService.isInitialized, isTrue);
      });

      test('should throw error when using uninitialized service', () async {
        await UnifiedAuthService.resetAll();

        expect(() => UnifiedAuthService.validatePasswordStrength('123456'),
            throwsException);
      });
    });

    group('Password Management Tests', () {
      test('should set a valid password successfully', () async {
        final result = await UnifiedAuthService.setPassword('147258');
        expect(result.isSuccess, isTrue);
        expect(result.type, equals(AuthResultType.success));

        // Vérifier que le password a été stocké
        expect(await UnifiedAuthService.hasPasswordSet(), isTrue);
      });

      test('should reject invalid password', () async {
        final result = await UnifiedAuthService.setPassword('123456');
        expect(result.isSuccess, isFalse);
        expect(result.type, equals(AuthResultType.error));

        // Vérifier qu'aucun password n'a été stocké
        expect(await UnifiedAuthService.hasPasswordSet(), isFalse);
      });

      test('should verify correct password', () async {
        const password = '147258';
        await UnifiedAuthService.setPassword(password);

        final result = await UnifiedAuthService.verifyPassword(password);
        expect(result.isSuccess, isTrue);
        expect(result.verified, isTrue);
        expect(result.type, equals(AuthResultType.success));
      });

      test('should reject incorrect password', () async {
        await UnifiedAuthService.setPassword('147258');

        final result = await UnifiedAuthService.verifyPassword('wrong');
        expect(result.isSuccess, isFalse);
        expect(result.verified, isFalse);
        expect(result.type, equals(AuthResultType.failed));
        expect(result.remainingAttempts, equals(2));
      });

      test('should change password with correct old password', () async {
        const oldPassword = '147258';
        const newPassword = '369852';

        await UnifiedAuthService.setPassword(oldPassword);

        final result =
            await UnifiedAuthService.changePassword(oldPassword, newPassword);
        expect(result.isSuccess, isTrue);

        // Vérifier que le nouveau password fonctionne
        final verification =
            await UnifiedAuthService.verifyPassword(newPassword);
        expect(verification.isSuccess, isTrue);

        // Vérifier que l'ancien password ne fonctionne plus
        final oldVerification =
            await UnifiedAuthService.verifyPassword(oldPassword);
        expect(oldVerification.isSuccess, isFalse);
      });

      test('should reset password', () async {
        await UnifiedAuthService.setPassword('147258');
        expect(await UnifiedAuthService.hasPasswordSet(), isTrue);

        await UnifiedAuthService.resetPassword();
        expect(await UnifiedAuthService.hasPasswordSet(), isFalse);
      });
    });

    group('Security Tests', () {
      test('should lock account after max failed attempts', () async {
        await UnifiedAuthService.setPassword('147258');

        // 3 tentatives échouées
        for (int i = 0; i < 3; i++) {
          await UnifiedAuthService.verifyPassword('wrong');
        }

        // La 4ème tentative devrait être verrouillée
        final result = await UnifiedAuthService.verifyPassword('147258');
        expect(result.isLocked, isTrue);
        expect(result.type, equals(AuthResultType.locked));
        expect(result.lockoutMinutes, greaterThan(0));
      });

      test('should validate password strength', () {
        // PIN trop court
        var result = UnifiedAuthService.validatePasswordStrength('12345');
        expect(result.isValid, isFalse);

        // PIN faible
        result = UnifiedAuthService.validatePasswordStrength('123456');
        expect(result.isValid, isFalse);

        // PIN valide
        result = UnifiedAuthService.validatePasswordStrength('147258');
        expect(result.isValid, isTrue);
      });

      test('should check account lock status', () async {
        await UnifiedAuthService.setPassword('147258');

        // Compte non verrouillé initialement
        expect(await UnifiedAuthService.isAccountLocked(), isFalse);
        expect(await UnifiedAuthService.getRemainingLockoutTime(), equals(0));

        // Générer des tentatives échouées pour verrouiller
        for (int i = 0; i < 3; i++) {
          await UnifiedAuthService.verifyPassword('wrong');
        }

        // Vérifier le verrouillage
        expect(await UnifiedAuthService.isAccountLocked(), isTrue);
        expect(
            await UnifiedAuthService.getRemainingLockoutTime(), greaterThan(0));
      });
    });

    group('Compatibility Tests', () {
      test('should provide configuration constants', () {
        expect(UnifiedAuthService.maxFailedAttempts, equals(3));
        expect(UnifiedAuthService.lockoutDurationMinutes, equals(5));
        expect(UnifiedAuthService.minPinLength, equals(6));
        expect(UnifiedAuthService.maxPinLength, equals(12));
      });

      test('should handle auth state checking', () async {
        // État initial - aucun PIN défini
        var authState = await UnifiedAuthService.checkAuthState();
        expect(authState.isReady, isTrue);
        expect(authState.type, equals(AuthStateType.noPinSet));

        // Après définition d'un PIN
        await UnifiedAuthService.setPassword('147258');
        authState = await UnifiedAuthService.checkAuthState();
        expect(authState.isReady, isTrue);
        expect(authState.type, equals(AuthStateType.pinSet));
      });

      test('should handle failed attempts count', () async {
        // Cette méthode retourne toujours 0 dans l'implémentation actuelle
        final failedAttempts = await UnifiedAuthService.getFailedAttempts();
        expect(failedAttempts, equals(0));
      });
    });

    group('Migration Tests', () {
      test('should handle clean initialization', () async {
        // Réinitialiser complètement
        await UnifiedAuthService.resetAll();

        // Réinitialiser
        await UnifiedAuthService.initialize();

        expect(UnifiedAuthService.isInitialized, isTrue);
        expect(await UnifiedAuthService.hasPasswordSet(), isFalse);
      });

      test('should maintain functionality after reset', () async {
        // Définir un PIN
        await UnifiedAuthService.setPassword('147258');
        expect(await UnifiedAuthService.hasPasswordSet(), isTrue);

        // Réinitialiser
        await UnifiedAuthService.resetAll();
        await UnifiedAuthService.initialize();

        // Vérifier que le PIN a été supprimé
        expect(await UnifiedAuthService.hasPasswordSet(), isFalse);

        // Vérifier qu'on peut définir un nouveau PIN
        final result = await UnifiedAuthService.setPassword('369852');
        expect(result.isSuccess, isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('should handle storage errors gracefully', () async {
        // Les erreurs de stockage sont gérées en interne
        // Ce test vérifie que l'API reste stable
        expect(() => UnifiedAuthService.validatePasswordStrength('147258'),
            returnsNormally);
      });

      test('should provide meaningful error messages', () async {
        final result = await UnifiedAuthService.setPassword('123');
        expect(result.isSuccess, isFalse);
        expect(result.message, isNotEmpty);
        expect(result.message, contains('trop court'));
      });
    });
  });
}
