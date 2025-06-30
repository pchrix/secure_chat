/// 👤 User Model - Modèle de données utilisateur pour la couche Data
///
/// Modèle de données qui étend l'entité User du domaine et ajoute
/// les fonctionnalités de sérialisation/désérialisation pour l'API.

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../domain/entities/user.dart';

// Alias pour éviter les conflits d'imports
typedef SupabaseUser = supabase.User;

/// Modèle de données utilisateur pour la couche Data
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final bool isEmailConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic> metadata;
  const UserModel({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.isEmailConfirmed = false,
    required this.createdAt,
    this.updatedAt,
    this.lastSignInAt,
    this.metadata = const {},
  });

  /// Crée un UserModel à partir d'un utilisateur Supabase
  factory UserModel.fromSupabaseUser(SupabaseUser user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String?,
      displayName: user.userMetadata?['display_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      isEmailConfirmed: user.emailConfirmedAt != null,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : DateTime.now(),
      updatedAt:
          user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      lastSignInAt:
          user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
      metadata: user.userMetadata ?? {},
    );
  }

  /// Crée un UserModel à partir d'un Map JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isEmailConfirmed: json['email_confirmed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Crée un UserModel à partir d'un profil utilisateur de la base de données
  factory UserModel.fromUserProfile(Map<String, dynamic> profile) {
    return UserModel(
      id: profile['user_id'] as String,
      email: profile['email'] as String? ?? '',
      username: profile['username'] as String?,
      displayName: profile['display_name'] as String?,
      avatarUrl: profile['avatar_url'] as String?,
      isEmailConfirmed: profile['email_confirmed'] as bool? ?? false,
      createdAt: profile['created_at'] != null
          ? DateTime.parse(profile['created_at'] as String)
          : DateTime.now(),
      updatedAt: profile['updated_at'] != null
          ? DateTime.parse(profile['updated_at'] as String)
          : null,
      lastSignInAt: profile['last_sign_in_at'] != null
          ? DateTime.parse(profile['last_sign_in_at'] as String)
          : null,
      metadata: profile['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Crée un UserModel à partir d'une entité User du domaine
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      isEmailConfirmed: user.isEmailVerified,
      createdAt: user.createdAt,
      updatedAt: null, // L'entité User n'a pas updatedAt
      lastSignInAt: user.lastSeenAt,
      metadata: const {},
    );
  }

  /// Convertit le UserModel en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'email_confirmed': isEmailConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Convertit le UserModel en Map pour le profil utilisateur de la base de données
  Map<String, dynamic> toUserProfile() {
    return {
      'user_id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'email_confirmed': isEmailConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Crée une copie du UserModel avec des valeurs modifiées
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isEmailConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convertit le UserModel en entité User du domaine
  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username ?? email.split('@').first,
      displayName: displayName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      lastSeenAt: lastSignInAt,
      isEmailVerified: isEmailConfirmed,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'email: $email, '
        'username: $username, '
        'displayName: $displayName, '
        'isEmailConfirmed: $isEmailConfirmed'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.isEmailConfirmed == isEmailConfirmed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastSignInAt == lastSignInAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      username,
      displayName,
      avatarUrl,
      isEmailConfirmed,
      createdAt,
      updatedAt,
      lastSignInAt,
    );
  }
}

/// Extensions utiles pour UserModel
extension UserModelExtensions on UserModel {
  /// Vérifie si l'utilisateur a un profil complet
  bool get hasCompleteProfile {
    return username != null &&
        username!.isNotEmpty &&
        displayName != null &&
        displayName!.isNotEmpty;
  }

  /// Vérifie si l'utilisateur est récent (créé dans les 7 derniers jours)
  bool get isNewUser {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  /// Obtient le nom d'affichage effectif (displayName ou username ou email)
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    return email.split('@').first;
  }

  /// Obtient les initiales pour l'avatar
  String get initials {
    final name = effectiveDisplayName;
    if (name.isEmpty) return '?';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Vérifie si l'utilisateur s'est connecté récemment (dans les 24 dernières heures)
  bool get hasRecentActivity {
    if (lastSignInAt == null) return false;
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(hours: 24));
    return lastSignInAt!.isAfter(dayAgo);
  }
}
