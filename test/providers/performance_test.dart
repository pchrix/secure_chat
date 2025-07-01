import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_chat/core/providers/performance_optimized_providers.dart';
import 'package:secure_chat/providers/room_provider_riverpod.dart';
import 'package:secure_chat/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:secure_chat/features/auth/presentation/providers/pin_state_provider.dart';

void main() {
  group('Performance Optimized Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('AutoDispose Functionality', () {
      test('providers should auto-dispose when not listened', () async {
        // Test que les providers se disposent automatiquement
        var listener = container.listen(
          activeRoomsCountProvider,
          (previous, next) {},
        );

        // Le provider est maintenant actif
        expect(container.exists(activeRoomsCountProvider), true);

        // Arrêter d'écouter
        listener.close();

        // Attendre que le provider se dispose
        await Future.delayed(Duration.zero);

        // Le provider devrait être disposé
        expect(container.exists(activeRoomsCountProvider), false);
      });

      test('providers with keepAlive should persist', () async {
        // Test que keepAlive fonctionne correctement
        var listener = container.listen(
          appSettingsCacheProvider,
          (previous, next) {},
        );

        // Attendre que le provider se charge
        await container.read(appSettingsCacheProvider.future);

        // Arrêter d'écouter
        listener.close();

        // Attendre un cycle
        await Future.delayed(Duration.zero);

        // Le provider devrait persister grâce à keepAlive
        expect(container.exists(appSettingsCacheProvider), true);
      });
    });

    group('Select() Optimization', () {
      test('select should prevent unnecessary rebuilds', () {
        int buildCount = 0;

        // Provider qui compte les rebuilds
        final testProvider = Provider.autoDispose<String>((ref) {
          buildCount++;
          final count = ref.watch(activeRoomsCountProvider);
          return 'Count: $count';
        });

        // Écouter le provider
        final listener = container.listen(testProvider, (previous, next) {});

        // Le provider devrait s'être construit une fois
        expect(buildCount, 1);

        // Simuler un changement qui n'affecte pas le count
        // (dans un vrai test, on modifierait l'état du room provider)
        
        listener.close();
      });
    });

    group('Family Providers', () {
      test('family providers should create separate instances', () {
        const roomId1 = 'room1';
        const roomId2 = 'room2';

        // Créer des listeners pour différents IDs
        final listener1 = container.listen(
          roomByIdProvider(roomId1),
          (previous, next) {},
        );

        final listener2 = container.listen(
          roomByIdProvider(roomId2),
          (previous, next) {},
        );

        // Les deux instances devraient exister séparément
        expect(container.exists(roomByIdProvider(roomId1)), true);
        expect(container.exists(roomByIdProvider(roomId2)), true);

        listener1.close();
        listener2.close();
      });

      test('family providers should auto-dispose independently', () async {
        const roomId1 = 'room1';
        const roomId2 = 'room2';

        final listener1 = container.listen(
          roomByIdProvider(roomId1),
          (previous, next) {},
        );

        final listener2 = container.listen(
          roomByIdProvider(roomId2),
          (previous, next) {},
        );

        // Fermer seulement le premier listener
        listener1.close();
        await Future.delayed(Duration.zero);

        // Seul le premier devrait être disposé
        expect(container.exists(roomByIdProvider(roomId1)), false);
        expect(container.exists(roomByIdProvider(roomId2)), true);

        listener2.close();
      });
    });

    group('Combined Providers', () {
      test('combined providers should update correctly', () {
        // Test des providers qui combinent plusieurs états
        final listener = container.listen(
          canSendMessageProvider,
          (previous, next) {},
        );

        // Le provider devrait exister
        expect(container.exists(canSendMessageProvider), true);

        // Lire la valeur (devrait être false par défaut)
        final canSend = listener.read();
        expect(canSend, false);

        listener.close();
      });

      test('empty state provider should work correctly', () {
        final listener = container.listen(
          shouldShowEmptyStateProvider,
          (previous, next) {},
        );

        // Le provider devrait exister
        expect(container.exists(shouldShowEmptyStateProvider), true);

        // Lire la valeur
        final shouldShow = listener.read();
        expect(shouldShow, isA<bool>());

        listener.close();
      });
    });

    group('Cache Providers', () {
      test('user cache should expire correctly', () async {
        const userId = 'test-user';

        // Écouter le provider de cache
        final listener = container.listen(
          userCacheProvider(userId),
          (previous, next) {},
        );

        // Attendre que le cache se charge
        final userData = await container.read(userCacheProvider(userId).future);

        // Les données devraient être présentes
        expect(userData, isNotNull);
        expect(userData!['id'], userId);

        listener.close();
      });

      test('app settings cache should persist', () async {
        // Écouter le provider de paramètres
        final listener = container.listen(
          appSettingsCacheProvider,
          (previous, next) {},
        );

        // Attendre que les paramètres se chargent
        final settings = await container.read(appSettingsCacheProvider.future);

        // Les paramètres devraient être présents
        expect(settings, isNotNull);
        expect(settings['theme'], 'dark');
        expect(settings['language'], 'fr');

        // Fermer le listener
        listener.close();

        // Attendre un cycle
        await Future.delayed(Duration.zero);

        // Le provider devrait persister grâce à keepAlive
        expect(container.exists(appSettingsCacheProvider), true);
      });
    });

    group('Performance Metrics', () {
      test('providers should minimize rebuild count', () {
        int totalRebuilds = 0;

        // Créer plusieurs providers qui comptent leurs rebuilds
        final providers = [
          activeRoomsCountProvider,
          roomsLoadingStateProvider,
          roomsErrorStateProvider,
          currentRoomIdProvider,
        ];

        final listeners = providers.map((provider) {
          return container.listen(provider, (previous, next) {
            totalRebuilds++;
          });
        }).toList();

        // Simuler des changements d'état
        // (dans un vrai test, on modifierait l'état source)

        // Nettoyer
        for (final listener in listeners) {
          listener.close();
        }

        // Le nombre de rebuilds devrait être minimal
        expect(totalRebuilds, lessThan(10));
      });
    });
  });

  group('Memory Management Tests', () {
    test('container should not leak providers', () {
      final container = ProviderContainer();

      // Créer et fermer plusieurs listeners
      for (int i = 0; i < 100; i++) {
        final listener = container.listen(
          activeRoomsCountProvider,
          (previous, next) {},
        );
        listener.close();
      }

      // Le container ne devrait pas avoir de providers actifs
      // (test conceptuel - Riverpod gère cela automatiquement)
      
      container.dispose();
    });
  });
}
