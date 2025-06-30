/// 🎯 Constantes globales de l'application SecureChat
///
/// Centralise toutes les constantes utilisées à travers l'application
/// pour faciliter la maintenance et éviter la duplication.

class AppConstants {
  // 🚫 Constructeur privé pour empêcher l'instanciation
  AppConstants._();

  // 📱 Informations de l'application
  static const String appName = 'SecureChat';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Application de messagerie sécurisée avec chiffrement AES-256-GCM';

  // 🔐 Sécurité et chiffrement
  static const int keyLength = 32; // 256 bits pour AES-256
  static const int nonceLength = 12; // 96 bits pour GCM
  static const int pinLength = 6;
  static const int maxLoginAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // 🌐 Configuration réseau
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // 💾 Stockage local
  static const String secureStoragePrefix = 'securechat_';
  static const String userPrefsKey = 'user_preferences';
  static const String roomKeysPrefix = 'room_key_';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String pinHashKey = 'pin_hash';

  // 🎨 Interface utilisateur
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const double borderRadius = 12.0;
  static const double glassOpacity = 0.1;

  // 📱 Responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double minMobileWidth = 320.0; // iPhone SE

  // 📝 Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxMessageLength = 4000;
  static const int maxRoomNameLength = 50;

  // 🔄 Synchronisation
  static const Duration syncInterval = Duration(seconds: 30);
  static const Duration heartbeatInterval = Duration(seconds: 60);
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxSyncRetries = 5;

  // 📊 Performance
  static const int maxCachedMessages = 1000;
  static const int maxCachedRooms = 100;
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxConcurrentOperations = 5;

  // 🎯 Features flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableFileSharing = false; // Future feature
  static const bool enableVoiceMessages = false; // Future feature
  static const bool enableVideoCall = false; // Future feature

  // 🌍 Localisation
  static const String defaultLocale = 'fr';
  static const List<String> supportedLocales = ['fr', 'en'];

  // 🔍 Debug et logging
  static const bool enableDebugMode = true; // À désactiver en production
  static const bool enablePerformanceMonitoring = true;
  static const bool enableCrashReporting =
      false; // À configurer selon l'environnement

  // 📱 Notifications
  static const String notificationChannelId = 'securechat_messages';
  static const String notificationChannelName = 'Messages SecureChat';
  static const String notificationChannelDescription =
      'Notifications pour les nouveaux messages';

  // 🎨 Thème
  static const String defaultThemeMode = 'system'; // 'light', 'dark', 'system'
  static const bool enableGlassmorphism = true;
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;

  // 🔐 Sécurité avancée
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration inactivityTimeout = Duration(minutes: 30);
  static const bool enableScreenshotProtection = true;
  static const bool enableAppLockOnBackground = true;

  // 📈 Analytics (anonymisées)
  static const bool enableAnalytics = false; // Respecter la vie privée
  static const bool enableUsageStatistics = false;
  static const bool enablePerformanceMetrics = true;

  // 🚨 Erreurs et exceptions
  static const String genericErrorMessage =
      'Une erreur inattendue s\'est produite';
  static const String networkErrorMessage = 'Problème de connexion réseau';
  static const String authErrorMessage = 'Erreur d\'authentification';
  static const String encryptionErrorMessage = 'Erreur de chiffrement';

  // 🎯 URLs et endpoints (seront remplacés par les variables d'environnement)
  static const String defaultApiBaseUrl = 'https://api.securechat.app';
  static const String defaultWebSocketUrl = 'wss://ws.securechat.app';
  static const String supportUrl = 'https://support.securechat.app';
  static const String privacyPolicyUrl = 'https://securechat.app/privacy';
  static const String termsOfServiceUrl = 'https://securechat.app/terms';

  // 🔄 Migration et versioning
  static const int currentDatabaseVersion = 1;
  static const int currentConfigVersion = 1;
  static const String migrationPrefix = 'migration_';

  // 🎨 Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String iconPath = 'assets/images/icon.png';
  static const String splashImagePath = 'assets/images/splash.png';

  // 📱 Platform specific
  static const String androidPackageName = 'com.securechat.app';
  static const String iosAppId = 'com.securechat.app';
  static const String windowsAppId = 'SecureChat.App';

  // 🎯 Feature limits
  static const int maxRoomsPerUser = 100;
  static const int maxParticipantsPerRoom = 50;
  static const int maxMessagesPerBatch = 50;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB (future feature)
}

/// 🎨 Constantes spécifiques au thème
class ThemeConstants {
  ThemeConstants._();

  // Couleurs principales
  static const int primaryColorValue = 0xFF6366F1; // Indigo
  static const int secondaryColorValue = 0xFF8B5CF6; // Violet
  static const int accentColorValue = 0xFF06B6D4; // Cyan

  // Glassmorphism
  static const double glassBlur = 10.0;
  static const double glassBorder = 1.0;
  static const double glassOpacity = 0.1;
  static const double cardElevation = 8.0;

  // Espacements
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Rayons de bordure
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;

  // Tailles de police
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHeading = 32.0;
}

/// 🔐 Constantes de sécurité
class SecurityConstants {
  SecurityConstants._();

  // Algorithmes de chiffrement
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const String hashAlgorithm = 'SHA-256';
  static const String keyDerivationAlgorithm = 'PBKDF2';

  // Paramètres cryptographiques
  static const int pbkdf2Iterations = 100000;
  static const int saltLength = 32;
  static const int keyLength = 32; // 256 bits
  static const int nonceLength = 12; // 96 bits pour GCM

  // Validation de sécurité
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]';
  static const String pinPattern = r'^\d{6}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,30}$';

  // Timeouts de sécurité
  static const Duration authTokenExpiry = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  static const Duration sessionExpiry = Duration(hours: 8);
  static const Duration pinLockTimeout = Duration(minutes: 5);
}
