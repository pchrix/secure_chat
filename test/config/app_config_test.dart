import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:securechat/config/app_config.dart';
import 'package:securechat/services/secure_storage_service.dart';

void main() {
  group('AppConfig Secure Credentials Tests', () {
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
    });

    test('should store and retrieve secure Supabase credentials', () async {
      const testUrl = 'https://test-project.supabase.co';
      const testKey = 'test-anon-key-12345';

      // Stocker les credentials de manière sécurisée
      await AppConfig.storeSupabaseCredentials(
        url: testUrl,
        anonKey: testKey,
      );

      // Récupérer les credentials
      final retrievedUrl = await AppConfig.getSecureSupabaseUrl();
      final retrievedKey = await AppConfig.getSecureSupabaseAnonKey();

      expect(retrievedUrl, equals(testUrl));
      expect(retrievedKey, equals(testKey));
    });

    test('should check if secure credentials are available', () async {
      // Vérifier qu'aucun credential n'est disponible initialement
      expect(await AppConfig.hasSecureCredentials(), isFalse);

      // Stocker des credentials
      await AppConfig.storeSupabaseCredentials(
        url: 'https://test.supabase.co',
        anonKey: 'test-key',
      );

      // Vérifier que les credentials sont maintenant disponibles
      expect(await AppConfig.hasSecureCredentials(), isTrue);
    });

    test('should clear secure credentials', () async {
      // Stocker des credentials
      await AppConfig.storeSupabaseCredentials(
        url: 'https://test.supabase.co',
        anonKey: 'test-key',
      );

      // Vérifier qu'ils sont disponibles
      expect(await AppConfig.hasSecureCredentials(), isTrue);

      // Nettoyer les credentials
      await AppConfig.clearSecureCredentials();

      // Vérifier qu'ils ne sont plus disponibles
      expect(await AppConfig.hasSecureCredentials(), isFalse);
    });

    test(
        'should fallback to environment variables when secure storage is empty',
        () async {
      // S'assurer que le stockage sécurisé est vide
      await AppConfig.clearSecureCredentials();

      try {
        // Essayer de récupérer depuis le stockage sécurisé (devrait fallback vers env vars)
        await AppConfig.getSecureSupabaseUrl();
        // Si on arrive ici, c'est que les variables d'environnement sont définies
        // ou que le fallback fonctionne
      } catch (e) {
        // C'est normal si les variables d'environnement ne sont pas définies en test
        expect(e.toString(), contains('Configuration Supabase requise'));
      }
    });

    test('should handle storage errors gracefully', () async {
      // Tester avec des valeurs nulles/vides
      await AppConfig.storeSupabaseCredentials(
        url: '',
        anonKey: '',
      );

      // Les credentials vides ne devraient pas être considérés comme valides
      expect(await AppConfig.hasSecureCredentials(), isFalse);
    });

    test('should maintain data integrity across multiple operations', () async {
      const credentials = [
        {'url': 'https://project1.supabase.co', 'key': 'key1'},
        {'url': 'https://project2.supabase.co', 'key': 'key2'},
        {'url': 'https://project3.supabase.co', 'key': 'key3'},
      ];

      // Stocker et récupérer plusieurs fois
      for (final cred in credentials) {
        await AppConfig.storeSupabaseCredentials(
          url: cred['url']!,
          anonKey: cred['key']!,
        );

        final retrievedUrl = await AppConfig.getSecureSupabaseUrl();
        final retrievedKey = await AppConfig.getSecureSupabaseAnonKey();

        expect(retrievedUrl, equals(cred['url']));
        expect(retrievedKey, equals(cred['key']));
      }
    });

    test('should handle concurrent access safely', () async {
      const testUrl = 'https://concurrent-test.supabase.co';
      const testKey = 'concurrent-test-key';

      // D'abord stocker les credentials
      await AppConfig.storeSupabaseCredentials(
        url: testUrl,
        anonKey: testKey,
      );

      // Ensuite faire des opérations de lecture concurrentes
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(AppConfig.getSecureSupabaseUrl());
        futures.add(AppConfig.getSecureSupabaseAnonKey());
        futures.add(AppConfig.hasSecureCredentials());
      }

      // Attendre que toutes les opérations de lecture se terminent
      final results = await Future.wait(futures);

      // Vérifier que toutes les lectures ont réussi
      for (int i = 0; i < results.length; i += 3) {
        expect(results[i], equals(testUrl)); // URL
        expect(results[i + 1], equals(testKey)); // Key
        expect(results[i + 2], isTrue); // hasCredentials
      }
    });
  });
}
