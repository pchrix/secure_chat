/// 🔍 Service de diagnostic découplé avec injection de dépendances
///
/// Ce service remplace DebugHelper en utilisant l'injection de dépendances
/// Riverpod pour découpler les services et faciliter les tests.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des providers
import '../providers/service_providers.dart';
import '../../services/secure_encryption_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/local_storage_service.dart';

/// Interface pour le service de diagnostic
abstract class IDebugService {
  Future<Map<String, dynamic>> diagnoseSupabase();
  Future<Map<String, dynamic>> diagnoseRoomCreation();
  Future<void> printFullDiagnosis();
}

/// Implémentation du service de diagnostic avec injection de dépendances
class DebugService implements IDebugService {
  const DebugService(this._ref);

  final Ref _ref;

  @override
  Future<Map<String, dynamic>> diagnoseSupabase() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Utiliser les providers pour obtenir les informations
      final supabaseDiag = await _ref.read(supabaseDiagnosticProvider.future);
      diagnosis.addAll(supabaseDiag);

      if (kDebugMode) {
        print('🔍 DIAGNOSTIC SUPABASE:');
        diagnosis.forEach((key, value) {
          print('  $key: $value');
        });
      }
    } catch (e) {
      diagnosis['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Erreur diagnostic Supabase: $e');
      }
    }

    return diagnosis;
  }

  @override
  Future<Map<String, dynamic>> diagnoseRoomCreation() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Utiliser les providers pour obtenir les informations
      final roomDiag = await _ref.read(roomCreationDiagnosticProvider.future);
      diagnosis.addAll(roomDiag);

      if (kDebugMode) {
        print('🔍 DIAGNOSTIC CRÉATION SALON:');
        diagnosis.forEach((key, value) {
          print('  $key: $value');
        });
      }
    } catch (e) {
      diagnosis['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Erreur diagnostic création salon: $e');
      }
    }

    return diagnosis;
  }

  @override
  Future<void> printFullDiagnosis() async {
    if (!kDebugMode) return;

    print('\n🔍 ===== DIAGNOSTIC COMPLET SECURECHAT =====');

    final supabaseDiag = await diagnoseSupabase();
    final roomDiag = await diagnoseRoomCreation();

    print('\n📊 RÉSUMÉ:');
    print('  Supabase configuré: ${supabaseDiag['config_available']}');
    print('  Service initialisé: ${supabaseDiag['service_initialized']}');
    print('  Mode en ligne: ${supabaseDiag['service_online']}');
    print('  Utilisateur connecté: ${supabaseDiag['auth_available']}');
    print('  Service local disponible: ${roomDiag['local_service_available']}');
    print('  Création salon possible: ${roomDiag['creation_possible']}');

    if (supabaseDiag.containsKey('error') || roomDiag.containsKey('error')) {
      print('\n❌ ERREURS DÉTECTÉES:');
      if (supabaseDiag.containsKey('error')) {
        print('  Supabase: ${supabaseDiag['error']}');
      }
      if (roomDiag.containsKey('error')) {
        print('  Création salon: ${roomDiag['error']}');
      }
    }

    print('============================================\n');
  }

  /// Méthodes utilitaires pour diagnostic spécifique

  /// Vérifier l'état des services de chiffrement
  Future<Map<String, dynamic>> diagnoseEncryption() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Vérifier que les services sont disponibles
      _ref.read(secureEncryptionServiceProvider);
      _ref.read(roomKeyServiceProvider);

      // Test de génération de clé
      final testKey = await SecureEncryptionService.generateSecureKey();
      diagnosis['key_generation'] = testKey.length == 32;

      // Test de chiffrement/déchiffrement
      const testMessage = 'Test de chiffrement';
      final encrypted =
          await SecureEncryptionService.encrypt(testMessage, testKey);
      final decrypted =
          await SecureEncryptionService.decrypt(encrypted, testKey);
      diagnosis['encryption_working'] = decrypted == testMessage;

      // État du service de clés
      diagnosis['room_key_service_initialized'] =
          true; // RoomKeyService.instance existe

      if (kDebugMode) {
        print('🔍 DIAGNOSTIC CHIFFREMENT:');
        diagnosis.forEach((key, value) {
          print('  $key: $value');
        });
      }
    } catch (e) {
      diagnosis['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Erreur diagnostic chiffrement: $e');
      }
    }

    return diagnosis;
  }

  /// Vérifier l'état des services de stockage
  Future<Map<String, dynamic>> diagnoseStorage() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Vérifier que les services sont disponibles
      _ref.read(secureStorageServiceProvider);
      _ref.read(localStorageServiceProvider);

      // Test de stockage sécurisé
      const testKey = 'test_key';
      const testValue = 'test_value';

      try {
        await SecureStorageService.setString(testKey, testValue);
        final readValue = await SecureStorageService.getString(testKey);
        diagnosis['secure_storage_working'] = readValue == testValue;
        await SecureStorageService.remove(testKey); // Nettoyage
      } catch (e) {
        diagnosis['secure_storage_working'] = false;
        diagnosis['secure_storage_error'] = e.toString();
      }

      // Test de stockage local
      try {
        final rooms = await LocalStorageService.getRooms();
        diagnosis['local_storage_working'] = true;
        diagnosis['local_rooms_count'] = rooms.length;
      } catch (e) {
        diagnosis['local_storage_working'] = false;
        diagnosis['local_storage_error'] = e.toString();
      }

      if (kDebugMode) {
        print('🔍 DIAGNOSTIC STOCKAGE:');
        diagnosis.forEach((key, value) {
          print('  $key: $value');
        });
      }
    } catch (e) {
      diagnosis['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Erreur diagnostic stockage: $e');
      }
    }

    return diagnosis;
  }

  /// Diagnostic complet de tous les services
  Future<Map<String, dynamic>> diagnoseAll() async {
    final allDiagnosis = <String, dynamic>{};

    try {
      final supabase = await diagnoseSupabase();
      final room = await diagnoseRoomCreation();
      final encryption = await diagnoseEncryption();
      final storage = await diagnoseStorage();

      allDiagnosis['supabase'] = supabase;
      allDiagnosis['room_creation'] = room;
      allDiagnosis['encryption'] = encryption;
      allDiagnosis['storage'] = storage;

      // Calcul d'un score de santé global
      int healthScore = 0;
      int totalChecks = 0;

      void checkBoolean(Map<String, dynamic> diag, String key) {
        if (diag.containsKey(key) && diag[key] is bool) {
          totalChecks++;
          if (diag[key] == true) healthScore++;
        }
      }

      checkBoolean(supabase, 'config_available');
      checkBoolean(supabase, 'service_initialized');
      checkBoolean(room, 'creation_possible');
      checkBoolean(encryption, 'encryption_working');
      checkBoolean(storage, 'secure_storage_working');
      checkBoolean(storage, 'local_storage_working');

      allDiagnosis['health_score'] =
          totalChecks > 0 ? (healthScore / totalChecks * 100).round() : 0;
      allDiagnosis['health_details'] =
          '$healthScore/$totalChecks checks passed';

      if (kDebugMode) {
        print(
            '\n🏥 SANTÉ GLOBALE: ${allDiagnosis['health_score']}% (${allDiagnosis['health_details']})');
      }
    } catch (e) {
      allDiagnosis['error'] = e.toString();
      if (kDebugMode) {
        print('❌ Erreur diagnostic complet: $e');
      }
    }

    return allDiagnosis;
  }
}

// ============================================================================
// PROVIDER POUR LE SERVICE DE DIAGNOSTIC
// ============================================================================

/// Provider pour le service de diagnostic avec injection de dépendances
final debugServiceProvider = Provider<IDebugService>((ref) {
  return DebugService(ref);
});

/// Provider pour diagnostic Supabase via le service
final debugSupabaseProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final debugService = ref.read(debugServiceProvider);
  return await debugService.diagnoseSupabase();
});

/// Provider pour diagnostic de création de salon via le service
final debugRoomCreationProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final debugService = ref.read(debugServiceProvider);
  return await debugService.diagnoseRoomCreation();
});

/// Provider pour diagnostic complet via le service
final debugAllProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final debugService = ref.read(debugServiceProvider) as DebugService;
  return await debugService.diagnoseAll();
});
