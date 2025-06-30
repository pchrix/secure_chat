/// 🔑 Use Case SignIn - Connexion utilisateur
/// 
/// Gère la logique métier pour la connexion d'un utilisateur.
/// Encapsule les règles de validation et les interactions avec le repository.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la connexion d'un utilisateur
class SignInUseCase implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    // Validation des paramètres d'entrée
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Tentative de connexion
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }

  /// Valide les paramètres de connexion
  ValidationFailure? _validateParams(SignInParams params) {
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

    // Validation du mot de passe
    if (params.password.isEmpty) {
      return ValidationFailure.requiredField(field: 'password');
    }

    if (params.password.length < 6) {
      return ValidationFailure.invalidInput(
        field: 'password',
        reason: 'Le mot de passe doit contenir au moins 6 caractères',
      );
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
}

/// Paramètres pour le use case de connexion
class SignInParams {
  final String email;
  final String password;
  final bool rememberMe;

  const SignInParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  String toString() {
    return 'SignInParams(email: $email, rememberMe: $rememberMe)';
  }
}
