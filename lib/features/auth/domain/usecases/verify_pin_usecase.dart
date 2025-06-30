/// 🔐 Use Case VerifyPin - Vérification du code PIN
/// 
/// Gère la logique métier pour la vérification du code PIN utilisateur.
/// Inclut la gestion des tentatives échouées et du verrouillage temporaire.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case pour la vérification du code PIN
class VerifyPinUseCase implements UseCase<bool, VerifyPinParams> {
  final AuthRepository repository;

  const VerifyPinUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyPinParams params) async {
    // Validation des paramètres d'entrée
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Vérification du PIN via le repository
      return await repository.verifyPin(pin: params.pin);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  /// Valide les paramètres de vérification PIN
  ValidationFailure? _validateParams(VerifyPinParams params) {
    // Validation du PIN
    if (params.pin.isEmpty) {
      return ValidationFailure.requiredField(field: 'pin');
    }

    if (params.pin.length != 6) {
      return ValidationFailure.invalidInput(
        field: 'pin',
        reason: 'Le code PIN doit contenir exactement 6 chiffres',
      );
    }

    if (!_isValidPin(params.pin)) {
      return ValidationFailure.invalidFormat(
        field: 'pin',
        expectedFormat: '6 chiffres (0-9)',
      );
    }

    return null;
  }

  /// Vérifie si le PIN est valide (6 chiffres)
  bool _isValidPin(String pin) {
    final pinRegex = RegExp(r'^\d{6}$');
    return pinRegex.hasMatch(pin);
  }
}

/// Use case pour la configuration d'un nouveau PIN
class SetupPinUseCase implements UseCase<void, SetupPinParams> {
  final AuthRepository repository;

  const SetupPinUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetupPinParams params) async {
    // Validation des paramètres d'entrée
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Configuration du PIN via le repository
      return await repository.setupPin(pin: params.pin);
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  /// Valide les paramètres de configuration PIN
  ValidationFailure? _validateParams(SetupPinParams params) {
    // Validation du PIN
    if (params.pin.isEmpty) {
      return ValidationFailure.requiredField(field: 'pin');
    }

    if (params.pin.length != 6) {
      return ValidationFailure.invalidInput(
        field: 'pin',
        reason: 'Le code PIN doit contenir exactement 6 chiffres',
      );
    }

    if (!_isValidPin(params.pin)) {
      return ValidationFailure.invalidFormat(
        field: 'pin',
        expectedFormat: '6 chiffres (0-9)',
      );
    }

    // Validation de la confirmation
    if (params.confirmPin != params.pin) {
      return ValidationFailure.invalidInput(
        field: 'confirmPin',
        reason: 'Les codes PIN ne correspondent pas',
      );
    }

    // Vérification de la sécurité du PIN
    if (_isWeakPin(params.pin)) {
      return ValidationFailure.invalidInput(
        field: 'pin',
        reason: 'Le code PIN est trop simple. Évitez les séquences ou répétitions',
      );
    }

    return null;
  }

  /// Vérifie si le PIN est valide (6 chiffres)
  bool _isValidPin(String pin) {
    final pinRegex = RegExp(r'^\d{6}$');
    return pinRegex.hasMatch(pin);
  }

  /// Vérifie si le PIN est faible (patterns simples)
  bool _isWeakPin(String pin) {
    // PIN avec tous les mêmes chiffres
    if (RegExp(r'^(\d)\1{5}$').hasMatch(pin)) {
      return true; // 111111, 222222, etc.
    }

    // Séquences croissantes
    if (pin == '123456' || pin == '234567' || pin == '345678' || 
        pin == '456789' || pin == '567890') {
      return true;
    }

    // Séquences décroissantes
    if (pin == '654321' || pin == '765432' || pin == '876543' || 
        pin == '987654' || pin == '098765') {
      return true;
    }

    // Patterns communs
    const commonPatterns = [
      '000000', '111111', '222222', '333333', '444444', '555555',
      '666666', '777777', '888888', '999999', '123456', '654321',
      '000001', '111111', '121212', '131313', '141414', '151515',
      '161616', '171717', '181818', '191919', '202020', '212121',
    ];

    return commonPatterns.contains(pin);
  }
}

/// Use case pour changer le PIN existant
class ChangePinUseCase implements UseCase<void, ChangePinParams> {
  final AuthRepository repository;

  const ChangePinUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePinParams params) async {
    // Validation des paramètres d'entrée
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Changement du PIN via le repository
      return await repository.changePin(
        currentPin: params.currentPin,
        newPin: params.newPin,
      );
    } catch (e) {
      return Left(SystemFailure.unexpected(
        error: e.toString(),
        stackTrace: StackTrace.current,
      ));
    }
  }

  /// Valide les paramètres de changement PIN
  ValidationFailure? _validateParams(ChangePinParams params) {
    // Validation du PIN actuel
    if (params.currentPin.isEmpty) {
      return ValidationFailure.requiredField(field: 'currentPin');
    }

    if (!_isValidPin(params.currentPin)) {
      return ValidationFailure.invalidFormat(
        field: 'currentPin',
        expectedFormat: '6 chiffres (0-9)',
      );
    }

    // Validation du nouveau PIN
    if (params.newPin.isEmpty) {
      return ValidationFailure.requiredField(field: 'newPin');
    }

    if (!_isValidPin(params.newPin)) {
      return ValidationFailure.invalidFormat(
        field: 'newPin',
        expectedFormat: '6 chiffres (0-9)',
      );
    }

    // Vérification que le nouveau PIN est différent
    if (params.currentPin == params.newPin) {
      return ValidationFailure.invalidInput(
        field: 'newPin',
        reason: 'Le nouveau PIN doit être différent de l\'ancien',
      );
    }

    // Validation de la confirmation
    if (params.confirmNewPin != params.newPin) {
      return ValidationFailure.invalidInput(
        field: 'confirmNewPin',
        reason: 'Les nouveaux codes PIN ne correspondent pas',
      );
    }

    return null;
  }

  /// Vérifie si le PIN est valide (6 chiffres)
  bool _isValidPin(String pin) {
    final pinRegex = RegExp(r'^\d{6}$');
    return pinRegex.hasMatch(pin);
  }
}

/// Paramètres pour la vérification PIN
class VerifyPinParams {
  final String pin;

  const VerifyPinParams({
    required this.pin,
  });

  @override
  String toString() {
    return 'VerifyPinParams(pin: [HIDDEN])';
  }
}

/// Paramètres pour la configuration PIN
class SetupPinParams {
  final String pin;
  final String confirmPin;

  const SetupPinParams({
    required this.pin,
    required this.confirmPin,
  });

  @override
  String toString() {
    return 'SetupPinParams(pin: [HIDDEN], confirmPin: [HIDDEN])';
  }
}

/// Paramètres pour le changement PIN
class ChangePinParams {
  final String currentPin;
  final String newPin;
  final String confirmNewPin;

  const ChangePinParams({
    required this.currentPin,
    required this.newPin,
    required this.confirmNewPin,
  });

  @override
  String toString() {
    return 'ChangePinParams(currentPin: [HIDDEN], newPin: [HIDDEN], confirmNewPin: [HIDDEN])';
  }
}
