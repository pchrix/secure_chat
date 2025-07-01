// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestUser _$TestUserFromJson(Map<String, dynamic> json) => _TestUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email_address'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$TestUserToJson(_TestUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email_address': instance.email,
      'isPremium': instance.isPremium,
      'tags': instance.tags,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };

TestApiResponseSuccess<T> _$TestApiResponseSuccessFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    TestApiResponseSuccess<T>(
      fromJsonT(json['data']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TestApiResponseSuccessToJson<T>(
  TestApiResponseSuccess<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': toJsonT(instance.data),
      'type': instance.$type,
    };

TestApiResponseError<T> _$TestApiResponseErrorFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    TestApiResponseError<T>(
      json['message'] as String,
      (json['code'] as num).toInt(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TestApiResponseErrorToJson<T>(
  TestApiResponseError<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'type': instance.$type,
    };

TestApiResponseLoading<T> _$TestApiResponseLoadingFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    TestApiResponseLoading<T>(
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TestApiResponseLoadingToJson<T>(
  TestApiResponseLoading<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'type': instance.$type,
    };

_TestSettings _$TestSettingsFromJson(Map<String, dynamic> json) =>
    _TestSettings(
      language: json['language'] as String? ?? 'en_US',
      notifications: json['notifications'] as bool? ?? true,
      sessionTimeout: (json['sessionTimeout'] as num?)?.toInt() ?? 30,
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TestSettingsToJson(_TestSettings instance) =>
    <String, dynamic>{
      'language': instance.language,
      'notifications': instance.notifications,
      'sessionTimeout': instance.sessionTimeout,
      'preferences': instance.preferences,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_TestApiRequest _$TestApiRequestFromJson(Map<String, dynamic> json) =>
    _TestApiRequest(
      requestId: json['request_id'] as String,
      userAgent: json['user_agent'] as String,
      timestamp: _timestampFromJson(json['timestamp']),
      optionalField: json['optionalField'] as String?,
    );

Map<String, dynamic> _$TestApiRequestToJson(_TestApiRequest instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'user_agent': instance.userAgent,
      'timestamp': _timestampToJson(instance.timestamp),
      if (instance.optionalField case final value?) 'optionalField': value,
    };
