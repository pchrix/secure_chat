import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';
import '../models/secret_access_config.dart';

class AppStateProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  DateTime? _keyExpiryTime;
  String? _temporaryKey;
  final int _defaultKeyDurationHours = 6;

  // Secret access configuration
  SecretAccessConfig _secretAccessConfig = SecretAccessConfig.defaultConfig;

  List<Contact> get contacts => _contacts;
  bool get hasValidKey =>
      _temporaryKey != null &&
      _keyExpiryTime != null &&
      _keyExpiryTime!.isAfter(DateTime.now());
  String? get temporaryKey => _temporaryKey;
  DateTime? get keyExpiryTime => _keyExpiryTime;
  SecretAccessConfig get secretAccessConfig => _secretAccessConfig;

  AppStateProvider() {
    _loadContacts();
    _loadKeyData();
    _loadSecretAccessConfig();
  }

  void addContact(Contact contact) {
    if (!_contacts.any((c) => c.id == contact.id)) {
      _contacts.add(contact);
      _saveContacts();
      notifyListeners();
    }
  }

  void removeContact(String contactId) {
    _contacts.removeWhere((contact) => contact.id == contactId);
    _saveContacts();
    notifyListeners();
  }

  void generateNewKey() {
    // The actual key generation is handled in the encryption service
    // Here we just manage expiry time
    _keyExpiryTime =
        DateTime.now().add(Duration(hours: _defaultKeyDurationHours));
    _saveKeyData();
    notifyListeners();
  }

  void setTemporaryKey(String key, {int? durationHours}) {
    _temporaryKey = key;
    _keyExpiryTime = DateTime.now()
        .add(Duration(hours: durationHours ?? _defaultKeyDurationHours));
    _saveKeyData();
    notifyListeners();
  }

  bool isKeyValid() {
    if (_temporaryKey == null || _keyExpiryTime == null) return false;
    return _keyExpiryTime!.isAfter(DateTime.now());
  }

  void clearKey() {
    _temporaryKey = null;
    _keyExpiryTime = null;
    _saveKeyData();
    notifyListeners();
  }

  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList('contacts') ?? [];
      _contacts = contactsJson.map((json) => Contact.fromJson(json)).toList();
    } catch (e) {
      // Handle error silently to avoid revealing app's true nature
      _contacts = [];
    }
  }

  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson =
          _contacts.map((contact) => contact.toJson()).toList();
      await prefs.setStringList('contacts', contactsJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadKeyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryMillis = prefs.getInt('key_expiry');
      if (expiryMillis != null) {
        _keyExpiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
        if (!_keyExpiryTime!.isAfter(DateTime.now())) {
          _keyExpiryTime = null;
          _temporaryKey = null;
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveKeyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_keyExpiryTime != null) {
        await prefs.setInt(
            'key_expiry', _keyExpiryTime!.millisecondsSinceEpoch);
      } else {
        await prefs.remove('key_expiry');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Secret access configuration management
  void updateSecretAccessConfig(SecretAccessConfig config) {
    _secretAccessConfig = config;
    _saveSecretAccessConfig();
    notifyListeners();
  }

  Future<void> _loadSecretAccessConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('secret_access_config');
      if (configJson != null) {
        _secretAccessConfig = SecretAccessConfig.fromJsonString(configJson);
      }
    } catch (e) {
      // Handle error silently, use default config
      _secretAccessConfig = SecretAccessConfig.defaultConfig;
    }
  }

  Future<void> _saveSecretAccessConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'secret_access_config', _secretAccessConfig.toJsonString());
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
