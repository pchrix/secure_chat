import 'package:flutter/foundation.dart';

/// Configuration sécurisée de l'application
class AppConfig {
  // Variables d'environnement pour sécuriser les credentials
  static String get supabaseUrl {
    const String url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    
    if (url.isEmpty) {
      throw Exception(
        'SUPABASE_URL non définie. Veuillez configurer la variable d\'environnement.',
      );
    }
    
    return url;
  }

  static String get supabaseAnonKey {
    const String key = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    
    if (key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY non définie. Veuillez configurer la variable d\'environnement.',
      );
    }
    
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
      throw Exception('Configuration Supabase requise. Consultez le README.md pour les instructions.');
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
        print('📋 Configurez SUPABASE_ANON_KEY dans les variables d\'environnement');
      }
      // Retourner une clé vide pour forcer le mode offline
      throw Exception('Configuration Supabase requise. Consultez le README.md pour les instructions.');
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
}