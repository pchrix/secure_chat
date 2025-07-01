/// 🏠 Use Case JoinRoom - Rejoindre un salon
///
/// Ce use case encapsule la logique métier pour rejoindre un salon,
/// incluant la validation, la vérification des permissions et l'ajout du participant.
///
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room.dart';
import '../entities/participant.dart';
import '../repositories/room_repository.dart';
import 'create_room_usecase.dart'; // Pour RoomFailure

/// Use case pour rejoindre un salon
class JoinRoomUseCase implements UseCase<Room, JoinRoomParams> {
  const JoinRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, Room>> call(JoinRoomParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // 1. Récupérer le salon (par ID ou code d'invitation)
      Room? room;

      if (params.roomId != null) {
        final roomResult = await _repository.getRoom(params.roomId!);
        room = roomResult.fold(
          (failure) => null,
          (foundRoom) => foundRoom,
        );
      } else if (params.inviteCode != null) {
        final roomResult =
            await _repository.validateInviteCode(params.inviteCode!);
        room = roomResult.fold(
          (failure) => null,
          (foundRoom) => foundRoom,
        );
      }

      if (room == null) {
        return const Left(RoomFailure.roomNotFound());
      }

      // 2. Vérifier que le salon peut être rejoint
      if (!room.canJoin) {
        if (room.isFull) {
          return const Left(RoomFailure.roomFull());
        }
        if (room.isExpired) {
          return const Left(RoomFailure.roomExpired());
        }
        return const Left(RoomFailure.invalidInput('Salon non disponible'));
      }

      // 3. Vérifier que l'utilisateur n'est pas déjà participant
      final isParticipantResult = await _repository.isParticipant(
        roomId: room.id,
        userId: params.userId,
      );

      final isAlreadyParticipant = isParticipantResult.fold(
        (failure) => false,
        (result) => result,
      );

      if (isAlreadyParticipant) {
        return const Left(
            RoomFailure.invalidInput('Utilisateur déjà participant'));
      }

      // 4. Ajouter l'utilisateur comme participant
      final participantResult = await _repository.addParticipant(
        roomId: room.id,
        userId: params.userId,
        displayName: params.displayName,
        avatarUrl: params.avatarUrl,
        role: ParticipantRole.guest,
        invitedBy: params.invitedBy,
        metadata: params.metadata,
      );

      return participantResult.fold(
        (failure) => Left(failure),
        (participant) async {
          // 5. Mettre à jour le salon avec le nouveau participant
          final updatedRoom = room!.addParticipant();

          // 6. Partager la clé de chiffrement si nécessaire
          if (updatedRoom.isEncrypted && updatedRoom.encryptionKeyId != null) {
            final keyResult =
                await _repository.getEncryptionKey(updatedRoom.id);

            await keyResult.fold(
              (failure) async {
                // Si on ne peut pas récupérer la clé, continuer sans chiffrement
                // (l'utilisateur pourra demander la clé plus tard)
              },
              (encryptionKey) async {
                if (encryptionKey != null) {
                  await _repository.shareEncryptionKey(
                    roomId: updatedRoom.id,
                    userId: params.userId,
                    encryptionKey: encryptionKey,
                  );
                }
              },
            );
          }

          return Right(updatedRoom);
        },
      );
    } catch (e) {
      return Left(RoomFailure.unknown(e.toString()));
    }
  }

  /// Valide les paramètres d'entrée
  RoomFailure? _validateParams(JoinRoomParams params) {
    if (params.userId.trim().isEmpty) {
      return const RoomFailure.invalidInput('ID utilisateur requis');
    }

    if (params.roomId == null && params.inviteCode == null) {
      return const RoomFailure.invalidInput(
          'ID salon ou code d\'invitation requis');
    }

    if (params.roomId != null && params.roomId!.trim().isEmpty) {
      return const RoomFailure.invalidInput('ID salon invalide');
    }

    if (params.inviteCode != null && params.inviteCode!.trim().isEmpty) {
      return const RoomFailure.invalidInput('Code d\'invitation invalide');
    }

    if (params.displayName != null && params.displayName!.length > 50) {
      return const RoomFailure.invalidInput(
          'Nom d\'affichage trop long (max 50 caractères)');
    }

    return null;
  }
}

/// Paramètres pour rejoindre un salon
class JoinRoomParams extends Equatable {
  const JoinRoomParams({
    required this.userId,
    this.roomId,
    this.inviteCode,
    this.displayName,
    this.avatarUrl,
    this.invitedBy,
    this.metadata = const {},
  });

  /// ID de l'utilisateur qui rejoint
  final String userId;

  /// ID du salon à rejoindre (optionnel si inviteCode fourni)
  final String? roomId;

  /// Code d'invitation (optionnel si roomId fourni)
  final String? inviteCode;

  /// Nom d'affichage de l'utilisateur
  final String? displayName;

  /// URL de l'avatar de l'utilisateur
  final String? avatarUrl;

  /// ID de l'utilisateur qui a invité (optionnel)
  final String? invitedBy;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Vérifie si les paramètres sont valides
  bool get isValid {
    return userId.isNotEmpty && (roomId != null || inviteCode != null);
  }

  /// Obtient l'identifiant du salon (roomId ou dérivé du code d'invitation)
  String? get effectiveRoomId => roomId;

  @override
  List<Object?> get props => [
        userId,
        roomId,
        inviteCode,
        displayName,
        avatarUrl,
        invitedBy,
        metadata,
      ];

  @override
  String toString() {
    return 'JoinRoomParams('
        'userId: $userId, '
        'roomId: $roomId, '
        'inviteCode: ${inviteCode != null ? '[HIDDEN]' : 'null'}, '
        'displayName: $displayName'
        ')';
  }
}
