// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {
  /// ID unique du message
  String get id;

  /// ID du salon
  String get roomId;

  /// Contenu du message (chiffré)
  String get content;

  /// ID de l'expéditeur
  String get senderId;

  /// Horodatage du message
  DateTime get timestamp;

  /// Type de message
  MessageType get type;

  /// Indique si le message est chiffré
  bool get isEncrypted;

  /// Statut de lecture
  bool get isRead;

  /// Métadonnées additionnelles
  Map<String, dynamic> get metadata;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageCopyWith<Message> get copyWith =>
      _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Message &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isEncrypted, isEncrypted) ||
                other.isEncrypted == isEncrypted) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roomId,
      content,
      senderId,
      timestamp,
      type,
      isEncrypted,
      isRead,
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'Message(id: $id, roomId: $roomId, content: $content, senderId: $senderId, timestamp: $timestamp, type: $type, isEncrypted: $isEncrypted, isRead: $isRead, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) =
      _$MessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String roomId,
      String content,
      String senderId,
      DateTime timestamp,
      MessageType type,
      bool isEncrypted,
      bool isRead,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res> implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? content = null,
    Object? senderId = null,
    Object? timestamp = null,
    Object? type = null,
    Object? isEncrypted = null,
    Object? isRead = null,
    Object? metadata = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _self.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      isEncrypted: null == isEncrypted
          ? _self.isEncrypted
          : isEncrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Message extends Message {
  const _Message(
      {required this.id,
      required this.roomId,
      required this.content,
      required this.senderId,
      required this.timestamp,
      this.type = MessageType.text,
      this.isEncrypted = true,
      this.isRead = false,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata,
        super._();
  factory _Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  /// ID unique du message
  @override
  final String id;

  /// ID du salon
  @override
  final String roomId;

  /// Contenu du message (chiffré)
  @override
  final String content;

  /// ID de l'expéditeur
  @override
  final String senderId;

  /// Horodatage du message
  @override
  final DateTime timestamp;

  /// Type de message
  @override
  @JsonKey()
  final MessageType type;

  /// Indique si le message est chiffré
  @override
  @JsonKey()
  final bool isEncrypted;

  /// Statut de lecture
  @override
  @JsonKey()
  final bool isRead;

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

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageCopyWith<_Message> get copyWith =>
      __$MessageCopyWithImpl<_Message>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Message &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isEncrypted, isEncrypted) ||
                other.isEncrypted == isEncrypted) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roomId,
      content,
      senderId,
      timestamp,
      type,
      isEncrypted,
      isRead,
      const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'Message(id: $id, roomId: $roomId, content: $content, senderId: $senderId, timestamp: $timestamp, type: $type, isEncrypted: $isEncrypted, isRead: $isRead, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) =
      __$MessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String roomId,
      String content,
      String senderId,
      DateTime timestamp,
      MessageType type,
      bool isEncrypted,
      bool isRead,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$MessageCopyWithImpl<$Res> implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? content = null,
    Object? senderId = null,
    Object? timestamp = null,
    Object? type = null,
    Object? isEncrypted = null,
    Object? isRead = null,
    Object? metadata = null,
  }) {
    return _then(_Message(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _self.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      isEncrypted: null == isEncrypted
          ? _self.isEncrypted
          : isEncrypted // ignore: cast_nullable_to_non_nullable
              as bool,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: null == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
