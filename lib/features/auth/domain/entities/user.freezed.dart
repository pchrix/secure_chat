// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {
  /// Identifiant unique de l'utilisateur
  String get id;

  /// Adresse email de l'utilisateur
  String get email;

  /// Nom d'utilisateur unique
  String get username;

  /// Date de création du compte
  DateTime get createdAt;

  /// Nom d'affichage optionnel
  String? get displayName;

  /// URL de l'avatar de l'utilisateur
  String? get avatarUrl;

  /// Dernière fois que l'utilisateur a été vu en ligne
  DateTime? get lastSeenAt;

  /// Indique si l'utilisateur est actuellement en ligne
  bool get isOnline;

  /// Indique si l'email de l'utilisateur est vérifié
  bool get isEmailVerified;

  /// Préférences utilisateur
  UserPreferences? get preferences;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserCopyWith<User> get copyWith =>
      _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is User &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      username,
      createdAt,
      displayName,
      avatarUrl,
      lastSeenAt,
      isOnline,
      isEmailVerified,
      preferences);

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, createdAt: $createdAt, displayName: $displayName, avatarUrl: $avatarUrl, lastSeenAt: $lastSeenAt, isOnline: $isOnline, isEmailVerified: $isEmailVerified, preferences: $preferences)';
  }
}

/// @nodoc
abstract mixin class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) _then) =
      _$UserCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      String username,
      DateTime createdAt,
      String? displayName,
      String? avatarUrl,
      DateTime? lastSeenAt,
      bool isOnline,
      bool isEmailVerified,
      UserPreferences? preferences});

  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserCopyWithImpl<$Res> implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? createdAt = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? lastSeenAt = freezed,
    Object? isOnline = null,
    Object? isEmailVerified = null,
    Object? preferences = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeenAt: freezed == lastSeenAt
          ? _self.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _self.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      preferences: freezed == preferences
          ? _self.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
    ));
  }

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_self.preferences!, (value) {
      return _then(_self.copyWith(preferences: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _User extends User {
  const _User(
      {required this.id,
      required this.email,
      required this.username,
      required this.createdAt,
      this.displayName,
      this.avatarUrl,
      this.lastSeenAt,
      this.isOnline = false,
      this.isEmailVerified = false,
      this.preferences})
      : super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Identifiant unique de l'utilisateur
  @override
  final String id;

  /// Adresse email de l'utilisateur
  @override
  final String email;

  /// Nom d'utilisateur unique
  @override
  final String username;

  /// Date de création du compte
  @override
  final DateTime createdAt;

  /// Nom d'affichage optionnel
  @override
  final String? displayName;

  /// URL de l'avatar de l'utilisateur
  @override
  final String? avatarUrl;

  /// Dernière fois que l'utilisateur a été vu en ligne
  @override
  final DateTime? lastSeenAt;

  /// Indique si l'utilisateur est actuellement en ligne
  @override
  @JsonKey()
  final bool isOnline;

  /// Indique si l'email de l'utilisateur est vérifié
  @override
  @JsonKey()
  final bool isEmailVerified;

  /// Préférences utilisateur
  @override
  final UserPreferences? preferences;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserCopyWith<_User> get copyWith =>
      __$UserCopyWithImpl<_User>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _User &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      username,
      createdAt,
      displayName,
      avatarUrl,
      lastSeenAt,
      isOnline,
      isEmailVerified,
      preferences);

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, createdAt: $createdAt, displayName: $displayName, avatarUrl: $avatarUrl, lastSeenAt: $lastSeenAt, isOnline: $isOnline, isEmailVerified: $isEmailVerified, preferences: $preferences)';
  }
}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) =
      __$UserCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String username,
      DateTime createdAt,
      String? displayName,
      String? avatarUrl,
      DateTime? lastSeenAt,
      bool isOnline,
      bool isEmailVerified,
      UserPreferences? preferences});

  @override
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$UserCopyWithImpl<$Res> implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = null,
    Object? createdAt = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? lastSeenAt = freezed,
    Object? isOnline = null,
    Object? isEmailVerified = null,
    Object? preferences = freezed,
  }) {
    return _then(_User(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      displayName: freezed == displayName
          ? _self.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastSeenAt: freezed == lastSeenAt
          ? _self.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      isEmailVerified: null == isEmailVerified
          ? _self.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      preferences: freezed == preferences
          ? _self.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
    ));
  }

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_self.preferences!, (value) {
      return _then(_self.copyWith(preferences: value));
    });
  }
}

