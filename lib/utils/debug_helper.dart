import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../services/supabase_service.dart';
import '../services/supabase_auth_service.dart';

/// Helper pour diagnostiquer les problèmes de l'application
class DebugHelper {
  /// Diagnostiquer les problèmes de configuration Supabase
  static Future<Map<String, dynamic>> diagnoseSupabase() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Vérifier la configuration
      diagnosis['config_url'] = AppConfig.supabaseUrl;
      diagnosis['config_key_length'] = AppConfig.supabaseAnonKey.length;
      diagnosis['config_available'] = AppConfig.isSupabaseConfigured;

      // Vérifier l'initialisation
      diagnosis['service_initialized'] = SupabaseService.isInitialized;
      diagnosis['service_online'] = SupabaseService.isOnlineMode;

      // Vérifier l'authentification
      diagnosis['auth_available'] = false // TODO: inject service;
      diagnosis['current_user'] = null // TODO: inject service;

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

  /// Diagnostiquer les problèmes de création de salon
  static Future<Map<String, dynamic>> diagnoseRoomCreation() async {
    final diagnosis = <String, dynamic>{};

    try {
      // Vérifier les prérequis
      diagnosis['supabase_ready'] = await _isSupabaseReady();
      diagnosis['auth_ready'] = false // TODO: inject service;
      diagnosis['local_service_available'] =
          true; // Service local toujours disponible
      diagnosis['creation_possible'] = true; // Possible via service local

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

  /// Vérifier si Supabase est prêt
  static Future<bool> _isSupabaseReady() async {
    try {
      return SupabaseService.isInitialized &&
          SupabaseService.isOnlineMode &&
          AppConfig.isSupabaseConfigured;
    } catch (e) {
      return false;
    }
  }

  /// Afficher un rapport complet de diagnostic
  static Future<void> printFullDiagnosis() async {
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
}
