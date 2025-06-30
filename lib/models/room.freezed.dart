// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Room {
  /// ID unique du salon
  String get id;

  /// Nom du salon
  String get name;

  /// Date de création
  DateTime get createdAt;

  /// Date d'expiration
  DateTime get expiresAt;

  /// Statut du salon
  RoomStatus get status;

  /// Nombre de participants actuels
  int get participantCount;

  /// Nombre maximum de participants
  int get maxParticipants;

  /// ID du créateur
  String? get creatorId;

  /// Métadonnées additionnelles
  Map<String, dynamic> get metadata;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoomCopyWith<Room> get copyWith =>
      _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Room &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      expiresAt,
      status,
      participantCount,
      maxParticipants,
      creatorId,
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'Room(id: $id, name: $name, createdAt: $createdAt, expiresAt: $expiresAt, status: $status, participantCount: $participantCount, maxParticipants: $maxParticipants, creatorId: $creatorId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) =
      _$RoomCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime createdAt,
      DateTime expiresAt,
      RoomStatus status,
      int participantCount,
      int maxParticipants,
      String? creatorId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$RoomCopyWithImpl<$Res> implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? participantCount = null,
    Object? maxParticipants = null,
    Object? creatorId = freezed,
    Object? metadata = null,
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
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      participantCount: null == participantCount
          ? _self.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _self.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: freezed == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Room extends Room {
  const _Room(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.expiresAt,
      required this.status,
      required this.participantCount,
      this.maxParticipants = 2,
      this.creatorId,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata,
        super._();
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  /// ID unique du salon
  @override
  final String id;

  /// Nom du salon
  @override
  final String name;

  /// Date de création
  @override
  final DateTime createdAt;

  /// Date d'expiration
  @override
  final DateTime expiresAt;

  /// Statut du salon
  @override
  final RoomStatus status;

  /// Nombre de participants actuels
  @override
  final int participantCount;

  /// Nombre maximum de participants
  @override
  @JsonKey()
  final int maxParticipants;

  /// ID du créateur
  @override
  final String? creatorId;

  /// Métadonnées additionnelles
  final Map<String, dynamic> _metadata;

  /// Métadonnées additionnelles
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RoomCopyWith<_Room> get copyWith =>
      __$RoomCopyWithImpl<_Room>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RoomToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Room &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      expiresAt,
      status,
      participantCount,
      maxParticipants,
      creatorId,
      const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'Room(id: $id, name: $name, createdAt: $createdAt, expiresAt: $expiresAt, status: $status, participantCount: $participantCount, maxParticipants: $maxParticipants, creatorId: $creatorId, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) =
      __$RoomCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime createdAt,
      DateTime expiresAt,
      RoomStatus status,
      int participantCount,
      int maxParticipants,
      String? creatorId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$RoomCopyWithImpl<$Res> implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? participantCount = null,
    Object? maxParticipants = null,
    Object? creatorId = freezed,
    Object? metadata = null,
  }) {
    return _then(_Room(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      participantCount: null == participantCount
          ? _self.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxParticipants: null == maxParticipants
          ? _self.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: freezed == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
