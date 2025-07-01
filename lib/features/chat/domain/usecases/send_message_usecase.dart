/// 💬 Use Case SendMessage - Envoi d'un message
/// 
/// Ce use case encapsule la logique métier pour l'envoi d'un message,
/// incluant la validation, le chiffrement et la persistance.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

/// Use case pour envoyer un message
class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // 1. Vérifier que la conversation existe et est active
      final conversationResult = await _repository.getConversation(params.conversationId);
      
      return conversationResult.fold(
        (failure) => Left(failure),
        (conversation) async {
          if (conversation == null) {
            return const Left(ChatFailure.conversationNotFound());
          }

          if (!conversation.allowsMessaging) {
            return const Left(ChatFailure.conversationNotActive());
          }

          // 2. Vérifier que l'utilisateur est participant
          final isParticipantResult = await _repository.isParticipant(
            conversationId: params.conversationId,
            userId: params.senderId,
          );

          return isParticipantResult.fold(
            (failure) => Left(failure),
            (isParticipant) async {
              if (!isParticipant) {
                return const Left(ChatFailure.notParticipant());
              }

              // 3. Chiffrer le contenu si nécessaire
              String finalContent = params.content;
              if (conversation.isEncrypted) {
                final encryptionResult = await _repository.encryptMessage(
                  conversationId: params.conversationId,
                  content: params.content,
                );

                final encryptedContent = encryptionResult.fold(
                  (failure) => null,
                  (encrypted) => encrypted,
                );

                if (encryptedContent == null) {
                  return const Left(ChatFailure.encryptionFailed());
                }

                finalContent = encryptedContent;
              }

              // 4. Envoyer le message
              final sendResult = await _repository.sendMessage(
                conversationId: params.conversationId,
                senderId: params.senderId,
                content: finalContent,
                type: params.type,
                replyToId: params.replyToId,
                metadata: params.metadata,
              );

              return sendResult.fold(
                (failure) => Left(failure),
                (message) async {
                  // 5. Marquer le message comme déchiffré si chiffrement activé
                  if (conversation.isEncrypted) {
                    final decryptedMessage = message.markAsDecrypted(params.content);
                    return Right(decryptedMessage);
                  }

                  return Right(message);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ChatFailure.unknown(e.toString()));
    }
  }

  /// Valide les paramètres d'entrée
  ChatFailure? _validateParams(SendMessageParams params) {
    if (params.conversationId.trim().isEmpty) {
      return const ChatFailure.invalidInput('ID de conversation requis');
    }

    if (params.senderId.trim().isEmpty) {
      return const ChatFailure.invalidInput('ID expéditeur requis');
    }

    if (params.content.trim().isEmpty) {
      return const ChatFailure.invalidInput('Contenu du message requis');
    }

    if (params.content.length > 10000) {
      return const ChatFailure.invalidInput('Message trop long (max 10000 caractères)');
    }

    return null;
  }
}

/// Paramètres pour l'envoi d'un message
class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.replyToId,
    this.metadata = const {},
  });

  /// ID de la conversation
  final String conversationId;

  /// ID de l'expéditeur
  final String senderId;

  /// Contenu du message
  final String content;

  /// Type de message
  final MessageType type;

  /// ID du message auquel on répond (optionnel)
  final String? replyToId;

  /// Métadonnées additionnelles
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
        conversationId,
        senderId,
        content,
        type,
        replyToId,
        metadata,
      ];

  @override
  String toString() {
    return 'SendMessageParams('
        'conversationId: $conversationId, '
        'senderId: $senderId, '
        'type: $type, '
        'contentLength: ${content.length}'
        ')';
  }
}

/// Échecs spécifiques au chat
class ChatFailure extends Failure {
  const ChatFailure({
    required super.message,
    required super.code,
  });

  const ChatFailure.conversationNotFound()
      : super(
          message: 'Conversation introuvable',
          code: 'CONVERSATION_NOT_FOUND',
        );

  const ChatFailure.conversationNotActive()
      : super(
          message: 'Conversation non active',
          code: 'CONVERSATION_NOT_ACTIVE',
        );

  const ChatFailure.notParticipant()
      : super(
          message: 'Utilisateur non participant',
          code: 'NOT_PARTICIPANT',
        );

  const ChatFailure.encryptionFailed()
      : super(
          message: 'Échec du chiffrement',
          code: 'ENCRYPTION_FAILED',
        );

  const ChatFailure.decryptionFailed()
      : super(
          message: 'Échec du déchiffrement',
          code: 'DECRYPTION_FAILED',
        );

  const ChatFailure.invalidInput(String details)
      : super(
          message: 'Données invalides: $details',
          code: 'INVALID_INPUT',
        );

  const ChatFailure.messageTooLong()
      : super(
          message: 'Message trop long',
          code: 'MESSAGE_TOO_LONG',
        );

  const ChatFailure.rateLimitExceeded()
      : super(
          message: 'Limite de débit dépassée',
          code: 'RATE_LIMIT_EXCEEDED',
        );

  const ChatFailure.unknown(String details)
      : super(
          message: 'Erreur inconnue: $details',
          code: 'UNKNOWN_ERROR',
        );

  @override
  List<Object?> get props => [message, code];
}
