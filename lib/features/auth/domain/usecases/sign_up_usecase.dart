/// 📝 Use Case SignUp - Inscription utilisateur
/// 
/// Gère la logique métier pour l'inscription d'un nouvel utilisateur.
/// Encapsule les règles de validation et les interactions avec le repository.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case pour l'inscription d'un nouvel utilisateur
class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    // Validation des paramètres d'entrée
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Tentative d'inscription
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      username: params.username,
      displayName: params.displayName,
    );
  }

  /// Valide les paramètres d'inscription
  ValidationFailure? _validateParams(SignUpParams params) {
    // Validation de l'email
    if (params.email.isEmpty) {
      return ValidationFailure.requiredField(field: 'email');
    }

    if (!_isValidEmail(params.email)) {
      return ValidationFailure.invalidFormat(
        field: 'email',
        expectedFormat: 'adresse@exemple.com',
      );
    }

    // Validation du nom d'utilisateur
    if (params.username.isEmpty) {
      return ValidationFailure.requiredField(field: 'username');
    }

    if (params.username.length < 3) {
      return ValidationFailure.invalidInput(
        field: 'username',
        reason: 'Le nom d\'utilisateur doit contenir au moins 3 caractères',
      );
    }

    if (params.username.length > 30) {
      return ValidationFailure.invalidInput(
        field: 'username',
        reason: 'Le nom d\'utilisateur ne peut pas dépasser 30 caractères',
      );
    }

    if (!_isValidUsername(params.username)) {
      return ValidationFailure.invalidFormat(
        field: 'username',
        expectedFormat: 'Lettres, chiffres et underscore uniquement',
      );
    }

    // Validation du mot de passe
    if (params.password.isEmpty) {
      return ValidationFailure.requiredField(field: 'password');
    }

    if (params.password.length < 8) {
      return ValidationFailure.invalidInput(
        field: 'password',
        reason: 'Le mot de passe doit contenir au moins 8 caractères',
      );
    }

    if (params.password.length > 128) {
      return ValidationFailure.invalidInput(
        field: 'password',
        reason: 'Le mot de passe ne peut pas dépasser 128 caractères',
      );
    }

    if (!_isStrongPassword(params.password)) {
      return ValidationFailure.invalidInput(
        field: 'password',
        reason: 'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial',
      );
    }

    // Validation de la confirmation de mot de passe
    if (params.confirmPassword != params.password) {
      return ValidationFailure.invalidInput(
        field: 'confirmPassword',
        reason: 'Les mots de passe ne correspondent pas',
      );
    }

    // Validation du nom d'affichage (optionnel)
    if (params.displayName != null && params.displayName!.isNotEmpty) {
      if (params.displayName!.length > 50) {
        return ValidationFailure.invalidInput(
          field: 'displayName',
          reason: 'Le nom d\'affichage ne peut pas dépasser 50 caractères',
        );
      }
    }

    return null;
  }

  /// Vérifie si l'email est valide
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Vérifie si le nom d'utilisateur est valide
  bool _isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }

  /// Vérifie si le mot de passe est fort
  bool _isStrongPassword(String password) {
    // Au moins une majuscule
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Au moins une minuscule
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Au moins un chiffre
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Au moins un caractère spécial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }
}

/// Paramètres pour le use case d'inscription
class SignUpParams {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String? displayName;
  final bool acceptTerms;

  const SignUpParams({
    required this.email,
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.displayName,
    this.acceptTerms = false,
  });

  @override
  String toString() {
    return 'SignUpParams(email: $email, username: $username, displayName: $displayName, acceptTerms: $acceptTerms)';
  }
}
