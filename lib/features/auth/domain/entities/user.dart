/// 👤 Entité User avec Freezed pour SecureChat
///
/// Modèle immutable pour les utilisateurs avec gestion d'état et authentification.
/// Conforme aux meilleures pratiques Context7 + Exa pour Freezed.

import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Statut de présence d'un utilisateur
enum UserPresenceStatus {
  /// Utilisateur en ligne
  online,

  /// Utilisateur absent (récemment en ligne)
  away,

  /// Utilisateur hors ligne
  offline,
}

/// Extension pour UserPresenceStatus avec labels, couleurs et icônes
extension UserPresenceStatusExtension on UserPresenceStatus {
  /// Obtient la couleur associée au statut
  String get colorHex {
    switch (this) {
      case UserPresenceStatus.online:
        return '#10B981'; // Vert
      case UserPresenceStatus.away:
        return '#F59E0B'; // Orange
      case UserPresenceStatus.offline:
        return '#6B7280'; // Gris
    }
  }

  /// Obtient le libellé du statut
  String get label {
    switch (this) {
      case UserPresenceStatus.online:
        return 'En ligne';
      case UserPresenceStatus.away:
        return 'Absent';
      case UserPresenceStatus.offline:
        return 'Hors ligne';
    }
  }

  /// Obtient l'icône associée au statut
  String get icon {
    switch (this) {
      case UserPresenceStatus.online:
        return '🟢';
      case UserPresenceStatus.away:
        return '🟡';
      case UserPresenceStatus.offline:
        return '⚫';
    }
  }
}

/// Modèle immutable User avec Freezed
@freezed
abstract class User with _$User {
  /// Constructeur privé pour méthodes personnalisées
  const User._();

  /// Factory constructor principal
  const factory User({
    /// Identifiant unique de l'utilisateur
    required String id,

    /// Adresse email de l'utilisateur
    required String email,

    /// Nom d'utilisateur unique
    required String username,

    /// Date de création du compte
    required DateTime createdAt,

    /// Nom d'affichage optionnel
    String? displayName,

    /// URL de l'avatar de l'utilisateur
    String? avatarUrl,

    /// Dernière fois que l'utilisateur a été vu en ligne
    DateTime? lastSeenAt,

    /// Indique si l'utilisateur est actuellement en ligne
    @Default(false) bool isOnline,

    /// Indique si l'email de l'utilisateur est vérifié
    @Default(false) bool isEmailVerified,

    /// Préférences utilisateur
    UserPreferences? preferences,
  }) = _User;

  /// Factory pour créer depuis JSON avec mapping personnalisé
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Factory pour créer un utilisateur avec des valeurs par défaut
  factory User.create({
    required String email,
    String? username,
    String? displayName,
    String? avatarUrl,
    UserPreferences? preferences,
  }) {
    final now = DateTime.now();
    final userId = _generateUserId();
    return User(
      id: userId,
      email: email,
      username: username ?? email.split('@').first,
      createdAt: now,
      displayName: displayName,
      avatarUrl: avatarUrl,
      preferences: preferences ?? const UserPreferences(),
    );
  }

  /// Générer un ID utilisateur unique
  static String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// Méthodes métier personnalisées

  /// Nom d'affichage effectif (displayName ou username)
  String get effectiveDisplayName => displayName ?? username;

  /// Vérifie si l'utilisateur a un avatar personnalisé
  bool get hasCustomAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Obtient l'URL de l'avatar ou une URL par défaut
  String getAvatarUrl({String? defaultUrl}) {
    if (hasCustomAvatar) return avatarUrl!;
    return defaultUrl ?? _generateDefaultAvatarUrl();
  }

  /// Vérifie si l'utilisateur était récemment en ligne (dans les 5 dernières minutes)
  bool get wasRecentlyOnline {
    if (isOnline) return true;
    if (lastSeenAt == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastSeenAt!);
    return difference.inMinutes <= 5;
  }

  /// Obtient le statut de présence de l'utilisateur
  UserPresenceStatus get presenceStatus {
    if (isOnline) return UserPresenceStatus.online;
    if (wasRecentlyOnline) return UserPresenceStatus.away;
    return UserPresenceStatus.offline;
  }

  /// Vérifie si l'utilisateur a un profil complet
  bool get hasCompleteProfile {
    return username.isNotEmpty &&
        displayName != null &&
        displayName!.isNotEmpty;
  }

