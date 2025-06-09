import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _passwordHashKey = 'password_hash';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lastAttemptTimeKey = 'last_attempt_time';
  static const String _isLockedKey = 'is_locked';
  
  static const int maxFailedAttempts = 3;
  static const int lockoutDurationMinutes = 5;

  /// Hash a password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a password has been set
  static Future<bool> hasPasswordSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hash = prefs.getString(_passwordHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Set a new password
  static Future<bool> setPassword(String password) async {
    try {
      // Validate password (4-6 digits)
      if (!_isValidPassword(password)) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final hashedPassword = _hashPassword(password);
      await prefs.setString(_passwordHashKey, hashedPassword);
      
      // Reset failed attempts when setting new password
      await _resetFailedAttempts();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify a password
  static Future<AuthResult> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if account is locked
      if (await _isAccountLocked()) {
        final remainingTime = await _getRemainingLockoutTime();
        return AuthResult.locked(remainingTime);
      }

      final storedHash = prefs.getString(_passwordHashKey);
      if (storedHash == null) {
        return AuthResult.noPasswordSet();
      }

      final inputHash = _hashPassword(password);
      
      if (storedHash == inputHash) {
        // Password correct - reset failed attempts
        await _resetFailedAttempts();
        return AuthResult.success();
      } else {
        // Password incorrect - increment failed attempts
        await _incrementFailedAttempts();
        final attempts = await _getFailedAttempts();
        
        if (attempts >= maxFailedAttempts) {
          await _lockAccount();
          return AuthResult.locked(lockoutDurationMinutes);
        }
        
        return AuthResult.failed(maxFailedAttempts - attempts);
      }
    } catch (e) {
      return AuthResult.error('Erreur lors de la vérification');
    }
  }

  /// Validate password format (4-6 digits)
  static bool _isValidPassword(String password) {
    if (password.length < 4 || password.length > 6) {
      return false;
    }
    
    // Check if all characters are digits
    return RegExp(r'^\d+$').hasMatch(password);
  }

  /// Get number of failed attempts
  static Future<int> _getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  /// Increment failed attempts
  static Future<void> _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = await _getFailedAttempts();
    await prefs.setInt(_failedAttemptsKey, attempts + 1);
    await prefs.setInt(_lastAttemptTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Reset failed attempts
  static Future<void> _resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lastAttemptTimeKey);
    await prefs.remove(_isLockedKey);
  }

  /// Check if account is locked
  static Future<bool> _isAccountLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocked = prefs.getBool(_isLockedKey) ?? false;
    
    if (!isLocked) return false;
    
    // Check if lockout period has expired
    final lastAttemptTime = prefs.getInt(_lastAttemptTimeKey) ?? 0;
    final lockoutEndTime = lastAttemptTime + (lockoutDurationMinutes * 60 * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (now >= lockoutEndTime) {
      // Lockout period expired - unlock account
      await _resetFailedAttempts();
      return false;
    }
    
    return true;
  }

  /// Lock the account
  static Future<void> _lockAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLockedKey, true);
    await prefs.setInt(_lastAttemptTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get remaining lockout time in minutes
  static Future<int> _getRemainingLockoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAttemptTime = prefs.getInt(_lastAttemptTimeKey) ?? 0;
    final lockoutEndTime = lastAttemptTime + (lockoutDurationMinutes * 60 * 1000);
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final remainingMs = lockoutEndTime - now;
    return (remainingMs / (60 * 1000)).ceil().clamp(0, lockoutDurationMinutes);
  }

  /// Clear all authentication data (for security wipe)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passwordHashKey);
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lastAttemptTimeKey);
    await prefs.remove(_isLockedKey);
  }

  /// Validate password format for UI
  static bool isValidPasswordFormat(String password) {
    return _isValidPassword(password);
  }
}

/// Result of authentication attempt
class AuthResult {
  final AuthStatus status;
  final String? message;
  final int? remainingAttempts;
  final int? lockoutMinutes;

  AuthResult._(this.status, {this.message, this.remainingAttempts, this.lockoutMinutes});

  factory AuthResult.success() => AuthResult._(AuthStatus.success);
  
  factory AuthResult.failed(int remainingAttempts) => AuthResult._(
    AuthStatus.failed, 
    remainingAttempts: remainingAttempts,
    message: 'Mot de passe incorrect. $remainingAttempts tentative${remainingAttempts > 1 ? 's' : ''} restante${remainingAttempts > 1 ? 's' : ''}.'
  );
  
  factory AuthResult.locked(int minutes) => AuthResult._(
    AuthStatus.locked, 
    lockoutMinutes: minutes,
    message: 'Compte verrouillé. Réessayez dans $minutes minute${minutes > 1 ? 's' : ''}.'
  );
  
  factory AuthResult.noPasswordSet() => AuthResult._(
    AuthStatus.noPasswordSet,
    message: 'Aucun mot de passe configuré.'
  );
  
  factory AuthResult.error(String error) => AuthResult._(
    AuthStatus.error,
    message: error
  );

  bool get isSuccess => status == AuthStatus.success;
  bool get isFailed => status == AuthStatus.failed;
  bool get isLocked => status == AuthStatus.locked;
  bool get isNoPasswordSet => status == AuthStatus.noPasswordSet;
  bool get isError => status == AuthStatus.error;
}

enum AuthStatus {
  success,
  failed,
  locked,
  noPasswordSet,
  error,
}
