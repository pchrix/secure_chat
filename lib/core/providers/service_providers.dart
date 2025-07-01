/// 🏗️ Providers centralisés pour l'injection de dépendances
///
/// Ce fichier contient tous les providers Riverpod pour les services,
/// permettant une injection de dépendances propre et testable.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des services
import '../../config/app_config.dart';
import '../../services/supabase_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/secure_encryption_service.dart';
import '../../services/encryption_service.dart';
import '../../services/room_service.dart';
import '../../services/room_key_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/supabase_room_service.dart';
import '../../services/unified_auth_service.dart';
import '../../services/secure_pin_service.dart';
import '../../services/auth_migration_service.dart';

// ============================================================================
// PROVIDERS DE CONFIGURATION
// ============================================================================

/// Provider pour la configuration de l'application
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig();
});

// ============================================================================
// PROVIDERS DE SERVICES DE BASE
// ============================================================================

/// Provider pour le service de stockage sécurisé
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider pour le service de stockage local
/// Avec injection de dépendances optionnelle
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final roomKeyService = ref.watch(roomKeyServiceProvider);
  return LocalStorageService(
    roomKeyService: roomKeyService,
  );
});

// ============================================================================
// PROVIDERS DE SERVICES DE CHIFFREMENT
// ============================================================================

/// Provider pour le service de chiffrement sécurisé (AES-256-GCM)
final secureEncryptionServiceProvider =
    Provider<SecureEncryptionService>((ref) {
  return SecureEncryptionService();
});

/// Provider pour le service de chiffrement legacy (pour compatibilité)
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// Provider pour le service de gestion des clés de salon
/// Avec injection de dépendances pure
final roomKeyServiceProvider = Provider<RoomKeyService>((ref) {
  final encryptionService = ref.watch(encryptionServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);

  return RoomKeyService(
    encryptionService: encryptionService,
    secureStorageService: secureStorageService,
  );
});

// ============================================================================
// PROVIDERS DE SERVICES D'AUTHENTIFICATION
// ============================================================================

/// Provider pour le service PIN sécurisé
/// Avec injection de dépendances pure
final securePinServiceProvider = Provider<SecurePinService>((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);

  return SecurePinService(
    secureStorageService: secureStorageService,
  );
});

/// Provider pour le service de migration d'authentification
/// Avec injection de dépendances pure
final authMigrationServiceProvider = Provider<AuthMigrationService>((ref) {
  final securePinService = ref.watch(securePinServiceProvider);

  return AuthMigrationService(
    securePinService: securePinService,
  );
});

/// Provider pour le service d'authentification unifié
/// Avec injection de dépendances pure
final unifiedAuthServiceProvider = Provider<UnifiedAuthService>((ref) {
  final securePinService = ref.watch(securePinServiceProvider);
  final authMigrationService = ref.watch(authMigrationServiceProvider);

  return UnifiedAuthService(
    securePinService: securePinService,
    authMigrationService: authMigrationService,
  );
});

// ============================================================================
// PROVIDERS DE SERVICES SUPABASE
// ============================================================================

/// Provider pour le service Supabase principal
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provider pour le service d'authentification Supabase
/// Avec injection de dépendances pure
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final supabaseClient = Supabase.instance.client;

  return SupabaseAuthService(
    supabaseClient: supabaseClient,
  );
});

/// Provider pour le service de gestion des salons Supabase
/// Avec injection de dépendances pure
final supabaseRoomServiceProvider = Provider<SupabaseRoomService>((ref) {
  final supabaseClient = Supabase.instance.client;
  final authService = ref.watch(supabaseAuthServiceProvider);

  return SupabaseRoomService(
    supabaseClient: supabaseClient,
    authService: authService,
  );
});

// ============================================================================
// PROVIDERS DE SERVICES MÉTIER
// ============================================================================

/// Provider pour le service de gestion des salons
/// Avec injection de dépendances pure
final roomServiceProvider = Provider<RoomService>((ref) {
  final roomKeyService = ref.watch(roomKeyServiceProvider);

  return RoomService(
    roomKeyService: roomKeyService,
  );
});

// ============================================================================
// PROVIDERS DÉRIVÉS ET UTILITAIRES
// ============================================================================

/// Provider pour vérifier si Supabase est configuré
/// Optimisé avec autoDispose car c'est une vérification ponctuelle
final isSupabaseConfiguredProvider = Provider.autoDispose<bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return AppConfig.isSupabaseConfigured;
});

/// Provider pour vérifier si Supabase est initialisé
/// Optimisé avec autoDispose car c'est une vérification ponctuelle
final isSupabaseInitializedProvider = Provider.autoDispose<bool>((ref) {
  // SupabaseService utilise encore des méthodes statiques
  return SupabaseService.isInitialized;
});

/// Provider pour vérifier si l'utilisateur est authentifié
/// Optimisé avec autoDispose car l'état peut changer fréquemment
final isAuthenticatedProvider = Provider.autoDispose<bool>((ref) {
  final authService = ref.watch(supabaseAuthServiceProvider);
  return authService.isAuthenticated;
});

