/// 🏠 Use Case GetRooms - Récupération des salons
/// 
/// Ce use case encapsule la logique métier pour récupérer les salons
/// d'un utilisateur, incluant le filtrage et le tri.
/// 
/// Conforme aux meilleures pratiques Context7 + Exa pour Clean Architecture.

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';
import 'create_room_usecase.dart'; // Pour RoomFailure

/// Use case pour récupérer les salons
class GetRoomsUseCase implements UseCase<List<Room>, GetRoomsParams> {
  const GetRoomsUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<Either<Failure, List<Room>>> call(GetRoomsParams params) async {
    // Validation des paramètres
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    try {
      // Récupérer les salons selon le filtre
      late Future<Either<Failure, List<Room>>> roomsResult;

      switch (params.filter) {
        case RoomFilter.all:
          roomsResult = _repository.getRooms();
          break;
        case RoomFilter.active:
          roomsResult = _repository.getActiveRooms();
          break;
        case RoomFilter.waiting:
          roomsResult = _repository.getWaitingRooms();
          break;
        case RoomFilter.archived:
          roomsResult = _repository.getArchivedRooms();
          break;
        case RoomFilter.recent:
          roomsResult = _repository.getRecentRooms(limit: params.limit ?? 20);
          break;
        case RoomFilter.byCreator:
          if (params.creatorId == null) {
            return const Left(RoomFailure.invalidInput('ID créateur requis pour le filtre byCreator'));
          }
          roomsResult = _repository.getRoomsByCreator(params.creatorId!);
          break;
      }

      return roomsResult.then((result) {
        return result.fold(
          (failure) => Left(failure),
          (rooms) {
            // Appliquer les filtres additionnels
            var filteredRooms = rooms;

            // Filtrer par type si spécifié
            if (params.type != null) {
              filteredRooms = filteredRooms
                  .where((room) => room.type == params.type)
                  .toList();
            }

            // Filtrer par statut si spécifié
            if (params.status != null) {
              filteredRooms = filteredRooms
                  .where((room) => room.status == params.status)
                  .toList();
            }

            // Exclure les salons expirés si demandé
            if (params.excludeExpired) {
              filteredRooms = filteredRooms
                  .where((room) => !room.isExpired)
                  .toList();
            }

            // Exclure les salons archivés si demandé
            if (params.excludeArchived) {
              filteredRooms = filteredRooms
                  .where((room) => !room.isArchived)
                  .toList();
            }

            // Exclure les salons supprimés si demandé
            if (params.excludeDeleted) {
              filteredRooms = filteredRooms
                  .where((room) => !room.isDeleted)
                  .toList();
            }

            // Trier les salons
            _sortRooms(filteredRooms, params.sortBy, params.sortOrder);

            // Appliquer la limite si spécifiée
            if (params.limit != null && params.limit! > 0) {
              filteredRooms = filteredRooms.take(params.limit!).toList();
            }

            return Right(filteredRooms);
          },
        );
      });
    } catch (e) {
      return Left(RoomFailure.unknown(e.toString()));
    }
  }

  /// Trie les salons selon les critères spécifiés
  void _sortRooms(List<Room> rooms, RoomSortBy sortBy, SortOrder sortOrder) {
    rooms.sort((a, b) {
      int comparison;

      switch (sortBy) {
        case RoomSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case RoomSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case RoomSortBy.participantCount:
          comparison = a.participantCount.compareTo(b.participantCount);
          break;
        case RoomSortBy.lastActivity:
          final aActivity = a.lastActivityAt ?? a.createdAt;
          final bActivity = b.lastActivityAt ?? b.createdAt;
          comparison = aActivity.compareTo(bActivity);
          break;
        case RoomSortBy.expiresAt:
          if (a.expiresAt == null && b.expiresAt == null) {
            comparison = 0;
          } else if (a.expiresAt == null) {
            comparison = 1; // Les salons sans expiration à la fin
          } else if (b.expiresAt == null) {
            comparison = -1;
          } else {
            comparison = a.expiresAt!.compareTo(b.expiresAt!);
          }
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  /// Valide les paramètres d'entrée
  RoomFailure? _validateParams(GetRoomsParams params) {
    if (params.limit != null && params.limit! <= 0) {
      return const RoomFailure.invalidInput('Limite doit être positive');
    }

    if (params.limit != null && params.limit! > 1000) {
      return const RoomFailure.invalidInput('Limite maximum 1000 salons');
    }

    return null;
  }
}

/// Filtres pour la récupération des salons
enum RoomFilter {
  all,
  active,
  waiting,
  archived,
  recent,
  byCreator,
}

/// Critères de tri des salons
enum RoomSortBy {
  createdAt,
  name,
  participantCount,
  lastActivity,
  expiresAt,
}

/// Ordre de tri
enum SortOrder {
  ascending,
  descending,
}

/// Paramètres pour la récupération des salons
class GetRoomsParams extends Equatable {
  const GetRoomsParams({
    this.filter = RoomFilter.all,
    this.type,
    this.status,
    this.creatorId,
    this.excludeExpired = true,
    this.excludeArchived = false,
    this.excludeDeleted = true,
    this.sortBy = RoomSortBy.lastActivity,
    this.sortOrder = SortOrder.descending,
    this.limit,
  });

  /// Filtre principal à appliquer
  final RoomFilter filter;

  /// Type de salon à filtrer (optionnel)
  final RoomType? type;

  /// Statut de salon à filtrer (optionnel)
  final RoomStatus? status;

  /// ID du créateur pour le filtre byCreator
  final String? creatorId;

  /// Exclure les salons expirés
  final bool excludeExpired;

  /// Exclure les salons archivés
  final bool excludeArchived;

  /// Exclure les salons supprimés
  final bool excludeDeleted;

  /// Critère de tri
  final RoomSortBy sortBy;

  /// Ordre de tri
  final SortOrder sortOrder;

  /// Nombre maximum de salons à retourner
  final int? limit;

  /// Crée des paramètres pour récupérer tous les salons
  const GetRoomsParams.all({
    RoomSortBy sortBy = RoomSortBy.lastActivity,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) : this(
          filter: RoomFilter.all,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
        );

  /// Crée des paramètres pour récupérer les salons actifs
  const GetRoomsParams.active({
    RoomSortBy sortBy = RoomSortBy.lastActivity,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) : this(
          filter: RoomFilter.active,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
        );

  /// Crée des paramètres pour récupérer les salons en attente
  const GetRoomsParams.waiting({
    RoomSortBy sortBy = RoomSortBy.createdAt,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
  }) : this(
          filter: RoomFilter.waiting,
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
        );

  /// Crée des paramètres pour récupérer les salons récents
  const GetRoomsParams.recent({
    int limit = 20,
  }) : this(
          filter: RoomFilter.recent,
          sortBy: RoomSortBy.createdAt,
          sortOrder: SortOrder.descending,
          limit: limit,
        );

  @override
  List<Object?> get props => [
        filter,
        type,
        status,
        creatorId,
        excludeExpired,
        excludeArchived,
        excludeDeleted,
        sortBy,
        sortOrder,
        limit,
      ];

  @override
  String toString() {
    return 'GetRoomsParams('
        'filter: $filter, '
        'type: $type, '
        'status: $status, '
        'sortBy: $sortBy, '
        'sortOrder: $sortOrder, '
        'limit: $limit'
        ')';
  }
}
