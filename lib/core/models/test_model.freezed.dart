// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestUser {
  String get id;
  String get name;
  @JsonKey(name: 'email_address')
  String get email;
  bool get isPremium;
  List<String> get tags;
  DateTime? get lastLoginAt;

  /// Create a copy of TestUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestUserCopyWith<TestUser> get copyWith =>
      _$TestUserCopyWithImpl<TestUser>(this as TestUser, _$identity);

  /// Serializes this TestUser to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestUser &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, isPremium,
      const DeepCollectionEquality().hash(tags), lastLoginAt);

  @override
  String toString() {
    return 'TestUser(id: $id, name: $name, email: $email, isPremium: $isPremium, tags: $tags, lastLoginAt: $lastLoginAt)';
  }
}

/// @nodoc
abstract mixin class $TestUserCopyWith<$Res> {
  factory $TestUserCopyWith(TestUser value, $Res Function(TestUser) _then) =
      _$TestUserCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'email_address') String email,
      bool isPremium,
      List<String> tags,
      DateTime? lastLoginAt});
}

/// @nodoc
class _$TestUserCopyWithImpl<$Res> implements $TestUserCopyWith<$Res> {
  _$TestUserCopyWithImpl(this._self, this._then);

  final TestUser _self;
  final $Res Function(TestUser) _then;

  /// Create a copy of TestUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? isPremium = null,
    Object? tags = null,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      isPremium: null == isPremium
          ? _self.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastLoginAt: freezed == lastLoginAt
          ? _self.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TestUser implements TestUser {
  const _TestUser(
      {required this.id,
      required this.name,
      @JsonKey(name: 'email_address') required this.email,
      this.isPremium = false,
      final List<String> tags = const [],
      this.lastLoginAt})
      : _tags = tags;
  factory _TestUser.fromJson(Map<String, dynamic> json) =>
      _$TestUserFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'email_address')
  final String email;
  @override
  @JsonKey()
  final bool isPremium;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime? lastLoginAt;

  /// Create a copy of TestUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TestUserCopyWith<_TestUser> get copyWith =>
      __$TestUserCopyWithImpl<_TestUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TestUserToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TestUser &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, isPremium,
      const DeepCollectionEquality().hash(_tags), lastLoginAt);

  @override
  String toString() {
    return 'TestUser(id: $id, name: $name, email: $email, isPremium: $isPremium, tags: $tags, lastLoginAt: $lastLoginAt)';
  }
}

/// @nodoc
abstract mixin class _$TestUserCopyWith<$Res>
    implements $TestUserCopyWith<$Res> {
  factory _$TestUserCopyWith(_TestUser value, $Res Function(_TestUser) _then) =
      __$TestUserCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'email_address') String email,
      bool isPremium,
      List<String> tags,
      DateTime? lastLoginAt});
}

/// @nodoc
class __$TestUserCopyWithImpl<$Res> implements _$TestUserCopyWith<$Res> {
  __$TestUserCopyWithImpl(this._self, this._then);

  final _TestUser _self;
  final $Res Function(_TestUser) _then;

