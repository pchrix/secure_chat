/// 💬 Use Case GetMessages - Récupération des messages
/// 
/// Ce use case encapsule la logique métier pour récupérer les messages
/// d'une conversation, incluant le déchiffrement et la pagination.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';
import 'send_message_usecase.dart'; // Pour ChatFailure

/// Use case pour récupérer les messages d'une conversation
class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  const GetMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // 1. Vérifier que la conversation existe
      final conversationResult = await _repository.getConversation(params.conversationId);
      
      return conversationResult.fold(
        (failure) => Left(failure),
        (conversation) async {
          if (conversation == null) {
            return const Left(ChatFailure.conversationNotFound());
          }

          // 2. Vérifier que l'utilisateur est participant (si spécifié)
          if (params.userId != null) {
            final isParticipantResult = await _repository.isParticipant(
              conversationId: params.conversationId,
              userId: params.userId!,
            );

            final isParticipant = isParticipantResult.fold(
              (failure) => false,
              (result) => result,
            );

            if (!isParticipant) {
              return const Left(ChatFailure.notParticipant());
            }
          }

          // 3. Récupérer les messages
          final messagesResult = await _repository.getMessages(
            conversationId: params.conversationId,
            limit: params.limit,
            beforeMessageId: params.beforeMessageId,
            afterMessageId: params.afterMessageId,
          );

          return messagesResult.fold(
            (failure) => Left(failure),
            (messages) async {
              // 4. Déchiffrer les messages si nécessaire
              if (conversation.isEncrypted && params.decryptMessages) {
                final decryptedMessages = await _decryptMessages(
                  messages,
                  conversation.id,
                );
                return Right(decryptedMessages);
              }

              return Right(messages);
            },
          );
        },
      );
    } catch (e) {
      return Left(ChatFailure.unknown(e.toString()));
    }
  }

  /// Déchiffre une liste de messages
  Future<List<Message>> _decryptMessages(
    List<Message> messages,
    String conversationId,
  ) async {
    final decryptedMessages = <Message>[];

    for (final message in messages) {
      if (message.isEncrypted) {
        final decryptionResult = await _repository.decryptMessage(
          conversationId: conversationId,
          encryptedContent: message.content,
        );

        final decryptedMessage = decryptionResult.fold(
          (failure) => message.copyWith(
            encryptionStatus: EncryptionStatus.failed,
          ),
          (decryptedContent) => message.markAsDecrypted(decryptedContent),
        );

        decryptedMessages.add(decryptedMessage);
      } else {
        decryptedMessages.add(message);
      }
    }

    return decryptedMessages;
  }

  /// Valide les paramètres d'entrée
  ChatFailure? _validateParams(GetMessagesParams params) {
    if (params.conversationId.trim().isEmpty) {
      return const ChatFailure.invalidInput('ID de conversation requis');
    }

    if (params.limit != null && params.limit! <= 0) {
      return const ChatFailure.invalidInput('Limite doit être positive');
    }

    if (params.limit != null && params.limit! > 1000) {
      return const ChatFailure.invalidInput('Limite maximum 1000 messages');
    }

    return null;
  }
}

/// Paramètres pour la récupération des messages
class GetMessagesParams extends Equatable {
  const GetMessagesParams({
    required this.conversationId,
    this.userId,
    this.limit,
    this.beforeMessageId,
    this.afterMessageId,
    this.decryptMessages = true,
    this.markAsRead = false,
  });

  /// ID de la conversation
  final String conversationId;

  /// ID de l'utilisateur (pour vérification des permissions)
  final String? userId;

  /// Nombre maximum de messages à récupérer
  final int? limit;

  /// ID du message avant lequel récupérer (pagination)
  final String? beforeMessageId;

  /// ID du message après lequel récupérer (pagination)
  final String? afterMessageId;

  /// Déchiffrer automatiquement les messages
  final bool decryptMessages;

  /// Marquer les messages comme lus
  final bool markAsRead;

  /// Vérifie si c'est une pagination vers le passé
  bool get isPaginatingBackward => beforeMessageId != null;

  /// Vérifie si c'est une pagination vers le futur
  bool get isPaginatingForward => afterMessageId != null;

  /// Vérifie si c'est une récupération initiale
  bool get isInitialLoad => beforeMessageId == null && afterMessageId == null;

  @override
  List<Object?> get props => [
        conversationId,
        userId,
        limit,
        beforeMessageId,
        afterMessageId,
        decryptMessages,
        markAsRead,
      ];

  @override
  String toString() {
    return 'GetMessagesParams('
        'conversationId: $conversationId, '
        'userId: $userId, '
        'limit: $limit, '
        'beforeMessageId: $beforeMessageId, '
        'afterMessageId: $afterMessageId, '
        'decryptMessages: $decryptMessages, '
        'markAsRead: $markAsRead'
        ')';
  }
}
