/// 🧪 Modèle de test pour valider la configuration Freezed
///
/// Ce modèle teste toutes les fonctionnalités Freezed configurées :
/// - Sérialisation JSON
/// - Unions/Sealed classes
/// - Valeurs par défaut
/// - Types génériques
///
/// Conforme aux meilleures pratiques Context7 + Exa pour Freezed.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_model.freezed.dart';
part 'test_model.g.dart';

/// Modèle de test simple avec sérialisation JSON
@freezed
abstract class TestUser with _$TestUser {
  const factory TestUser({
    required String id,
    required String name,
    @JsonKey(name: 'email_address') required String email,
    @Default(false) bool isPremium,
    @Default([]) List<String> tags,
    DateTime? lastLoginAt,
  }) = _TestUser;

  factory TestUser.fromJson(Map<String, dynamic> json) =>
      _$TestUserFromJson(json);
}

/// Sealed class pour tester les unions avec configuration personnalisée
@Freezed(
  unionKey: 'type',
  unionValueCase: FreezedUnionCase.pascal,
  genericArgumentFactories: true,
)
sealed class TestApiResponse<T> with _$TestApiResponse<T> {
  const factory TestApiResponse.success(T data) = TestApiResponseSuccess<T>;

  @FreezedUnionValue('ErrorCase')
  const factory TestApiResponse.error(String message, int code) =
      TestApiResponseError<T>;

  const factory TestApiResponse.loading() = TestApiResponseLoading<T>;

  factory TestApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$TestApiResponseFromJson(json, fromJsonT);
}

/// Modèle avec valeurs par défaut complexes
@freezed
abstract class TestSettings with _$TestSettings {
  const factory TestSettings({
    @Default('en_US') String language,
    @Default(true) bool notifications,
    @Default(30) int sessionTimeout,
    @Default({}) Map<String, dynamic> preferences,
    DateTime? updatedAt,
  }) = _TestSettings;

  factory TestSettings.fromJson(Map<String, dynamic> json) =>
      _$TestSettingsFromJson(json);
}

/// Modèle avec JsonKey personnalisés
@freezed
abstract class TestApiRequest with _$TestApiRequest {
  const factory TestApiRequest({
    @JsonKey(name: 'request_id') required String requestId,
    @JsonKey(name: 'user_agent') required String userAgent,
    @JsonKey(
        name: 'timestamp',
        fromJson: _timestampFromJson,
        toJson: _timestampToJson)
    required DateTime timestamp,
    @JsonKey(includeIfNull: false) String? optionalField,
  }) = _TestApiRequest;

  factory TestApiRequest.fromJson(Map<String, dynamic> json) =>
      _$TestApiRequestFromJson(json);
}

/// Fonctions utilitaires pour la conversion de timestamp
DateTime _timestampFromJson(dynamic timestamp) {
  if (timestamp is String) {
    return DateTime.parse(timestamp);
  } else if (timestamp is int) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  throw ArgumentError('Invalid timestamp format: $timestamp');
}

dynamic _timestampToJson(DateTime timestamp) {
  return timestamp.toIso8601String();
}