  /// Create a copy of TestUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? isPremium = null,
    Object? tags = null,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_TestUser(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      isPremium: null == isPremium
          ? _self.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastLoginAt: freezed == lastLoginAt
          ? _self.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

TestApiResponse<T> _$TestApiResponseFromJson<T>(
    Map<String, dynamic> json, T Function(Object?) fromJsonT) {
  switch (json['type']) {
    case 'Success':
      return TestApiResponseSuccess<T>.fromJson(json, fromJsonT);
    case 'ErrorCase':
      return TestApiResponseError<T>.fromJson(json, fromJsonT);
    case 'Loading':
      return TestApiResponseLoading<T>.fromJson(json, fromJsonT);

    default:
      throw CheckedFromJsonException(json, 'type', 'TestApiResponse',
          'Invalid union type "${json['type']}"!');
  }
}

/// @nodoc
mixin _$TestApiResponse<T> {
  /// Serializes this TestApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TestApiResponse<T>);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TestApiResponse<$T>()';
  }
}

/// @nodoc
class $TestApiResponseCopyWith<T, $Res> {
  $TestApiResponseCopyWith(
      TestApiResponse<T> _, $Res Function(TestApiResponse<T>) __);
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class TestApiResponseSuccess<T> implements TestApiResponse<T> {
  const TestApiResponseSuccess(this.data, {final String? $type})
      : $type = $type ?? 'Success';
  factory TestApiResponseSuccess.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$TestApiResponseSuccessFromJson(json, fromJsonT);

  final T data;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of TestApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestApiResponseSuccessCopyWith<T, TestApiResponseSuccess<T>> get copyWith =>
      _$TestApiResponseSuccessCopyWithImpl<T, TestApiResponseSuccess<T>>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$TestApiResponseSuccessToJson<T>(this, toJsonT);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestApiResponseSuccess<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'TestApiResponse<$T>.success(data: $data)';
  }
}

/// @nodoc
abstract mixin class $TestApiResponseSuccessCopyWith<T, $Res>
    implements $TestApiResponseCopyWith<T, $Res> {
  factory $TestApiResponseSuccessCopyWith(TestApiResponseSuccess<T> value,
          $Res Function(TestApiResponseSuccess<T>) _then) =
      _$TestApiResponseSuccessCopyWithImpl;
  @useResult
  $Res call({T data});
}

/// @nodoc
class _$TestApiResponseSuccessCopyWithImpl<T, $Res>
    implements $TestApiResponseSuccessCopyWith<T, $Res> {
  _$TestApiResponseSuccessCopyWithImpl(this._self, this._then);

  final TestApiResponseSuccess<T> _self;
  final $Res Function(TestApiResponseSuccess<T>) _then;

  /// Create a copy of TestApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = freezed,
  }) {
    return _then(TestApiResponseSuccess<T>(
      freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class TestApiResponseError<T> implements TestApiResponse<T> {
  const TestApiResponseError(this.message, this.code, {final String? $type})
      : $type = $type ?? 'ErrorCase';
  factory TestApiResponseError.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$TestApiResponseErrorFromJson(json, fromJsonT);

  final String message;
  final int code;

  @JsonKey(name: 'type')
  final String $type;

  /// Create a copy of TestApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestApiResponseErrorCopyWith<T, TestApiResponseError<T>> get copyWith =>
      _$TestApiResponseErrorCopyWithImpl<T, TestApiResponseError<T>>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$TestApiResponseErrorToJson<T>(this, toJsonT);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestApiResponseError<T> &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() {
    return 'TestApiResponse<$T>.error(message: $message, code: $code)';
  }
}

/// @nodoc
abstract mixin class $TestApiResponseErrorCopyWith<T, $Res>
    implements $TestApiResponseCopyWith<T, $Res> {
  factory $TestApiResponseErrorCopyWith(TestApiResponseError<T> value,
          $Res Function(TestApiResponseError<T>) _then) =
      _$TestApiResponseErrorCopyWithImpl;
  @useResult
  $Res call({String message, int code});
}

/// @nodoc
class _$TestApiResponseErrorCopyWithImpl<T, $Res>
    implements $TestApiResponseErrorCopyWith<T, $Res> {
  _$TestApiResponseErrorCopyWithImpl(this._self, this._then);

  final TestApiResponseError<T> _self;
  final $Res Function(TestApiResponseError<T>) _then;

  /// Create a copy of TestApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = null,
  }) {
    return _then(TestApiResponseError<T>(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class TestApiResponseLoading<T> implements TestApiResponse<T> {
  const TestApiResponseLoading({final String? $type})
      : $type = $type ?? 'Loading';
  factory TestApiResponseLoading.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$TestApiResponseLoadingFromJson(json, fromJsonT);

  @JsonKey(name: 'type')
  final String $type;

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$TestApiResponseLoadingToJson<T>(this, toJsonT);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestApiResponseLoading<T>);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TestApiResponse<$T>.loading()';
  }
}

/// @nodoc
class $TestApiResponseLoadingCopyWith<T, $Res>
    implements $TestApiResponseCopyWith<T, $Res> {
  $TestApiResponseLoadingCopyWith(
      TestApiResponseLoading<T> _, $Res Function(TestApiResponseLoading<T>) __);
}

/// @nodoc
class _$TestApiResponseLoadingCopyWithImpl<T, $Res>
    implements $TestApiResponseLoadingCopyWith<T, $Res> {
  _$TestApiResponseLoadingCopyWithImpl(this._self, this._then);

  final TestApiResponseLoading<T> _self;
  final $Res Function(TestApiResponseLoading<T>) _then;
}

/// @nodoc
mixin _$TestSettings {
  String get language;
  bool get notifications;
  int get sessionTimeout;
  Map<String, dynamic> get preferences;
  DateTime? get updatedAt;

  /// Create a copy of TestSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestSettingsCopyWith<TestSettings> get copyWith =>
      _$TestSettingsCopyWithImpl<TestSettings>(
          this as TestSettings, _$identity);

  /// Serializes this TestSettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestSettings &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout) &&
            const DeepCollectionEquality()
                .equals(other.preferences, preferences) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      language,
      notifications,
      sessionTimeout,
      const DeepCollectionEquality().hash(preferences),
      updatedAt);

  @override
  String toString() {
    return 'TestSettings(language: $language, notifications: $notifications, sessionTimeout: $sessionTimeout, preferences: $preferences, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $TestSettingsCopyWith<$Res> {
  factory $TestSettingsCopyWith(
          TestSettings value, $Res Function(TestSettings) _then) =
      _$TestSettingsCopyWithImpl;
  @useResult
  $Res call(
      {String language,
      bool notifications,
      int sessionTimeout,
      Map<String, dynamic> preferences,
      DateTime? updatedAt});
}

/// @nodoc
class _$TestSettingsCopyWithImpl<$Res> implements $TestSettingsCopyWith<$Res> {
  _$TestSettingsCopyWithImpl(this._self, this._then);

  final TestSettings _self;
  final $Res Function(TestSettings) _then;

  /// Create a copy of TestSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? language = null,
    Object? notifications = null,
    Object? sessionTimeout = null,
    Object? preferences = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      notifications: null == notifications
          ? _self.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionTimeout: null == sessionTimeout
          ? _self.sessionTimeout
          : sessionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      preferences: null == preferences
          ? _self.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TestSettings implements TestSettings {
  const _TestSettings(
      {this.language = 'en_US',
      this.notifications = true,
      this.sessionTimeout = 30,
      final Map<String, dynamic> preferences = const {},
      this.updatedAt})
      : _preferences = preferences;
  factory _TestSettings.fromJson(Map<String, dynamic> json) =>
      _$TestSettingsFromJson(json);

  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool notifications;
  @override
  @JsonKey()
  final int sessionTimeout;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  @override
  final DateTime? updatedAt;

  /// Create a copy of TestSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TestSettingsCopyWith<_TestSettings> get copyWith =>
      __$TestSettingsCopyWithImpl<_TestSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TestSettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TestSettings &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.notifications, notifications) ||
                other.notifications == notifications) &&
            (identical(other.sessionTimeout, sessionTimeout) ||
                other.sessionTimeout == sessionTimeout) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      language,
      notifications,
      sessionTimeout,
      const DeepCollectionEquality().hash(_preferences),
      updatedAt);

  @override
  String toString() {
    return 'TestSettings(language: $language, notifications: $notifications, sessionTimeout: $sessionTimeout, preferences: $preferences, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$TestSettingsCopyWith<$Res>
    implements $TestSettingsCopyWith<$Res> {
  factory _$TestSettingsCopyWith(
          _TestSettings value, $Res Function(_TestSettings) _then) =
      __$TestSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String language,
      bool notifications,
      int sessionTimeout,
      Map<String, dynamic> preferences,
      DateTime? updatedAt});
}

/// @nodoc
class __$TestSettingsCopyWithImpl<$Res>
    implements _$TestSettingsCopyWith<$Res> {
  __$TestSettingsCopyWithImpl(this._self, this._then);

  final _TestSettings _self;
  final $Res Function(_TestSettings) _then;

  /// Create a copy of TestSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? language = null,
    Object? notifications = null,
    Object? sessionTimeout = null,
    Object? preferences = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_TestSettings(
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      notifications: null == notifications
          ? _self.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as bool,
      sessionTimeout: null == sessionTimeout
          ? _self.sessionTimeout
          : sessionTimeout // ignore: cast_nullable_to_non_nullable
              as int,
      preferences: null == preferences
          ? _self._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$TestApiRequest {
  @JsonKey(name: 'request_id')
  String get requestId;
  @JsonKey(name: 'user_agent')
  String get userAgent;
  @JsonKey(
      name: 'timestamp', fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get timestamp;
  @JsonKey(includeIfNull: false)
  String? get optionalField;

  /// Create a copy of TestApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TestApiRequestCopyWith<TestApiRequest> get copyWith =>
      _$TestApiRequestCopyWithImpl<TestApiRequest>(
          this as TestApiRequest, _$identity);

  /// Serializes this TestApiRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TestApiRequest &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.optionalField, optionalField) ||
                other.optionalField == optionalField));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, requestId, userAgent, timestamp, optionalField);

  @override
  String toString() {
    return 'TestApiRequest(requestId: $requestId, userAgent: $userAgent, timestamp: $timestamp, optionalField: $optionalField)';
  }
}

/// @nodoc
abstract mixin class $TestApiRequestCopyWith<$Res> {
  factory $TestApiRequestCopyWith(
          TestApiRequest value, $Res Function(TestApiRequest) _then) =
      _$TestApiRequestCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'request_id') String requestId,
      @JsonKey(name: 'user_agent') String userAgent,
      @JsonKey(
          name: 'timestamp',
          fromJson: _timestampFromJson,
          toJson: _timestampToJson)
      DateTime timestamp,
      @JsonKey(includeIfNull: false) String? optionalField});
}

