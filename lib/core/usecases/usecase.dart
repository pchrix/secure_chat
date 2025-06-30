/// 🎯 Interface UseCase - Contrat pour les cas d'usage
/// 
/// Définit l'interface commune pour tous les cas d'usage de l'application.
/// Suit le principe de responsabilité unique et facilite les tests.

import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Interface générique pour tous les cas d'usage
abstract class UseCase<Type, Params> {
  /// Exécute le cas d'usage avec les paramètres fournis
  Future<Either<Failure, Type>> call(Params params);
}

/// Interface pour les cas d'usage sans paramètres
abstract class NoParamsUseCase<Type> {
  /// Exécute le cas d'usage sans paramètres
  Future<Either<Failure, Type>> call();
}

/// Interface pour les cas d'usage synchrones
abstract class SyncUseCase<Type, Params> {
  /// Exécute le cas d'usage de manière synchrone
  Either<Failure, Type> call(Params params);
}

/// Interface pour les cas d'usage synchrones sans paramètres
abstract class NoParamsSyncUseCase<Type> {
  /// Exécute le cas d'usage synchrone sans paramètres
  Either<Failure, Type> call();
}

/// Interface pour les cas d'usage qui retournent un Stream
abstract class StreamUseCase<Type, Params> {
  /// Exécute le cas d'usage et retourne un Stream
  Stream<Either<Failure, Type>> call(Params params);
}

/// Interface pour les cas d'usage Stream sans paramètres
abstract class NoParamsStreamUseCase<Type> {
  /// Exécute le cas d'usage Stream sans paramètres
  Stream<Either<Failure, Type>> call();
}

/// Classe pour représenter l'absence de paramètres
class NoParams {
  const NoParams();
  
  @override
  bool operator ==(Object other) => other is NoParams;
  
  @override
  int get hashCode => 0;
}

/// Classe utilitaire pour créer des Either de succès
class Success<T> {
  static Either<Failure, T> value<T>(T value) => Right(value);
}

/// Classe utilitaire pour créer des Either d'échec
class Error {
  static Either<Failure, T> failure<T>(Failure failure) => Left(failure);
}

/// Extension pour simplifier la gestion des Either
extension EitherExtension<L, R> on Either<L, R> {
  /// Exécute une fonction si c'est un succès
  Either<L, R> onSuccess(void Function(R value) callback) {
    return fold(
      (failure) => Left(failure),
      (value) {
        callback(value);
        return Right(value);
      },
    );
  }

  /// Exécute une fonction si c'est un échec
  Either<L, R> onFailure(void Function(L failure) callback) {
    return fold(
      (failure) {
        callback(failure);
        return Left(failure);
      },
      (value) => Right(value),
    );
  }

  /// Transforme la valeur de succès
  Either<L, T> mapSuccess<T>(T Function(R value) mapper) {
    return fold(
      (failure) => Left(failure),
      (value) => Right(mapper(value)),
    );
  }

  /// Transforme la valeur d'échec
  Either<T, R> mapFailure<T>(T Function(L failure) mapper) {
    return fold(
      (failure) => Left(mapper(failure)),
      (value) => Right(value),
    );
  }

  /// Obtient la valeur ou null
  R? get valueOrNull => fold((_) => null, (value) => value);

  /// Obtient l'échec ou null
  L? get failureOrNull => fold((failure) => failure, (_) => null);

  /// Vérifie si c'est un succès
  bool get isSuccess => fold((_) => false, (_) => true);

  /// Vérifie si c'est un échec
  bool get isFailure => fold((_) => true, (_) => false);
}

/// Mixin pour ajouter des fonctionnalités de logging aux use cases
mixin UseCaseLogging<Type, Params> on UseCase<Type, Params> {
  /// Nom du use case pour le logging
  String get useCaseName => runtimeType.toString();

  /// Exécute le use case avec logging
  Future<Either<Failure, Type>> callWithLogging(Params params) async {
    _logStart(params);
    
    final stopwatch = Stopwatch()..start();
    final result = await call(params);
    stopwatch.stop();
    
    result.fold(
      (failure) => _logFailure(failure, stopwatch.elapsedMilliseconds),
      (value) => _logSuccess(value, stopwatch.elapsedMilliseconds),
    );
    
    return result;
  }

  void _logStart(Params params) {
    print('🚀 [$useCaseName] Starting with params: $params');
  }

  void _logSuccess(Type value, int durationMs) {
    print('✅ [$useCaseName] Completed successfully in ${durationMs}ms');
  }

  void _logFailure(Failure failure, int durationMs) {
    print('❌ [$useCaseName] Failed in ${durationMs}ms: ${failure.message}');
  }
}

/// Mixin pour ajouter des fonctionnalités de cache aux use cases
mixin UseCaseCache<Type, Params> on UseCase<Type, Params> {
  final Map<String, _CacheEntry<Type>> _cache = {};
  
  /// Durée de vie du cache (par défaut 5 minutes)
  Duration get cacheDuration => const Duration(minutes: 5);
  
  /// Génère une clé de cache basée sur les paramètres
  String generateCacheKey(Params params) => params.toString();
  
  /// Exécute le use case avec cache
  Future<Either<Failure, Type>> callWithCache(Params params) async {
    final cacheKey = generateCacheKey(params);
    final cachedEntry = _cache[cacheKey];
    
    // Vérifier si le cache est valide
    if (cachedEntry != null && !cachedEntry.isExpired) {
      return Right(cachedEntry.value);
    }
    
    // Exécuter le use case et mettre en cache le résultat
    final result = await call(params);
    
    result.fold(
      (_) {}, // Ne pas mettre en cache les échecs
      (value) {
        _cache[cacheKey] = _CacheEntry(
          value: value,
          expiresAt: DateTime.now().add(cacheDuration),
        );
      },
    );
    
    return result;
  }
  
  /// Vide le cache
  void clearCache() {
    _cache.clear();
  }
  
  /// Supprime une entrée spécifique du cache
  void removeCacheEntry(Params params) {
    final cacheKey = generateCacheKey(params);
    _cache.remove(cacheKey);
  }
}

/// Entrée de cache interne
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  
  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Mixin pour ajouter des fonctionnalités de retry aux use cases
mixin UseCaseRetry<Type, Params> on UseCase<Type, Params> {
  /// Nombre maximum de tentatives (par défaut 3)
  int get maxRetries => 3;
  
  /// Délai entre les tentatives (par défaut 1 seconde)
  Duration get retryDelay => const Duration(seconds: 1);
  
  /// Détermine si une erreur doit déclencher un retry
  bool shouldRetry(Failure failure) {
    return failure is NetworkFailure;
  }
  
  /// Exécute le use case avec retry automatique
  Future<Either<Failure, Type>> callWithRetry(Params params) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      final result = await call(params);
      
      if (result.isSuccess || !shouldRetry(result.failureOrNull!)) {
        return result;
      }
      
      attempts++;
      if (attempts < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }
    
    // Dernière tentative
    return await call(params);
  }
}
