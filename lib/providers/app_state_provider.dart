import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../services/secure_storage_service.dart';

// État de l'application
class AppState {
  final List<Contact> contacts;
  final DateTime? keyExpiryTime;
  final String? temporaryKey;
  final bool isLoading;
  final String? error;

  const AppState({
    this.contacts = const [],
    this.keyExpiryTime,
    this.temporaryKey,
    this.isLoading = false,
    this.error,
  });

  bool get hasValidKey =>
      temporaryKey != null &&
      keyExpiryTime != null &&
      keyExpiryTime!.isAfter(DateTime.now());

  AppState copyWith({
    List<Contact>? contacts,
    DateTime? keyExpiryTime,
    String? temporaryKey,
    bool? isLoading,
    String? error,
    bool clearKeyExpiryTime = false,
    bool clearTemporaryKey = false,
    bool clearError = false,
  }) {
    return AppState(
      contacts: contacts ?? this.contacts,
      keyExpiryTime:
          clearKeyExpiryTime ? null : (keyExpiryTime ?? this.keyExpiryTime),
      temporaryKey:
          clearTemporaryKey ? null : (temporaryKey ?? this.temporaryKey),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  static const int _defaultKeyDurationHours = 6;

  AppStateNotifier() : super(const AppState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    await _loadContacts();
    await _loadKeyData();
    state = state.copyWith(isLoading: false);
  }

  void addContact(Contact contact) {
    if (!state.contacts.any((c) => c.id == contact.id)) {
      final updatedContacts = [...state.contacts, contact];
      state = state.copyWith(contacts: updatedContacts);
      _saveContacts();
    }
  }

  void removeContact(String contactId) {
    final updatedContacts =
        state.contacts.where((contact) => contact.id != contactId).toList();
    state = state.copyWith(contacts: updatedContacts);
    _saveContacts();
  }

  void generateNewKey() {
    // The actual key generation is handled in the encryption service
    // Here we just manage expiry time
    final keyExpiryTime =
        DateTime.now().add(const Duration(hours: _defaultKeyDurationHours));
    state = state.copyWith(keyExpiryTime: keyExpiryTime);
    _saveKeyData();
  }

  void setTemporaryKey(String key, {int? durationHours}) {
    final keyExpiryTime = DateTime.now()
        .add(Duration(hours: durationHours ?? _defaultKeyDurationHours));
    state = state.copyWith(
      temporaryKey: key,
      keyExpiryTime: keyExpiryTime,
    );
    _saveKeyData();
  }

  bool isKeyValid() {
    return state.hasValidKey;
  }

  void clearKey() {
    state = state.copyWith(
      clearTemporaryKey: true,
      clearKeyExpiryTime: true,
    );
    _saveKeyData();
  }

  Future<void> _loadContacts() async {
    try {
      final contactsJson =
          await SecureStorageService.getStringList('contacts') ?? [];
      final contacts =
          contactsJson.map((json) => Contact.fromJson(json)).toList();
      state = state.copyWith(contacts: contacts);
    } catch (e) {
      // Handle error silently to avoid revealing app's true nature
      state = state.copyWith(contacts: []);
    }
  }

  Future<void> _saveContacts() async {
    try {
      final contactsJson =
          state.contacts.map((contact) => contact.toJson()).toList();
      await SecureStorageService.setStringList('contacts', contactsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadKeyData() async {
    try {
      final expiryMillis = await SecureStorageService.getInt('key_expiry');
      if (expiryMillis != null) {
        final keyExpiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
        if (!keyExpiryTime.isAfter(DateTime.now())) {
          // Key expired, clear it
          state = state.copyWith(
            clearKeyExpiryTime: true,
            clearTemporaryKey: true,
          );
        } else {
          state = state.copyWith(keyExpiryTime: keyExpiryTime);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveKeyData() async {
    try {
      if (state.keyExpiryTime != null) {
        await SecureStorageService.setInt(
            'key_expiry', state.keyExpiryTime!.millisecondsSinceEpoch);
      } else {
        await SecureStorageService.remove('key_expiry');
      }
    } catch (e) {
      // Handle error silently
    }
  }
}

// Provider global pour AppState
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