/// @nodoc
class _$TestApiRequestCopyWithImpl<$Res>
    implements $TestApiRequestCopyWith<$Res> {
  _$TestApiRequestCopyWithImpl(this._self, this._then);

  final TestApiRequest _self;
  final $Res Function(TestApiRequest) _then;

  /// Create a copy of TestApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestId = null,
    Object? userAgent = null,
    Object? timestamp = null,
    Object? optionalField = freezed,
  }) {
    return _then(_self.copyWith(
      requestId: null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      userAgent: null == userAgent
          ? _self.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optionalField: freezed == optionalField
          ? _self.optionalField
          : optionalField // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TestApiRequest implements TestApiRequest {
  const _TestApiRequest(
      {@JsonKey(name: 'request_id') required this.requestId,
      @JsonKey(name: 'user_agent') required this.userAgent,
      @JsonKey(
          name: 'timestamp',
          fromJson: _timestampFromJson,
          toJson: _timestampToJson)
      required this.timestamp,
      @JsonKey(includeIfNull: false) this.optionalField});
  factory _TestApiRequest.fromJson(Map<String, dynamic> json) =>
      _$TestApiRequestFromJson(json);

  @override
  @JsonKey(name: 'request_id')
  final String requestId;
  @override
  @JsonKey(name: 'user_agent')
  final String userAgent;
  @override
  @JsonKey(
      name: 'timestamp', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime timestamp;
  @override
  @JsonKey(includeIfNull: false)
  final String? optionalField;

  /// Create a copy of TestApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TestApiRequestCopyWith<_TestApiRequest> get copyWith =>
      __$TestApiRequestCopyWithImpl<_TestApiRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TestApiRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TestApiRequest &&
            (identical(other.requestId, requestId) ||
                other.requestId == requestId) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.optionalField, optionalField) ||
                other.optionalField == optionalField));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, requestId, userAgent, timestamp, optionalField);

  @override
  String toString() {
    return 'TestApiRequest(requestId: $requestId, userAgent: $userAgent, timestamp: $timestamp, optionalField: $optionalField)';
  }
}

