import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/secure_storage_service.dart';

/// Configuration sécurisée de l'application
/// Conforme aux meilleures pratiques Context7 Supabase + flutter_secure_storage
///
/// Hiérarchie de configuration (par ordre de priorité) :
/// 1. Variables d'environnement (--dart-define) - PRODUCTION
/// 2. Fichier .env (flutter_dotenv) - DÉVELOPPEMENT
/// 3. Stockage sécurisé (flutter_secure_storage) - RUNTIME
class AppConfig {
  static bool _isInitialized = false;

  /// Initialise la configuration en chargeant le fichier .env si disponible
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger le fichier .env pour le développement
      await dotenv.load(fileName: '.env');
      if (kDebugMode) {
        print('✅ Configuration .env chargée pour le développement');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'ℹ️ Fichier .env non trouvé - utilisation des variables d\'environnement uniquement');
      }
    }

    _isInitialized = true;
  }

  /// Obtient l'URL Supabase selon la hiérarchie de configuration
  static String get supabaseUrl {
    // 1. Priorité : Variables d'environnement (--dart-define)
    const String envUrl = String.fromEnvironment('SUPABASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Fallback : Fichier .env (développement)
    final String dotenvUrl = dotenv.env['SUPABASE_URL'] ?? '';
    if (dotenvUrl.isNotEmpty) {
      return dotenvUrl;
    }

    // 3. Erreur : Aucune configuration trouvée
    throw Exception('SUPABASE_URL non configurée. '
        'Utilisez --dart-define=SUPABASE_URL=... ou configurez le fichier .env');
  }

  /// Obtient la clé anonyme Supabase selon la hiérarchie de configuration
  static String get supabaseAnonKey {
    // 1. Priorité : Variables d'environnement (--dart-define)
    const String envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }

    // 2. Fallback : Fichier .env (développement)
    final String dotenvKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    if (dotenvKey.isNotEmpty) {
      return dotenvKey;
    }

    // 3. Erreur : Aucune configuration trouvée
    throw Exception('SUPABASE_ANON_KEY non configurée. '
        'Utilisez --dart-define=SUPABASE_ANON_KEY=... ou configurez le fichier .env');
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

  /// Obtient l'environnement actuel (development, staging, production)
  static String get environment {
    const String env = String.fromEnvironment('ENVIRONMENT');
    if (env.isNotEmpty) return env;

    final String dotenvEnv = dotenv.env['ENVIRONMENT'] ?? 'development';
    return dotenvEnv;
  }

  /// Vérifie si les logs de debug sont activés
  static bool get enableDebugLogs {
    const String env = String.fromEnvironment('ENABLE_DEBUG_LOGS');
    if (env.isNotEmpty) return env.toLowerCase() == 'true';

    final String dotenvValue = dotenv.env['ENABLE_DEBUG_LOGS'] ?? 'false';
    return dotenvValue.toLowerCase() == 'true';
  }

  // Configuration de l'application
  static String get appName {
    const String env = String.fromEnvironment('APP_NAME');
    if (env.isNotEmpty) return env;

    return dotenv.env['APP_NAME'] ?? 'SecureChat';
  }

  static String get appVersion {
    const String env = String.fromEnvironment('APP_VERSION');
    if (env.isNotEmpty) return env;

    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  // Durées par défaut
  static Duration get roomDefaultDuration {
    const String env = String.fromEnvironment('ROOM_DEFAULT_DURATION');
    if (env.isNotEmpty) {
      final int seconds = int.tryParse(env) ?? 86400;
      return Duration(seconds: seconds);
    }

    final String dotenvValue = dotenv.env['ROOM_DEFAULT_DURATION'] ?? '86400';
    final int seconds = int.tryParse(dotenvValue) ?? 86400;
    return Duration(seconds: seconds);
  }

  static Duration get connectionTimeout {
    const String env = String.fromEnvironment('CONNECTION_TIMEOUT');
    if (env.isNotEmpty) {
      final int seconds = int.tryParse(env) ?? 30;
      return Duration(seconds: seconds);
    }

    final String dotenvValue = dotenv.env['CONNECTION_TIMEOUT'] ?? '30';
    final int seconds = int.tryParse(dotenvValue) ?? 30;
    return Duration(seconds: seconds);
  }

  static Duration get messageTimeout {
    const String env = String.fromEnvironment('MESSAGE_TIMEOUT');
    if (env.isNotEmpty) {
      final int seconds = int.tryParse(env) ?? 10;
      return Duration(seconds: seconds);
    }

    final String dotenvValue = dotenv.env['MESSAGE_TIMEOUT'] ?? '10';
    final int seconds = int.tryParse(dotenvValue) ?? 10;
    return Duration(seconds: seconds);
  }

  // Limites de sécurité
  static int get maxRoomParticipants {
    const String env = String.fromEnvironment('MAX_ROOM_PARTICIPANTS');
    if (env.isNotEmpty) return int.tryParse(env) ?? 10;

    final String dotenvValue = dotenv.env['MAX_ROOM_PARTICIPANTS'] ?? '10';
    return int.tryParse(dotenvValue) ?? 10;
  }

  static int get maxMessageLength {
    const String env = String.fromEnvironment('MAX_MESSAGE_LENGTH');
    if (env.isNotEmpty) return int.tryParse(env) ?? 1000;

    final String dotenvValue = dotenv.env['MAX_MESSAGE_LENGTH'] ?? '1000';
    return int.tryParse(dotenvValue) ?? 1000;
  }

  static int get maxRoomNameLength {
    const String env = String.fromEnvironment('MAX_ROOM_NAME_LENGTH');
    if (env.isNotEmpty) return int.tryParse(env) ?? 50;

    final String dotenvValue = dotenv.env['MAX_ROOM_NAME_LENGTH'] ?? '50';
    return int.tryParse(dotenvValue) ?? 50;
  }

  static int get pinLength {
    const String env = String.fromEnvironment('PIN_LENGTH');
    if (env.isNotEmpty) return int.tryParse(env) ?? 4;

    final String dotenvValue = dotenv.env['PIN_LENGTH'] ?? '4';
    return int.tryParse(dotenvValue) ?? 4;
  }

  // Configuration chiffrement
  static int get keyLength {
    const String env = String.fromEnvironment('KEY_LENGTH');
    if (env.isNotEmpty) return int.tryParse(env) ?? 32;

    final String dotenvValue = dotenv.env['KEY_LENGTH'] ?? '32';
    return int.tryParse(dotenvValue) ?? 32;
  }

  static int get ivLength {
    const String env = String.fromEnvironment('IV_LENGTH');
    if (env.isNotEmpty) return int.tryParse(env) ?? 16;

    final String dotenvValue = dotenv.env['IV_LENGTH'] ?? '16';
    return int.tryParse(dotenvValue) ?? 16;
  }

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
