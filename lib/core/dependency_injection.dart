/// 🏗️ Configuration de l'injection de dépendances avec Riverpod
///
/// Ce fichier configure l'injection de dépendances pour toute l'application,
/// permettant un découplage propre des services et une facilité de test.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des adaptateurs legacy
import '../utils/debug_helper.dart';
import '../utils/security_utils.dart';

// Imports des providers et services
import 'providers/service_providers.dart';
import 'services/debug_service.dart';
import 'services/security_service.dart';
import '../services/secure_encryption_service.dart';
import '../services/secure_storage_service.dart';
import '../services/room_service.dart';
import '../services/supabase_auth_service.dart';

/// Configuration de l'injection de dépendances pour l'application
class DependencyInjection {
  static ProviderContainer? _container;

  /// Initialiser l'injection de dépendances
  static ProviderContainer initialize() {
    _container = ProviderContainer();

    // Initialiser les adaptateurs legacy avec le container
    DebugHelper.initialize(_container!);
    SecurityUtils.initialize(_container!);

    return _container!;
  }

  /// Obtenir le container global (pour les cas d'urgence uniquement)
  static ProviderContainer get container {
    if (_container == null) {
      throw StateError(
          'DependencyInjection not initialized. Call DependencyInjection.initialize() first.');
    }
    return _container!;
  }

  /// Nettoyer les ressources
  static void dispose() {
    _container?.dispose();
    _container = null;
  }
}

/// Widget racine avec injection de dépendances
class DependencyInjectionApp extends StatelessWidget {
  const DependencyInjectionApp({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  final Widget child;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: child,
    );
  }
}

/// Mixin pour faciliter l'accès aux services dans les widgets
mixin ServiceMixin {
  /// Obtenir le service de debug
  IDebugService getDebugService(WidgetRef ref) {
    return ref.read(debugServiceProvider);
  }

  /// Obtenir le service de sécurité
  ISecurityService getSecurityService(WidgetRef ref) {
    return ref.read(securityServiceProvider);
  }

  /// Obtenir le service de chiffrement sécurisé
  SecureEncryptionService getEncryptionService(WidgetRef ref) {
    return ref.read(secureEncryptionServiceProvider);
  }

  /// Obtenir le service de stockage sécurisé
  SecureStorageService getSecureStorageService(WidgetRef ref) {
    return ref.read(secureStorageServiceProvider);
  }

  /// Obtenir le service de gestion des salons
  RoomService getRoomService(WidgetRef ref) {
    return ref.read(roomServiceProvider);
  }

  /// Obtenir le service d'authentification Supabase
  SupabaseAuthService getAuthService(WidgetRef ref) {
    return ref.read(supabaseAuthServiceProvider);
  }
}

/// Extension pour faciliter l'accès aux services dans les providers
extension ServiceExtension on Ref {
  /// Obtenir le service de debug
  IDebugService get debugService => read(debugServiceProvider);

  /// Obtenir le service de sécurité
  ISecurityService get securityService => read(securityServiceProvider);

  /// Obtenir le service de chiffrement sécurisé
  SecureEncryptionService get encryptionService =>
      read(secureEncryptionServiceProvider);

  /// Obtenir le service de stockage sécurisé
  SecureStorageService get secureStorageService =>
      read(secureStorageServiceProvider);

  /// Obtenir le service de gestion des salons
  RoomService get roomService => read(roomServiceProvider);

  /// Obtenir le service d'authentification Supabase
  SupabaseAuthService get authService => read(supabaseAuthServiceProvider);
}

/// Configuration pour les tests
class TestDependencyInjection {
  /// Créer un container de test avec des mocks
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: [
        // Override du mode test
        testModeProvider.overrideWith((ref) => true),
        ...overrides,
      ],
    );
  }

  /// Créer des overrides pour mocker les services
  static List<Override> createMockOverrides({
    IDebugService? mockDebugService,
    ISecurityService? mockSecurityService,
    SecureEncryptionService? mockEncryptionService,
    SecureStorageService? mockStorageService,
    RoomService? mockRoomService,
  }) {
    final overrides = <Override>[];

    if (mockDebugService != null) {
      overrides.add(debugServiceProvider.overrideWithValue(mockDebugService));
    }

    if (mockSecurityService != null) {
      overrides
          .add(securityServiceProvider.overrideWithValue(mockSecurityService));
    }

    if (mockEncryptionService != null) {
      overrides.add(secureEncryptionServiceProvider
          .overrideWithValue(mockEncryptionService));
    }

    if (mockStorageService != null) {
      overrides.add(
          secureStorageServiceProvider.overrideWithValue(mockStorageService));
    }

    if (mockRoomService != null) {
      overrides.add(roomServiceProvider.overrideWithValue(mockRoomService));
    }

    return overrides;
  }
}

/// Utilitaires pour le diagnostic de l'injection de dépendances
class DIUtils {
  /// Vérifier que tous les services sont correctement injectés
  static Future<Map<String, bool>> checkServicesHealth(
      ProviderContainer container) async {
    final health = <String, bool>{};

    try {
      // Vérifier le service de debug
      container.read(debugServiceProvider);
      health['debug_service'] = true;

      // Vérifier le service de sécurité
      container.read(securityServiceProvider);
      health['security_service'] = true;

      // Vérifier le service de chiffrement
      container.read(secureEncryptionServiceProvider);
      health['encryption_service'] = true;

      // Vérifier le service de stockage
      container.read(secureStorageServiceProvider);
      health['storage_service'] = true;

      // Vérifier le service de gestion des salons
      container.read(roomServiceProvider);
      health['room_service'] = true;

      // Vérifier les providers de diagnostic
      try {
        await container.read(supabaseDiagnosticProvider.future);
        health['supabase_diagnostic'] = true;
      } catch (e) {
        health['supabase_diagnostic'] = false;
      }
    } catch (e) {
      health['error'] = false;
    }

    return health;
  }

  /// Afficher un rapport de santé des services
  static Future<void> printHealthReport(ProviderContainer container) async {
    final health = await checkServicesHealth(container);

    print('\n🏥 ===== RAPPORT DE SANTÉ DES SERVICES =====');
    health.forEach((service, isHealthy) {
      final status = isHealthy ? '✅' : '❌';
      print('  $status $service: ${isHealthy ? 'OK' : 'ERREUR'}');
    });

    final totalServices = health.length;
    final healthyServices = health.values.where((h) => h).length;
    final healthPercentage =
        totalServices > 0 ? (healthyServices / totalServices * 100).round() : 0;

    print(
        '\n📊 SANTÉ GLOBALE: $healthPercentage% ($healthyServices/$totalServices services OK)');
    print('============================================\n');
  }
}