/// @nodoc
mixin _$UserPreferences {
  /// Thème de l'application ('light', 'dark', 'system')
  String get theme;

  /// Langue de l'interface
  String get language;

  /// Activer les notifications
  bool get enableNotifications;

  /// Activer les sons
  bool get enableSounds;

  /// Activer les vibrations
  bool get enableVibration;

  /// Activer les accusés de lecture
  bool get enableReadReceipts;

  /// Activer les indicateurs de frappe
  bool get enableTypingIndicators;

  /// Afficher le statut en ligne
  bool get enableOnlineStatus;

  /// Suppression automatique des messages
  bool get autoDeleteMessages;

  /// Durée avant suppression automatique
  Duration? get autoDeleteDuration;

  /// Taille de police
  double get fontSize;

  /// Authentification biométrique
  bool get enableBiometricAuth;

  /// Timeout de session
  Duration get sessionTimeout;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      _$UserPreferencesCopyWithImpl<UserPreferences>(
          this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserPreferences &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.enableSounds, enableSounds) ||
                other.enableSounds == enableSounds) &&
            (identical(other.enableVibration, enableVibration) ||
                other.enableVibration == enableVibration) &&
            (identical(other.enableReadReceipts, enableReadReceipts) ||
                other.enableReadReceipts == enableReadReceipts) &&
            (identical(other.enableTypingIndicators, enableTypingIndicators) ||
                other.enableTypingIndicators == enableTypingIndicators) &&
            (identical(other.enableOnlineStatus, enableOnlineStatus) ||
                other.enableOnlineStatus == enableOnlineStatus) &&
            (identical(other.autoDeleteMessages, autoDeleteMessages) ||
                other.autoDeleteMessages == autoDeleteMessages) &&
            (identical(other.autoDeleteDuration, autoDeleteDuration) ||
                other.autoDeleteDuration == autoDeleteDuration) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.enableBiometricAuth, enableBiometricAuth) ||
                other.enableBiometricAuth == enableBiometricAuth) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      theme,
      language,
      enableNotifications,
      enableSounds,
      enableVibration,
      enableReadReceipts,
      enableTypingIndicators,
      enableOnlineStatus,
      autoDeleteMessages,
      autoDeleteDuration,
      fontSize,
      enableBiometricAuth,
      sessionTimeout);

  @override
  String toString() {
    return 'UserPreferences(theme: $theme, language: $language, enableNotifications: $enableNotifications, enableSounds: $enableSounds, enableVibration: $enableVibration, enableReadReceipts: $enableReadReceipts, enableTypingIndicators: $enableTypingIndicators, enableOnlineStatus: $enableOnlineStatus, autoDeleteMessages: $autoDeleteMessages, autoDeleteDuration: $autoDeleteDuration, fontSize: $fontSize, enableBiometricAuth: $enableBiometricAuth, sessionTimeout: $sessionTimeout)';
  }
}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) _then) =
      _$UserPreferencesCopyWithImpl;
  @useResult
  $Res call(
      {String theme,
      String language,
      bool enableNotifications,
      bool enableSounds,
      bool enableVibration,
      bool enableReadReceipts,
      bool enableTypingIndicators,
      bool enableOnlineStatus,
      bool autoDeleteMessages,
      Duration? autoDeleteDuration,
      double fontSize,
      bool enableBiometricAuth,
      Duration sessionTimeout});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? language = null,
    Object? enableNotifications = null,
    Object? enableSounds = null,
    Object? enableVibration = null,
    Object? enableReadReceipts = null,
    Object? enableTypingIndicators = null,
    Object? enableOnlineStatus = null,
    Object? autoDeleteMessages = null,
    Object? autoDeleteDuration = freezed,
    Object? fontSize = null,
    Object? enableBiometricAuth = null,
    Object? sessionTimeout = null,
  }) {
    return _then(_self.copyWith(
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      enableNotifications: null == enableNotifications
          ? _self.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSounds: null == enableSounds
          ? _self.enableSounds
          : enableSounds // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _self.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReadReceipts: null == enableReadReceipts
          ? _self.enableReadReceipts
          : enableReadReceipts // ignore: cast_nullable_to_non_nullable
              as bool,
      enableTypingIndicators: null == enableTypingIndicators
          ? _self.enableTypingIndicators
          : enableTypingIndicators // ignore: cast_nullable_to_non_nullable
              as bool,
      enableOnlineStatus: null == enableOnlineStatus
          ? _self.enableOnlineStatus
          : enableOnlineStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteMessages: null == autoDeleteMessages
          ? _self.autoDeleteMessages
          : autoDeleteMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteDuration: freezed == autoDeleteDuration
          ? _self.autoDeleteDuration
          : autoDeleteDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableBiometricAuth: null == enableBiometricAuth
          ? _self.enableBiometricAuth
          : enableBiometricAuth // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionTimeout: null == sessionTimeout
          ? _self.sessionTimeout
          : sessionTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _UserPreferences extends UserPreferences {
  const _UserPreferences(
      {this.theme = 'system',
      this.language = 'fr',
      this.enableNotifications = true,
      this.enableSounds = true,
      this.enableVibration = true,
      this.enableReadReceipts = true,
      this.enableTypingIndicators = true,
      this.enableOnlineStatus = true,
      this.autoDeleteMessages = false,
      this.autoDeleteDuration,
      this.fontSize = 16.0,
      this.enableBiometricAuth = false,
      this.sessionTimeout = const Duration(hours: 24)})
      : super._();
  factory _UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  /// Thème de l'application ('light', 'dark', 'system')
  @override
  @JsonKey()
  final String theme;

  /// Langue de l'interface
  @override
  @JsonKey()
  final String language;

  /// Activer les notifications
  @override
  @JsonKey()
  final bool enableNotifications;

  /// Activer les sons
  @override
  @JsonKey()
  final bool enableSounds;

  /// Activer les vibrations
  @override
  @JsonKey()
  final bool enableVibration;

  /// Activer les accusés de lecture
  @override
  @JsonKey()
  final bool enableReadReceipts;

  /// Activer les indicateurs de frappe
  @override
  @JsonKey()
  final bool enableTypingIndicators;

  /// Afficher le statut en ligne
  @override
  @JsonKey()
  final bool enableOnlineStatus;

  /// Suppression automatique des messages
  @override
  @JsonKey()
  final bool autoDeleteMessages;

  /// Durée avant suppression automatique
  @override
  final Duration? autoDeleteDuration;

  /// Taille de police
  @override
  @JsonKey()
  final double fontSize;

  /// Authentification biométrique
  @override
  @JsonKey()
  final bool enableBiometricAuth;

  /// Timeout de session
  @override
  @JsonKey()
  final Duration sessionTimeout;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserPreferencesCopyWith<_UserPreferences> get copyWith =>
      __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserPreferencesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserPreferences &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.enableSounds, enableSounds) ||
                other.enableSounds == enableSounds) &&
            (identical(other.enableVibration, enableVibration) ||
                other.enableVibration == enableVibration) &&
            (identical(other.enableReadReceipts, enableReadReceipts) ||
                other.enableReadReceipts == enableReadReceipts) &&
            (identical(other.enableTypingIndicators, enableTypingIndicators) ||
                other.enableTypingIndicators == enableTypingIndicators) &&
            (identical(other.enableOnlineStatus, enableOnlineStatus) ||
                other.enableOnlineStatus == enableOnlineStatus) &&
            (identical(other.autoDeleteMessages, autoDeleteMessages) ||
                other.autoDeleteMessages == autoDeleteMessages) &&
            (identical(other.autoDeleteDuration, autoDeleteDuration) ||
                other.autoDeleteDuration == autoDeleteDuration) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.enableBiometricAuth, enableBiometricAuth) ||
                other.enableBiometricAuth == enableBiometricAuth) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      theme,
      language,
      enableNotifications,
      enableSounds,
      enableVibration,
      enableReadReceipts,
      enableTypingIndicators,
      enableOnlineStatus,
      autoDeleteMessages,
      autoDeleteDuration,
      fontSize,
      enableBiometricAuth,
      sessionTimeout);

  @override
  String toString() {
    return 'UserPreferences(theme: $theme, language: $language, enableNotifications: $enableNotifications, enableSounds: $enableSounds, enableVibration: $enableVibration, enableReadReceipts: $enableReadReceipts, enableTypingIndicators: $enableTypingIndicators, enableOnlineStatus: $enableOnlineStatus, autoDeleteMessages: $autoDeleteMessages, autoDeleteDuration: $autoDeleteDuration, fontSize: $fontSize, enableBiometricAuth: $enableBiometricAuth, sessionTimeout: $sessionTimeout)';
  }
}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(
          _UserPreferences value, $Res Function(_UserPreferences) _then) =
      __$UserPreferencesCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String theme,
      String language,
      bool enableNotifications,
      bool enableSounds,
      bool enableVibration,
      bool enableReadReceipts,
      bool enableTypingIndicators,
      bool enableOnlineStatus,
      bool autoDeleteMessages,
      Duration? autoDeleteDuration,
      double fontSize,
      bool enableBiometricAuth,
      Duration sessionTimeout});
}

