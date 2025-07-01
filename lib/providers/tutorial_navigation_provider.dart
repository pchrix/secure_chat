/// 📖 Tutorial Navigation Provider - Gestion de la navigation du tutoriel
///
/// Provider Riverpod optimisé pour gérer la navigation dans le tutoriel
/// avec patterns Riverpod 2024 et gestion d'état réactive.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MODÈLE D'ÉTAT DE NAVIGATION
// ============================================================================

/// État de la navigation du tutoriel
class TutorialNavigationState {
  const TutorialNavigationState({
    required this.currentPage,
    required this.totalPages,
    required this.isCompleted,
    required this.canGoNext,
    required this.canGoPrevious,
  });

  final int currentPage;
  final int totalPages;
  final bool isCompleted;
  final bool canGoNext;
  final bool canGoPrevious;

  /// État initial par défaut
  factory TutorialNavigationState.initial({int totalPages = 5}) {
    return TutorialNavigationState(
      currentPage: 0,
      totalPages: totalPages,
      isCompleted: false,
      canGoNext: totalPages > 1,
      canGoPrevious: false,
    );
  }

  /// Copie avec modifications
  TutorialNavigationState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isCompleted,
    bool? canGoNext,
    bool? canGoPrevious,
  }) {
    return TutorialNavigationState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
      canGoNext: canGoNext ?? this.canGoNext,
      canGoPrevious: canGoPrevious ?? this.canGoPrevious,
    );
  }

  /// Calcule l'état de navigation basé sur la page actuelle
  TutorialNavigationState _calculateNavigationState() {
    final isLastPage = currentPage >= totalPages - 1;
    final isFirstPage = currentPage <= 0;

    return copyWith(
      isCompleted: isLastPage,
      canGoNext: !isLastPage,
      canGoPrevious: !isFirstPage,
    );
  }

  /// Pourcentage de progression
  double get progressPercentage {
    if (totalPages <= 1) return 1.0;
    return (currentPage + 1) / totalPages;
  }

  /// Index de la page suivante (null si dernière page)
  int? get nextPageIndex {
    return canGoNext ? currentPage + 1 : null;
  }

  /// Index de la page précédente (null si première page)
  int? get previousPageIndex {
    return canGoPrevious ? currentPage - 1 : null;
  }

  /// Titre de la page actuelle
  String get currentPageTitle {
    switch (currentPage) {
      case 0:
        return 'Bienvenue';
      case 1:
        return 'Sécurité';
      case 2:
        return 'Salons';
      case 3:
        return 'Chiffrement';
      case 4:
        return 'Prêt !';
      default:
        return 'Page ${currentPage + 1}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialNavigationState &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          totalPages == other.totalPages &&
          isCompleted == other.isCompleted &&
          canGoNext == other.canGoNext &&
          canGoPrevious == other.canGoPrevious;

  @override
  int get hashCode =>
      currentPage.hashCode ^
      totalPages.hashCode ^
      isCompleted.hashCode ^
      canGoNext.hashCode ^
      canGoPrevious.hashCode;

  @override
  String toString() {
    return 'TutorialNavigationState{currentPage: $currentPage, totalPages: $totalPages, isCompleted: $isCompleted, canGoNext: $canGoNext, canGoPrevious: $canGoPrevious}';
  }
}

// ============================================================================
// NOTIFIER POUR LA NAVIGATION
// ============================================================================

/// Notifier pour gérer la navigation du tutoriel
class TutorialNavigationNotifier extends Notifier<TutorialNavigationState> {
  @override
  TutorialNavigationState build() {
    return TutorialNavigationState.initial();
  }

  /// Navigue vers une page spécifique
  void goToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= state.totalPages) {
      debugPrint('TutorialNavigation: Index de page invalide: $pageIndex');
      return;
    }

    final newState =
        state.copyWith(currentPage: pageIndex)._calculateNavigationState();
    state = newState;

    // Feedback haptique supprimé pour éviter les problèmes de tests

    debugPrint('TutorialNavigation: Navigation vers page $pageIndex');
  }

  /// Navigue vers la page suivante
  void nextPage() {
    if (state.canGoNext) {
      goToPage(state.currentPage + 1);
    } else {
      debugPrint('TutorialNavigation: Impossible d\'aller à la page suivante');
    }
  }

  /// Navigue vers la page précédente
  void previousPage() {
    if (state.canGoPrevious) {
      goToPage(state.currentPage - 1);
    } else {
      debugPrint(
          'TutorialNavigation: Impossible d\'aller à la page précédente');
    }
  }

  /// Remet à zéro la navigation
  void reset() {
    state = TutorialNavigationState.initial(totalPages: state.totalPages);
    debugPrint('TutorialNavigation: Navigation remise à zéro');
  }

  /// Marque le tutoriel comme terminé
  void complete() {
    final lastPageIndex = state.totalPages - 1;
    goToPage(lastPageIndex);
    debugPrint('TutorialNavigation: Tutoriel terminé');
  }

  /// Configure le nombre total de pages
  void setTotalPages(int totalPages) {
    if (totalPages <= 0) {
      debugPrint('TutorialNavigation: Nombre de pages invalide: $totalPages');
      return;
    }

    // Ajuster la page actuelle si nécessaire
    final adjustedCurrentPage =
        state.currentPage >= totalPages ? totalPages - 1 : state.currentPage;

    state = state
        .copyWith(
          totalPages: totalPages,
          currentPage: adjustedCurrentPage,
        )
        ._calculateNavigationState();

    debugPrint(
        'TutorialNavigation: Nombre total de pages défini à $totalPages');
  }

  /// Saute à la dernière page
  void skipToEnd() {
    goToPage(state.totalPages - 1);
    debugPrint('TutorialNavigation: Saut vers la fin du tutoriel');
  }

  /// Retourne au début
  void goToStart() {
    goToPage(0);
    debugPrint('TutorialNavigation: Retour au début du tutoriel');
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider principal pour la navigation du tutoriel
final tutorialNavigationProvider =
    NotifierProvider<TutorialNavigationNotifier, TutorialNavigationState>(
  TutorialNavigationNotifier.new,
);

/// Provider pour la page actuelle
final currentTutorialPageProvider = Provider<int>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.currentPage;
});