  /// Vérifie si l'utilisateur est récent (créé dans les 7 derniers jours)
  bool get isNewUser {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  /// Obtient l'âge du compte en jours
  int get accountAgeInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Vérifie si l'utilisateur peut être considéré comme actif
  bool get isActiveUser {
    return isOnline || wasRecentlyOnline;
  }

  /// Marquer l'utilisateur comme en ligne
  User goOnline() {
    return copyWith(
      isOnline: true,
      lastSeenAt: DateTime.now(),
    );
  }

  /// Marquer l'utilisateur comme hors ligne
  User goOffline() {
    return copyWith(
      isOnline: false,
      lastSeenAt: DateTime.now(),
    );
  }

  /// Mettre à jour les préférences
  User updatePreferences(UserPreferences newPreferences) {
    return copyWith(preferences: newPreferences);
  }

  /// Vérifier l'email
  User verifyEmail() {
    return copyWith(isEmailVerified: true);
  }

  /// Mettre à jour le profil
  User updateProfile({
    String? displayName,
    String? avatarUrl,
  }) {
    return copyWith(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  /// Sérialiser vers JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Désérialiser depuis JSON string
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }

  /// Génère une URL d'avatar par défaut basée sur les initiales
  String _generateDefaultAvatarUrl() {
    final initials = _getInitials();
    // Utilise un service comme UI Avatars ou Gravatar
    return 'https://ui-avatars.com/api/?name=$initials&background=6366f1&color=ffffff&size=128';
  }

  /// Obtient les initiales de l'utilisateur
  String _getInitials() {
    final name = effectiveDisplayName;
    final words = name.split(' ');

    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }
}

/// Modèle immutable UserPreferences avec Freezed
@freezed
abstract class UserPreferences with _$UserPreferences {
  /// Constructeur privé pour méthodes personnalisées
  const UserPreferences._();

  /// Factory constructor principal
  const factory UserPreferences({
    /// Thème de l'application ('light', 'dark', 'system')
    @Default('system') String theme,

    /// Langue de l'interface
    @Default('fr') String language,

    /// Activer les notifications
    @Default(true) bool enableNotifications,

    /// Activer les sons
    @Default(true) bool enableSounds,

    /// Activer les vibrations
    @Default(true) bool enableVibration,

    /// Activer les accusés de lecture
    @Default(true) bool enableReadReceipts,

    /// Activer les indicateurs de frappe
    @Default(true) bool enableTypingIndicators,

    /// Afficher le statut en ligne
    @Default(true) bool enableOnlineStatus,

    /// Suppression automatique des messages
    @Default(false) bool autoDeleteMessages,

    /// Durée avant suppression automatique
    Duration? autoDeleteDuration,

    /// Taille de police
    @Default(16.0) double fontSize,

    /// Authentification biométrique
    @Default(false) bool enableBiometricAuth,

    /// Timeout de session
    @Default(Duration(hours: 24)) Duration sessionTimeout,
  }) = _UserPreferences;

  /// Factory pour créer depuis JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// Méthodes métier personnalisées

  /// Vérifie si les notifications sont activées
  bool get hasNotificationsEnabled => enableNotifications;

  /// Vérifie si l'authentification biométrique est disponible et activée
  bool get isBiometricAuthEnabled => enableBiometricAuth;

  /// Vérifie si le mode sombre est activé
  bool get isDarkMode => theme == 'dark';

  /// Vérifie si le mode clair est activé
  bool get isLightMode => theme == 'light';

  /// Vérifie si le mode système est activé
  bool get isSystemMode => theme == 'system';

  /// Obtient la taille de police formatée
  String get fontSizeLabel {
    if (fontSize <= 12) return 'Très petite';
    if (fontSize <= 14) return 'Petite';
    if (fontSize <= 16) return 'Normale';
    if (fontSize <= 18) return 'Grande';
    return 'Très grande';
  }

  /// Vérifie si les paramètres de confidentialité sont stricts
  bool get hasStrictPrivacySettings {
    return !enableReadReceipts &&
        !enableTypingIndicators &&
        !enableOnlineStatus;
  }

  /// Obtient le timeout de session en heures
  int get sessionTimeoutHours => sessionTimeout.inHours;

  /// Active le mode sombre
  UserPreferences enableDarkMode() {
    return copyWith(theme: 'dark');
  }

  /// Active le mode clair
  UserPreferences enableLightMode() {
    return copyWith(theme: 'light');
  }

  /// Active le mode système
  UserPreferences enableSystemMode() {
    return copyWith(theme: 'system');
  }

  /// Active toutes les notifications
  UserPreferences enableAllNotifications() {
    return copyWith(
      enableNotifications: true,
      enableSounds: true,
      enableVibration: true,
    );
  }

  /// Désactive toutes les notifications
  UserPreferences disableAllNotifications() {
    return copyWith(
      enableNotifications: false,
      enableSounds: false,
      enableVibration: false,
    );
  }

  /// Active les paramètres de confidentialité stricts
  UserPreferences enableStrictPrivacy() {
    return copyWith(
      enableReadReceipts: false,
      enableTypingIndicators: false,
      enableOnlineStatus: false,
    );
  }

  /// Désactive les paramètres de confidentialité stricts
  UserPreferences disableStrictPrivacy() {
    return copyWith(
      enableReadReceipts: true,
      enableTypingIndicators: true,
      enableOnlineStatus: true,
    );
  }
}
