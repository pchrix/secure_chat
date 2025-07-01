import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/contact.dart';

/// Service d'authentification Supabase avec sécurité renforcée et injection de dépendances
class SupabaseAuthService {
  /// Constructeur avec injection de dépendances
  /// [supabaseClient] Client Supabase injecté
  SupabaseAuthService({
    required SupabaseClient supabaseClient,
  }) : _client = supabaseClient;

  /// Client Supabase injecté
  final SupabaseClient _client;

  /// Obtenir l'utilisateur actuel
  User? get currentUser => _client.auth.currentUser;

  /// Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => currentUser != null;

  /// Stream des changements d'état d'authentification
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // === AUTHENTIFICATION ===

  /// Inscription avec email et mot de passe
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': displayName ?? username,
        },
      );

      if (response.user != null) {
        // Créer le profil utilisateur
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          username: username,
          displayName: displayName,
        );
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// Connexion avec email et mot de passe
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Mettre à jour le statut en ligne
        await _updateOnlineStatus(true);
      }

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Connexion avec lien magique
  Future<void> signInWithMagicLink({
    required String email,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.securechat://callback',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du lien magique: $e');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      // Mettre à jour le statut hors ligne avant de se déconnecter
      await _updateOnlineStatus(false);

      await _client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la déconnexion: $e');
      }
      // Forcer la déconnexion même en cas d'erreur
      await _client.auth.signOut(scope: SignOutScope.local);
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.securechat://reset-password',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  // === GESTION DU PROFIL ===

  /// Créer un profil utilisateur
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? username,
    String? displayName,
  }) async {
    try {
      await _client.from('profiles').insert({
        'id': userId,
        'username': username ?? email.split('@')[0],
        'display_name': displayName ?? username ?? email.split('@')[0],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création du profil: $e');
      }
      // Ne pas faire échouer l'inscription si la création du profil échoue
    }
  }

  /// Obtenir le profil utilisateur actuel
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du profil: $e');
      }
      return null;
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    String? username,
    String? displayName,
    String? avatarUrl,
  }) async {
    if (!isAuthenticated) throw Exception('Utilisateur non connecté');

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('profiles').update(updates).eq('id', currentUser!.id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  /// Définir/Mettre à jour le PIN de sécurité
  Future<void> setPinHash(String pinHash) async {
    if (!isAuthenticated) throw Exception('Utilisateur non connecté');

    try {
      await _client.from('profiles').update({
        'pin_hash': pinHash,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (e) {
      throw Exception('Erreur lors de la définition du PIN: $e');
    }
  }

  /// Vérifier le PIN de sécurité
  Future<bool> verifyPin(String pin) async {
    if (!isAuthenticated) return false;

    try {
      final profile = await getCurrentUserProfile();
      if (profile == null || profile['pin_hash'] == null) {
        return false;
      }

      final pinHash = sha256.convert(utf8.encode(pin)).toString();
      return profile['pin_hash'] == pinHash;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la vérification du PIN: $e');
      }
      return false;
    }
  }

  // === STATUT EN LIGNE ===

  /// Mettre à jour le statut en ligne
  Future<void> _updateOnlineStatus(bool isOnline) async {
    if (!isAuthenticated) return;

    try {
      await _client.from('profiles').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du statut: $e');
      }
    }
  }

  /// Marquer l'utilisateur comme actif
  Future<void> markAsActive() async {
    await _updateOnlineStatus(true);
  }

  // === CONTACTS ===

  /// Rechercher des utilisateurs par nom d'utilisateur
  Future<List<Contact>> searchUsers(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await _client
          .from('profiles')
          .select(
              'id, username, display_name, avatar_url, is_online, last_seen')
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .neq('id', currentUser?.id ?? '')
          .limit(20);

      return response
          .map<Contact>((data) => Contact(
                id: data['id'],
                name: data['display_name'] ?? data['username'],
                publicKey:
                    'temp_key_${data['id']}', // Clé temporaire pour la démo
                createdAt: DateTime.now(),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la recherche d\'utilisateurs: $e');
      }
      return [];
    }
  }

  // === GESTION DES ERREURS ===

  /// Gérer les exceptions d'authentification
  static Exception _handleAuthException(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return Exception('Email ou mot de passe incorrect');
      case 'Email not confirmed':
        return Exception('Veuillez confirmer votre email');
      case 'User already registered':
        return Exception('Un compte existe déjà avec cet email');
      case 'Password should be at least 6 characters':
        return Exception('Le mot de passe doit contenir au moins 6 caractères');
      case 'Unable to validate email address: invalid format':
        return Exception('Format d\'email invalide');
      default:
        return Exception('Erreur d\'authentification: ${e.message}');
    }
  }
}