/// @nodoc
abstract mixin class _$TestApiRequestCopyWith<$Res>
    implements $TestApiRequestCopyWith<$Res> {
  factory _$TestApiRequestCopyWith(
          _TestApiRequest value, $Res Function(_TestApiRequest) _then) =
      __$TestApiRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'request_id') String requestId,
      @JsonKey(name: 'user_agent') String userAgent,
      @JsonKey(
          name: 'timestamp',
          fromJson: _timestampFromJson,
          toJson: _timestampToJson)
      DateTime timestamp,
      @JsonKey(includeIfNull: false) String? optionalField});
}

/// @nodoc
class __$TestApiRequestCopyWithImpl<$Res>
    implements _$TestApiRequestCopyWith<$Res> {
  __$TestApiRequestCopyWithImpl(this._self, this._then);

  final _TestApiRequest _self;
  final $Res Function(_TestApiRequest) _then;

  /// Create a copy of TestApiRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requestId = null,
    Object? userAgent = null,
    Object? timestamp = null,
    Object? optionalField = freezed,
  }) {
    return _then(_TestApiRequest(
      requestId: null == requestId
          ? _self.requestId
          : requestId // ignore: cast_nullable_to_non_nullable
              as String,
      userAgent: null == userAgent
          ? _self.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      optionalField: freezed == optionalField
          ? _self.optionalField
          : optionalField // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
