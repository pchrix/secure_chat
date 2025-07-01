/// ✅ Validators - Validateurs pour les formulaires
/// 
/// Classe utilitaire contenant tous les validateurs pour les champs de formulaire.
/// Optimisé pour l'authentification et la sécurité.

class Validators {
  // Empêche l'instanciation
  Validators._();

  // ========== EXPRESSIONS RÉGULIÈRES ==========
  
  /// Pattern pour email valide
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  /// Pattern pour nom d'utilisateur valide (lettres, chiffres, underscore, tiret)
  static final RegExp _usernameRegExp = RegExp(
    r'^[a-zA-Z0-9_-]+$',
  );
  
  /// Pattern pour mot de passe fort
  static final RegExp _strongPasswordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );
  
  /// Pattern pour code PIN (6 chiffres)
  static final RegExp _pinRegExp = RegExp(r'^\d{6}$');
  
  /// Pattern pour numéro de téléphone
  static final RegExp _phoneRegExp = RegExp(
    r'^(\+33|0)[1-9](\d{8})$',
  );

  // ========== VALIDATEURS EMAIL ==========
  
  /// Valide une adresse email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    if (value.length > 254) {
      return 'L\'email est trop long';
    }
    
    if (!_emailRegExp.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }
  
  /// Valide un email requis
  static String? validateRequiredEmail(String? value) {
    final emailError = validateEmail(value);
    if (emailError != null) return emailError;
    
    return null;
  }

  // ========== VALIDATEURS MOT DE PASSE ==========
  
  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    if (value.length > 128) {
      return 'Le mot de passe est trop long';
    }
    
    return null;
  }
  
  /// Valide un mot de passe fort
  static String? validateStrongPassword(String? value) {
    final basicError = validatePassword(value);
    if (basicError != null) return basicError;
    
    if (!value!.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    
    if (!value.contains(RegExp(r'\d'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    if (!value.contains(RegExp(r'[@$!%*?&]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }
    
    return null;
  }
  
  /// Valide la confirmation de mot de passe
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }
    
    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  // ========== VALIDATEURS NOM D'UTILISATEUR ==========
  
  /// Valide un nom d'utilisateur
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }
    
    if (value.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }
    
    if (value.length > 30) {
      return 'Le nom d\'utilisateur est trop long';
    }
    
    if (!_usernameRegExp.hasMatch(value)) {
      return 'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres, _ et -';
    }
    
    // Vérifier que ce n'est pas que des chiffres
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Le nom d\'utilisateur ne peut pas être que des chiffres';
    }
    
    return null;
  }

  // ========== VALIDATEURS NOM ==========
  
  /// Valide un nom d'affichage
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    if (value.length < 2) {
      return 'Le nom d\'affichage doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return 'Le nom d\'affichage est trop long';
    }
    
    // Vérifier qu'il n'y a pas que des espaces
    if (value.trim().isEmpty) {
      return 'Le nom d\'affichage ne peut pas être vide';
    }
    
    return null;
  }
  
  /// Valide un prénom
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le prénom est requis';
    }
    
    if (value.length < 2) {
      return 'Le prénom doit contenir au moins 2 caractères';
    }
    
    if (value.length > 30) {
      return 'Le prénom est trop long';
    }
    
    return null;
  }
  
  /// Valide un nom de famille
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom de famille est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom de famille doit contenir au moins 2 caractères';
    }
    
    if (value.length > 30) {
      return 'Le nom de famille est trop long';
    }
    
    return null;
  }

  // ========== VALIDATEURS CODE PIN ==========
  
  /// Valide un code PIN
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est requis';
    }
    
    if (!_pinRegExp.hasMatch(value)) {
      return 'Le code PIN doit contenir exactement 6 chiffres';
    }
    
    // Vérifier que ce n'est pas une séquence simple
    if (_isSimpleSequence(value)) {
      return 'Le code PIN ne peut pas être une séquence simple';
    }
    
    // Vérifier que ce ne sont pas tous les mêmes chiffres
    if (_isAllSameDigits(value)) {
      return 'Le code PIN ne peut pas être composé du même chiffre';
    }
    
    return null;
  }
  
  /// Valide la confirmation de PIN
  static String? validateConfirmPin(String? value, String? originalPin) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du PIN est requise';
    }
    
    if (value != originalPin) {
      return 'Les codes PIN ne correspondent pas';
    }
    
    return null;
  }

  // ========== VALIDATEURS TÉLÉPHONE ==========
  
  /// Valide un numéro de téléphone français
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    // Nettoyer le numéro (supprimer espaces, tirets, etc.)
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\.]'), '');
    
    if (!_phoneRegExp.hasMatch(cleanNumber)) {
      return 'Format de téléphone invalide';
    }
    
    return null;
  }

  // ========== VALIDATEURS GÉNÉRIQUES ==========
  
  /// Valide qu'un champ n'est pas vide
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
  
  /// Valide la longueur minimale
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }
    return null;
  }
  
  /// Valide la longueur maximale
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }
    return null;
  }
  
  /// Valide qu'une valeur est dans une liste
  static String? validateInList(String? value, List<String> validValues, String fieldName) {
    if (value != null && !validValues.contains(value)) {
      return '$fieldName n\'est pas valide';
    }
    return null;
  }

  // ========== MÉTHODES UTILITAIRES PRIVÉES ==========
  
  /// Vérifie si le PIN est une séquence simple (123456, 654321, etc.)
  static bool _isSimpleSequence(String pin) {
    // Séquences croissantes
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      if (next != current + 1) break;
      if (i == pin.length - 2) return true; // Toute la séquence est croissante
    }
    
    // Séquences décroissantes
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      if (next != current - 1) break;
      if (i == pin.length - 2) return true; // Toute la séquence est décroissante
    }
    
    return false;
  }
  
  /// Vérifie si tous les chiffres du PIN sont identiques
  static bool _isAllSameDigits(String pin) {
    final firstDigit = pin[0];
    return pin.split('').every((digit) => digit == firstDigit);
  }
}