/// Provider pour obtenir l'utilisateur actuel
/// Optimisé avec autoDispose car l'utilisateur peut changer
final currentUserProvider = Provider.autoDispose<dynamic>((ref) {
  final authService = ref.watch(supabaseAuthServiceProvider);
  return authService.currentUser;
});

// ============================================================================
// PROVIDERS DE DIAGNOSTIC ET DEBUG
// ============================================================================

/// Provider pour les informations de diagnostic Supabase
/// Optimisé avec autoDispose pour éviter les fuites mémoire
final supabaseDiagnosticProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final config = ref.watch(appConfigProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final authService = ref.watch(supabaseAuthServiceProvider);

  final result = {
    'config_url': AppConfig.supabaseUrl,
    'config_key_length': AppConfig.supabaseAnonKey.length,
    'config_available': AppConfig.isSupabaseConfigured,
    'service_initialized': SupabaseService.isInitialized,
    'service_online': SupabaseService.isOnlineMode,
    'auth_available': authService.isAuthenticated,
    'current_user': authService.currentUser?.id,
  };

  // Conserver le résultat si le diagnostic est réussi
  if (result['config_available'] == true &&
      result['service_initialized'] == true) {
    ref.keepAlive();
  }

  return result;
});

/// Provider pour les informations de diagnostic de création de salon
/// Optimisé avec autoDispose et keepAlive conditionnel
final roomCreationDiagnosticProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabaseDiag = await ref.watch(supabaseDiagnosticProvider.future);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  final result = {
    'supabase_ready': supabaseDiag['service_initialized'] == true &&
        supabaseDiag['service_online'] == true &&
        supabaseDiag['config_available'] == true,
    'auth_ready': isAuthenticated,
    'local_service_available': true,
    'creation_possible': true,
  };

  // Conserver le résultat si la création est possible
  if (result['creation_possible'] == true) {
    ref.keepAlive();
  }

  return result;
});

// ============================================================================
// PROVIDERS OPTIMISÉS AVEC FAMILY
// ============================================================================

/// Provider pour diagnostic spécifique par type de service
/// Optimisé avec family + autoDispose
final serviceDiagnosticProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, serviceType) async {
  switch (serviceType.toLowerCase()) {
    case 'supabase':
      return await ref.watch(supabaseDiagnosticProvider.future);
    case 'room_creation':
      return await ref.watch(roomCreationDiagnosticProvider.future);
    case 'encryption':
      // Retourner un diagnostic simplifié pour le chiffrement
      return {
        'service_type': 'encryption',
        'available': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    case 'storage':
      // Retourner un diagnostic simplifié pour le stockage
      return {
        'service_type': 'storage',
        'available': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    default:
      throw ArgumentError('Unknown service type: $serviceType');
  }
});

/// Provider pour données utilisateur par ID
/// Optimisé avec family + autoDispose + keepAlive conditionnel
final userDataProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, userId) async {
  if (userId.isEmpty) return null;

  // Vérifier que le service d'auth est disponible
  final authService = ref.watch(supabaseAuthServiceProvider);

  // Si c'est l'utilisateur actuel, conserver en cache
  if (authService.currentUser?.id == userId) {
    ref.keepAlive();
  }

  return {
    'id': userId,
    'timestamp': DateTime.now().toIso8601String(),
    'cached': true,
  };
});

/// Provider pour messages par salon
/// Optimisé avec family + autoDispose
final roomMessagesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, roomId) async {
  if (roomId.isEmpty) return [];

  // Simuler la récupération des messages
  await Future.delayed(const Duration(milliseconds: 100));

  return [
    {
      'id': 'msg1',
      'roomId': roomId,
      'content': 'Message de test',
      'timestamp': DateTime.now().toIso8601String(),
    }
  ];
});

// ============================================================================
// PROVIDERS POUR TESTS ET MOCKING
// ============================================================================

/// Provider pour override en mode test
/// Permet de remplacer facilement les services pour les tests
final testModeProvider = StateProvider<bool>((ref) => false);

/// Provider conditionnel pour le service de chiffrement
/// Utilise un mock en mode test, le vrai service sinon
final encryptionProvider = Provider<dynamic>((ref) {
  final isTestMode = ref.watch(testModeProvider);

  if (isTestMode) {
    // Retourner un mock pour les tests
    return MockEncryptionService();
  } else {
    // Retourner le vrai service
    return ref.watch(secureEncryptionServiceProvider);
  }
});

// ============================================================================
// MOCK SERVICES POUR TESTS
// ============================================================================

/// Mock du service de chiffrement pour les tests
class MockEncryptionService {
  static Future<List<int>> generateSecureKey() async {
    return List.generate(32, (index) => index);
  }

  static Future<String> encrypt(String plaintext, List<int> keyBytes) async {
    return 'mock_encrypted_$plaintext';
  }

  static Future<String> decrypt(String ciphertext, List<int> keyBytes) async {
    return ciphertext.replaceFirst('mock_encrypted_', '');
  }
}