/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? theme = null,
    Object? language = null,
    Object? enableNotifications = null,
    Object? enableSounds = null,
    Object? enableVibration = null,
    Object? enableReadReceipts = null,
    Object? enableTypingIndicators = null,
    Object? enableOnlineStatus = null,
    Object? autoDeleteMessages = null,
    Object? autoDeleteDuration = freezed,
    Object? fontSize = null,
    Object? enableBiometricAuth = null,
    Object? sessionTimeout = null,
  }) {
    return _then(_UserPreferences(
      theme: null == theme
          ? _self.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      enableNotifications: null == enableNotifications
          ? _self.enableNotifications
          : enableNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSounds: null == enableSounds
          ? _self.enableSounds
          : enableSounds // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _self.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      enableReadReceipts: null == enableReadReceipts
          ? _self.enableReadReceipts
          : enableReadReceipts // ignore: cast_nullable_to_non_nullable
              as bool,
      enableTypingIndicators: null == enableTypingIndicators
          ? _self.enableTypingIndicators
          : enableTypingIndicators // ignore: cast_nullable_to_non_nullable
              as bool,
      enableOnlineStatus: null == enableOnlineStatus
          ? _self.enableOnlineStatus
          : enableOnlineStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteMessages: null == autoDeleteMessages
          ? _self.autoDeleteMessages
          : autoDeleteMessages // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteDuration: freezed == autoDeleteDuration
          ? _self.autoDeleteDuration
          : autoDeleteDuration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableBiometricAuth: null == enableBiometricAuth
          ? _self.enableBiometricAuth
          : enableBiometricAuth // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionTimeout: null == sessionTimeout
          ? _self.sessionTimeout
          : sessionTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

// dart format on
