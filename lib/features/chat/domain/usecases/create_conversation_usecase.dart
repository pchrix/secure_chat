/// 💬 Use Case CreateConversation - Création d'une conversation
/// 
/// Ce use case encapsule la logique métier pour la création d'une conversation,
/// incluant la validation, la génération de clés de chiffrement et l'initialisation.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';
import 'send_message_usecase.dart'; // Pour ChatFailure

/// Use case pour créer une conversation
class CreateConversationUseCase implements UseCase<Conversation, CreateConversationParams> {
  const CreateConversationUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, Conversation>> call(CreateConversationParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // 1. Créer la conversation
      final createResult = await _repository.createConversation(
        creatorId: params.creatorId,
        name: params.name,
        description: params.description,
        type: params.type,
        maxParticipants: params.maxParticipants,
        durationHours: params.durationHours,
        metadata: params.metadata,
      );

      return createResult.fold(
        (failure) => Left(failure),
        (conversation) async {
          // 2. Générer une clé de chiffrement si nécessaire
          if (params.enableEncryption) {
            final keyResult = await _repository.generateEncryptionKey(conversation.id);
            
            return keyResult.fold(
              (failure) async {
                // Si la génération de clé échoue, supprimer la conversation créée
                await _repository.deleteConversation(conversation.id);
                return Left(failure);
              },
              (keyId) {
                // Mettre à jour la conversation avec l'ID de la clé
                final encryptedConversation = conversation.copyWith(
                  encryptionKeyId: keyId,
                );
                return Right(encryptedConversation);
              },
            );
          }

          // 3. Ajouter le créateur comme participant
          final participantResult = await _repository.addParticipant(
            conversationId: conversation.id,
            userId: params.creatorId,
          );

          return participantResult.fold(
            (failure) async {
              // Si l'ajout du participant échoue, supprimer la conversation
              await _repository.deleteConversation(conversation.id);
              return Left(failure);
            },
            (_) {
              // Mettre à jour le nombre de participants
              final updatedConversation = conversation.addParticipant();
              return Right(updatedConversation);
            },
          );
        },
      );
    } catch (e) {
      return Left(ChatFailure.unknown(e.toString()));
    }
  }

  /// Valide les paramètres d'entrée
  ChatFailure? _validateParams(CreateConversationParams params) {
    if (params.creatorId.trim().isEmpty) {
      return const ChatFailure.invalidInput('ID créateur requis');
    }

    if (params.name != null && params.name!.length > 100) {
      return const ChatFailure.invalidInput('Nom trop long (max 100 caractères)');
    }

    if (params.description != null && params.description!.length > 500) {
      return const ChatFailure.invalidInput('Description trop longue (max 500 caractères)');
    }

    if (params.maxParticipants < 2) {
      return const ChatFailure.invalidInput('Minimum 2 participants requis');
    }

    if (params.maxParticipants > 100) {
      return const ChatFailure.invalidInput('Maximum 100 participants autorisés');
    }

    if (params.durationHours != null) {
      if (params.durationHours! < 1) {
        return const ChatFailure.invalidInput('Durée minimum 1 heure');
      }
      if (params.durationHours! > 168) { // 7 jours
        return const ChatFailure.invalidInput('Durée maximum 168 heures (7 jours)');
      }
    }

    return null;
  }
}

/// Paramètres pour la création d'une conversation
class CreateConversationParams extends Equatable {
  const CreateConversationParams({
    required this.creatorId,
    this.name,
    this.description,
    this.type = ConversationType.ephemeral,
    this.maxParticipants = 2,
    this.durationHours,
    this.enableEncryption = true,
    this.metadata = const {},
  });

  /// ID du créateur de la conversation
  final String creatorId;

  /// Nom de la conversation (optionnel)
  final String? name;

  /// Description de la conversation (optionnel)
  final String? description;

  /// Type de conversation
  final ConversationType type;

  /// Nombre maximum de participants
  final int maxParticipants;

  /// Durée en heures (pour les conversations éphémères)
  final int? durationHours;

  /// Activer le chiffrement
  final bool enableEncryption;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  /// Obtient la date d'expiration calculée
  DateTime? get expirationDate {
    if (durationHours == null) return null;
    return DateTime.now().add(Duration(hours: durationHours!));
  }

  /// Vérifie si la configuration est valide pour une conversation éphémère
  bool get isValidEphemeralConfig {
    if (type != ConversationType.ephemeral) return true;
    return durationHours != null && durationHours! > 0;
  }

  @override
  List<Object?> get props => [
        creatorId,
        name,
        description,
        type,
        maxParticipants,
        durationHours,
        enableEncryption,
        metadata,
      ];

  @override
  String toString() {
    return 'CreateConversationParams('
        'creatorId: $creatorId, '
        'name: $name, '
        'type: $type, '
        'maxParticipants: $maxParticipants, '
        'durationHours: $durationHours, '
        'enableEncryption: $enableEncryption'
        ')';
  }
}
