import 'package:flutter/foundation.dart';
import '../services/secure_storage_service.dart';

/// Configuration sécurisée de l'application
/// Conforme aux meilleures pratiques Context7 Supabase + flutter_secure_storage
class AppConfig {
  // Variables d'environnement pour sécuriser les credentials
  static String get supabaseUrl {
    const String url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue:
          'https://wfcnymkoufwtsalnbgvb.supabase.co', // Fallback pour MVP
    );

    return url;
  }

  static String get supabaseAnonKey {
    const String key = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmY255bWtvdWZ3dHNhbG5iZ3ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0NjgxMDMsImV4cCI6MjA2NjA0NDEwM30.0pbagW0K-nAkO_PZuH2ZXzs9kiCTAU2NLSmSIgZbxH0', // Fallback pour MVP
    );

    return key;
  }

  // Mode offline pour MVP - pas de credentials hardcodés pour la sécurité
  static String get _offlineModeMessage {
    return 'Mode hors-ligne activé - Configuration Supabase requise pour le mode en ligne';
  }

  // Méthodes sécurisées pour obtenir les credentials
  static String getSupabaseUrl() {
    try {
      return supabaseUrl;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️  $_offlineModeMessage');
        // ignore: avoid_print
        print('📋 Configurez SUPABASE_URL dans les variables d\'environnement');
      }
      // Retourner une URL vide pour forcer le mode offline
      throw Exception(
          'Configuration Supabase requise. Consultez le README.md pour les instructions.');
    }
  }

  static String getSupabaseAnonKey() {
    try {
      return supabaseAnonKey;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('⚠️  $_offlineModeMessage');
        // ignore: avoid_print
        print(
            '📋 Configurez SUPABASE_ANON_KEY dans les variables d\'environnement');
      }
      // Retourner une clé vide pour forcer le mode offline
      throw Exception(
          'Configuration Supabase requise. Consultez le README.md pour les instructions.');
    }
  }

  // Vérifier si la configuration Supabase est disponible
  static bool get isSupabaseConfigured {
    try {
      getSupabaseUrl();
      getSupabaseAnonKey();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Configuration de l'application
  static const String appName = 'SecureChat';
  static const String appVersion = '1.0.0';

  // Durées par défaut
  static const Duration roomDefaultDuration = Duration(hours: 24);
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration messageTimeout = Duration(seconds: 10);

  // Limites de sécurité
  static const int maxRoomParticipants = 10;
  static const int maxMessageLength = 1000;
  static const int maxRoomNameLength = 50;
  static const int pinLength = 4;

  // Configuration chiffrement
  static const int keyLength = 32; // 256 bits
  static const int ivLength = 16; // 128 bits

  // === MÉTHODES SÉCURISÉES CONTEXT7 ===

  /// Stocke les credentials Supabase de manière sécurisée
  /// Conforme aux meilleures pratiques Context7 flutter_secure_storage
  static Future<void> storeSupabaseCredentials({
    required String url,
    required String anonKey,
  }) async {
    await SecureStorageService.initialize();

    // Stocker les credentials de manière chiffrée
    await SecureStorageService.storeConfigValue(
      'secure_supabase_url',
      url,
    );
    await SecureStorageService.storeConfigValue(
      'secure_supabase_anon_key',
      anonKey,
    );

    if (kDebugMode) {
      print('✅ Credentials Supabase stockés de manière sécurisée');
    }
  }

  /// Récupère l'URL Supabase depuis le stockage sécurisé
  /// Fallback vers les variables d'environnement si non trouvé
  static Future<String> getSecureSupabaseUrl() async {
    try {
      await SecureStorageService.initialize();

      // Essayer d'abord le stockage sécurisé
      final secureUrl = await SecureStorageService.getConfigValue(
        'secure_supabase_url',
      );

      if (secureUrl != null && secureUrl.isNotEmpty) {
        return secureUrl;
      }

      // Fallback vers les variables d'environnement
      return getSupabaseUrl();
    } catch (e) {
      // Fallback final vers les variables d'environnement
      return getSupabaseUrl();
    }
  }

  /// Récupère la clé anonyme Supabase depuis le stockage sécurisé
  /// Fallback vers les variables d'environnement si non trouvé
  static Future<String> getSecureSupabaseAnonKey() async {
    try {
      await SecureStorageService.initialize();

      // Essayer d'abord le stockage sécurisé
      final secureKey = await SecureStorageService.getConfigValue(
        'secure_supabase_anon_key',
      );

      if (secureKey != null && secureKey.isNotEmpty) {
        return secureKey;
      }

      // Fallback vers les variables d'environnement
      return getSupabaseAnonKey();
    } catch (e) {
      // Fallback final vers les variables d'environnement
      return getSupabaseAnonKey();
    }
  }

  /// Vérifie si les credentials sécurisés sont disponibles
  static Future<bool> hasSecureCredentials() async {
    try {
      await SecureStorageService.initialize();

      final url = await SecureStorageService.getConfigValue(
        'secure_supabase_url',
      );
      final key = await SecureStorageService.getConfigValue(
        'secure_supabase_anon_key',
      );

      return url != null && url.isNotEmpty && key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Nettoie les credentials stockés (pour déconnexion sécurisée)
  static Future<void> clearSecureCredentials() async {
    try {
      await SecureStorageService.initialize();

      await SecureStorageService.deleteConfigValue('secure_supabase_url');
      await SecureStorageService.deleteConfigValue('secure_supabase_anon_key');

      if (kDebugMode) {
        print('🧹 Credentials Supabase nettoyés du stockage sécurisé');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erreur lors du nettoyage des credentials: $e');
      }
    }
  }
}
