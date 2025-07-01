// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      lastSeenAt: json['lastSeenAt'] == null
          ? null
          : DateTime.parse(json['lastSeenAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      preferences: json['preferences'] == null
          ? null
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'createdAt': instance.createdAt.toIso8601String(),
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
      'isOnline': instance.isOnline,
      'isEmailVerified': instance.isEmailVerified,
      'preferences': instance.preferences,
    };

_UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    _UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'fr',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableSounds: json['enableSounds'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      enableReadReceipts: json['enableReadReceipts'] as bool? ?? true,
      enableTypingIndicators: json['enableTypingIndicators'] as bool? ?? true,
      enableOnlineStatus: json['enableOnlineStatus'] as bool? ?? true,
      autoDeleteMessages: json['autoDeleteMessages'] as bool? ?? false,
      autoDeleteDuration: json['autoDeleteDuration'] == null
          ? null
          : Duration(microseconds: (json['autoDeleteDuration'] as num).toInt()),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      enableBiometricAuth: json['enableBiometricAuth'] as bool? ?? false,
      sessionTimeout: json['sessionTimeout'] == null
          ? const Duration(hours: 24)
          : Duration(microseconds: (json['sessionTimeout'] as num).toInt()),
    );

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'language': instance.language,
      'enableNotifications': instance.enableNotifications,
      'enableSounds': instance.enableSounds,
      'enableVibration': instance.enableVibration,
      'enableReadReceipts': instance.enableReadReceipts,
      'enableTypingIndicators': instance.enableTypingIndicators,
      'enableOnlineStatus': instance.enableOnlineStatus,
      'autoDeleteMessages': instance.autoDeleteMessages,
      'autoDeleteDuration': instance.autoDeleteDuration?.inMicroseconds,
      'fontSize': instance.fontSize,
      'enableBiometricAuth': instance.enableBiometricAuth,
      'sessionTimeout': instance.sessionTimeout.inMicroseconds,
    };
