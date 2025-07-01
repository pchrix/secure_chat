/// 🏠 Use Case CreateRoom - Création d'un salon
/// 
/// Ce use case encapsule la logique métier pour la création d'un salon,
/// incluant la validation, la génération de clés de chiffrement et l'initialisation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room.dart';
import '../entities/participant.dart';
import '../repositories/room_repository.dart';

/// Use case pour créer un salon
class CreateRoomUseCase implements UseCase<Room, CreateRoomParams> {
  const CreateRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, Room>> call(CreateRoomParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // 1. Créer le salon
      final createResult = await _repository.createRoom(
        creatorId: params.creatorId,
        name: params.name,
        description: params.description,
        type: params.type,
        maxParticipants: params.maxParticipants,
        durationHours: params.durationHours,
        enableEncryption: params.enableEncryption,
        metadata: params.metadata,
        settings: params.settings,
      );

      return createResult.fold(
        (failure) => Left(failure),
        (room) async {
          // 2. Ajouter le créateur comme participant
          final participantResult = await _repository.addParticipant(
            roomId: room.id,
            userId: params.creatorId,
            displayName: params.creatorDisplayName,
            role: ParticipantRole.creator,
            permissions: _getCreatorPermissions(),
          );

          return participantResult.fold(
            (failure) async {
              // Si l'ajout du participant échoue, supprimer le salon créé
              await _repository.deleteRoom(room.id);
              return Left(failure);
            },
            (participant) async {
              // 3. Générer une clé de chiffrement si nécessaire
              if (params.enableEncryption) {
                final keyResult = await _repository.generateEncryptionKey(room.id);
                
                return keyResult.fold(
                  (failure) async {
                    // Si la génération de clé échoue, supprimer le salon
                    await _repository.deleteRoom(room.id);
                    return Left(failure);
                  },
                  (keyId) {
                    // Mettre à jour le salon avec l'ID de la clé
                    final encryptedRoom = room.copyWith(
                      encryptionKeyId: keyId,
                      participantCount: 1, // Le créateur est maintenant participant
                    );
                    return Right(encryptedRoom);
                  },
                );
              }

              // Salon créé sans chiffrement
              final finalRoom = room.copyWith(
                participantCount: 1, // Le créateur est maintenant participant
              );
              return Right(finalRoom);
            },
          );
        },
      );
    } catch (e) {
      return Left(RoomFailure.unknown(e.toString()));
    }
  }

  /// Valide les paramètres d'entrée
  RoomFailure? _validateParams(CreateRoomParams params) {
    if (params.creatorId.trim().isEmpty) {
      return const RoomFailure.invalidInput('ID créateur requis');
    }

    if (params.name.trim().isEmpty) {
      return const RoomFailure.invalidInput('Nom du salon requis');
    }

    if (params.name.length > 100) {
      return const RoomFailure.invalidInput('Nom trop long (max 100 caractères)');
    }

    if (params.description != null && params.description!.length > 500) {
      return const RoomFailure.invalidInput('Description trop longue (max 500 caractères)');
    }

    if (params.maxParticipants < 2) {
      return const RoomFailure.invalidInput('Minimum 2 participants requis');
    }

    if (params.maxParticipants > 100) {
      return const RoomFailure.invalidInput('Maximum 100 participants autorisés');
    }

    if (params.durationHours != null) {
      if (params.durationHours! < 1) {
        return const RoomFailure.invalidInput('Durée minimum 1 heure');
      }
      if (params.durationHours! > 168) { // 7 jours
        return const RoomFailure.invalidInput('Durée maximum 168 heures (7 jours)');
      }
    }

    return null;
  }

  /// Obtient les permissions par défaut du créateur
  Map<String, bool> _getCreatorPermissions() {
    return {
      'manage_room': true,
      'invite_users': true,
      'kick_users': true,
      'ban_users': true,
      'manage_encryption': true,
      'delete_room': true,
      'archive_room': true,
    };
  }
}

/// Paramètres pour la création d'un salon
class CreateRoomParams extends Equatable {
  const CreateRoomParams({
    required this.creatorId,
    required this.name,
    this.description,
    this.creatorDisplayName,
    this.type = RoomType.ephemeral,
    this.maxParticipants = 2,
    this.durationHours,
    this.enableEncryption = true,
    this.metadata = const {},
    this.settings = const {},
  });

  /// ID du créateur du salon
  final String creatorId;

  /// Nom du salon
  final String name;

  /// Description du salon (optionnel)
  final String? description;

  /// Nom d'affichage du créateur
  final String? creatorDisplayName;

  /// Type de salon
  final RoomType type;

  /// Nombre maximum de participants
  final int maxParticipants;

  /// Durée en heures (pour les salons éphémères)
  final int? durationHours;

  /// Activer le chiffrement
  final bool enableEncryption;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Paramètres du salon
  final Map<String, dynamic> settings;

  /// Obtient la date d'expiration calculée
  DateTime? get expirationDate {
    if (durationHours == null) return null;
    return DateTime.now().add(Duration(hours: durationHours!));
  }

  /// Vérifie si la configuration est valide pour un salon éphémère
  bool get isValidEphemeralConfig {
    if (type != RoomType.ephemeral) return true;
    return durationHours != null && durationHours! > 0;
  }

  @override
  List<Object?> get props => [
        creatorId,
        name,
        description,
        creatorDisplayName,
        type,
        maxParticipants,
        durationHours,
        enableEncryption,
        metadata,
        settings,
      ];

  @override
  String toString() {
    return 'CreateRoomParams('
        'creatorId: $creatorId, '
        'name: $name, '
        'type: $type, '
        'maxParticipants: $maxParticipants, '
        'durationHours: $durationHours, '
        'enableEncryption: $enableEncryption'
        ')';
  }
}

/// Échecs spécifiques aux salons
class RoomFailure extends Failure {
  const RoomFailure({
    required super.message,
    required super.code,
  });

  const RoomFailure.roomNotFound()
      : super(
          message: 'Salon introuvable',
          code: 'ROOM_NOT_FOUND',
        );

  const RoomFailure.roomFull()
      : super(
          message: 'Salon complet',
          code: 'ROOM_FULL',
        );

  const RoomFailure.roomExpired()
      : super(
          message: 'Salon expiré',
          code: 'ROOM_EXPIRED',
        );

  const RoomFailure.notParticipant()
      : super(
          message: 'Utilisateur non participant',
          code: 'NOT_PARTICIPANT',
        );

  const RoomFailure.insufficientPermissions()
      : super(
          message: 'Permissions insuffisantes',
          code: 'INSUFFICIENT_PERMISSIONS',
        );

  const RoomFailure.invalidInviteCode()
      : super(
          message: 'Code d\'invitation invalide',
          code: 'INVALID_INVITE_CODE',
        );

  const RoomFailure.encryptionFailed()
      : super(
          message: 'Échec du chiffrement',
          code: 'ENCRYPTION_FAILED',
        );

  const RoomFailure.invalidInput(String details)
      : super(
          message: 'Données invalides: $details',
          code: 'INVALID_INPUT',
        );

  const RoomFailure.unknown(String details)
      : super(
          message: 'Erreur inconnue: $details',
          code: 'UNKNOWN_ERROR',
        );

  @override
  List<Object?> get props => [message, code];
}