/// Provider pour le pourcentage de progression
final tutorialProgressProvider = Provider<double>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.progressPercentage;
});

/// Provider pour vérifier si on peut aller à la page suivante
final canGoNextProvider = Provider<bool>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.canGoNext;
});

/// Provider pour vérifier si on peut aller à la page précédente
final canGoPreviousProvider = Provider<bool>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.canGoPrevious;
});

/// Provider pour vérifier si le tutoriel est terminé
final isTutorialCompletedProvider = Provider<bool>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.isCompleted;
});

/// Provider pour le titre de la page actuelle
final currentPageTitleProvider = Provider<String>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.currentPageTitle;
});

/// Provider pour l'index de la page suivante
final nextPageIndexProvider = Provider<int?>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.nextPageIndex;
});

/// Provider pour l'index de la page précédente
final previousPageIndexProvider = Provider<int?>((ref) {
  final navigationState = ref.watch(tutorialNavigationProvider);
  return navigationState.previousPageIndex;
});

// ============================================================================
// PROVIDERS D'ACTIONS
// ============================================================================

/// Provider pour les actions de navigation
final tutorialActionsProvider = Provider<TutorialActions>((ref) {
  final notifier = ref.read(tutorialNavigationProvider.notifier);
  return TutorialActions(notifier);
});

/// Classe d'actions pour la navigation
class TutorialActions {
  const TutorialActions(this._notifier);

  final TutorialNavigationNotifier _notifier;

  /// Navigue vers la page suivante
  void nextPage() => _notifier.nextPage();

  /// Navigue vers la page précédente
  void previousPage() => _notifier.previousPage();

  /// Navigue vers une page spécifique
  void goToPage(int pageIndex) => _notifier.goToPage(pageIndex);

  /// Remet à zéro la navigation
  void reset() => _notifier.reset();

  /// Marque le tutoriel comme terminé
  void complete() => _notifier.complete();

  /// Saute à la fin
  void skipToEnd() => _notifier.skipToEnd();

  /// Retourne au début
  void goToStart() => _notifier.goToStart();
}

// ============================================================================
// EXTENSIONS UTILITAIRES
// ============================================================================

/// Extension pour faciliter l'utilisation de la navigation
extension TutorialNavigationExtension on WidgetRef {
  /// Accès rapide à l'état de navigation
  TutorialNavigationState get tutorialNavigation =>
      watch(tutorialNavigationProvider);

  /// Accès rapide à la page actuelle
  int get currentTutorialPage => watch(currentTutorialPageProvider);

  /// Accès rapide au pourcentage de progression
  double get tutorialProgress => watch(tutorialProgressProvider);

  /// Accès rapide aux actions
  TutorialActions get tutorialActions => read(tutorialActionsProvider);

  /// Vérifie si on peut aller à la page suivante
  bool get canGoNext => watch(canGoNextProvider);

  /// Vérifie si on peut aller à la page précédente
  bool get canGoPrevious => watch(canGoPreviousProvider);

  /// Vérifie si le tutoriel est terminé
  bool get isTutorialCompleted => watch(isTutorialCompletedProvider);

  /// Obtient le titre de la page actuelle
  String get currentPageTitle => watch(currentPageTitleProvider);
}
