/// 📱 ResponsiveBuilder - Design System Responsive Cohérent
///
/// Basé sur les meilleures pratiques Flutter Context7 + Exa Research :
/// - MediaQuery.sizeOf() pour performance optimale
/// - LayoutBuilder pour contraintes dynamiques
/// - Design tokens centralisés (AppBreakpoints, AppSpacing, AppSizes)
/// - Approche mobile-first avec scaling fluide
/// - Intégration complète avec le design system SecureChat

import 'package:flutter/material.dart';
import '../core/theme/app_breakpoints.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';

// ============================================================================
// RESPONSIVE BUILDER WIDGET AMÉLIORÉ
// ============================================================================

// ============================================================================
// ENHANCED RESPONSIVE INFO CLASS
// ============================================================================

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget Function(BuildContext context, ResponsiveInfo info) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Utiliser MediaQuery.sizeOf pour performance optimale (Exa best practice)
        final screenSize = MediaQuery.sizeOf(context);
        final orientation = MediaQuery.orientationOf(context);

        // Créer ResponsiveInfo avec toutes les données nécessaires
        final info = ResponsiveInfo(
          screenSize: screenSize,
          constraints: constraints,
          orientation: orientation,
        );

        return builder(context, info);
      },
    );
  }
}

class ResponsiveInfo {
  const ResponsiveInfo({
    required this.screenSize,
    required this.constraints,
    required this.orientation,
  });

  final Size screenSize;
  final BoxConstraints constraints;
  final Orientation orientation;

  // ============================================================================
  // DEVICE TYPE DETECTION (Intégré avec AppBreakpoints)
  // ============================================================================

  DeviceType get deviceType => AppBreakpoints.getDeviceType(_buildContext);
  ScreenSize get screenSize => AppBreakpoints.getScreenSize(_buildContext);

  // Fallback BuildContext pour les méthodes statiques
  BuildContext get _buildContext => throw UnimplementedError(
    'ResponsiveInfo doit être utilisé dans un contexte avec BuildContext'
  );

  // Méthodes de détection basées sur les design tokens
  bool get isVerySmall => screenSize.width < AppBreakpoints.verySmall;
  bool get isMobile => screenSize.width < AppBreakpoints.mobile;
  bool get isTablet => screenSize.width >= AppBreakpoints.mobile &&
                      screenSize.width < AppBreakpoints.desktop;
  bool get isDesktop => screenSize.width >= AppBreakpoints.desktop;
  bool get isLargeDesktop => screenSize.width >= AppBreakpoints.largeDesktop;

  // Détection de hauteur
  bool get isVeryCompactHeight => screenSize.height < AppBreakpoints.veryCompactHeight;
  bool get isCompactHeight => screenSize.height < AppBreakpoints.compactHeight;
  bool get isNormalHeight => screenSize.height >= AppBreakpoints.normalHeight;

  // Orientation
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // ============================================================================
  // ADAPTIVE DIMENSIONS (Intégré avec Design Tokens)
  // ============================================================================

  /// Padding adaptatif basé sur les design tokens
  EdgeInsets get adaptivePadding {
    if (isVerySmall) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs
      );
    } else if (isMobile) {
      return const EdgeInsets.all(AppSpacing.md);
    } else if (isTablet) {
      return const EdgeInsets.all(AppSpacing.lg);
    } else {
      return const EdgeInsets.all(AppSpacing.xl);
    }
  }

  /// Espacement vertical adaptatif
  double get verticalSpacing {
    if (isVerySmall) return AppSpacing.xs;
    if (isMobile) return AppSpacing.sm;
    if (isTablet) return AppSpacing.md;
    return AppSpacing.lg;
  }

  /// Espacement horizontal adaptatif
  double get horizontalSpacing {
    if (isVerySmall) return AppSpacing.sm;
    if (isMobile) return AppSpacing.md;
    if (isTablet) return AppSpacing.lg;
    return AppSpacing.xl;
  }

  /// Hauteur de bouton adaptative basée sur AppSizes
  double get buttonHeight {
    if (isVerySmall) return AppSizes.buttonHeightSm;
    if (isMobile) return AppSizes.buttonHeightMd;
    if (isTablet) return AppSizes.buttonHeightLg;
    return AppSizes.buttonHeightXl;
  }

  /// Taille d'icône adaptative
  double get iconSize {
    if (isVerySmall) return AppSizes.iconSm;
    if (isMobile) return AppSizes.iconMd;
    if (isTablet) return AppSizes.iconLg;
    return AppSizes.iconXl;
  }

  /// Largeur maximale du contenu
  double get maxContentWidth {
    if (isMobile) return screenSize.width * 0.9;
    if (isTablet) return AppSizes.cardMaxWidth;
    return AppSizes.maxContentWidth;
  }

  /// Rayon de bordure adaptatif
  double get borderRadius {
    if (isVerySmall) return AppSizes.radiusSm;
    if (isMobile) return AppSizes.radiusMd;
    if (isTablet) return AppSizes.radiusLg;
    return AppSizes.radiusXl;
  }

  /// Élévation adaptative
  double get elevation {
    if (isVerySmall) return AppSizes.elevationSm;
    if (isMobile) return AppSizes.elevationMd;
    if (isTablet) return AppSizes.elevationLg;
    return AppSizes.elevationXl;
  }

  // ============================================================================
  // LAYOUT HELPERS
  // ============================================================================

  /// Détermine si on doit utiliser un layout compact
  bool get shouldUseCompactLayout => isVeryCompactHeight || isVerySmall;

  /// Détermine si on doit désactiver les animations coûteuses
  bool get shouldDisableHeavyAnimations => isVerySmall || isVeryCompactHeight;

  /// Détermine si on doit réduire les effets visuels
  bool get shouldReduceVisualEffects => isVerySmall || isVeryCompactHeight;

  /// Calcule la hauteur disponible en soustrayant les éléments fixes
  double getAvailableHeight({
    double headerHeight = 0,
    double footerHeight = 0,
    double keyboardHeight = 0,
  }) {
    return screenSize.height -
        headerHeight -
        footerHeight -
        keyboardHeight -
        adaptivePadding.vertical;
  }

  /// Calcule la largeur disponible
  double get availableWidth {
    return screenSize.width - adaptivePadding.horizontal;
  }

  /// Obtient le nombre de colonnes pour une grille responsive
  int get gridColumns {
    if (isVerySmall) return 1;
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }
}

// ============================================================================
// RESPONSIVE EXTENSIONS AMÉLIORÉES
// ============================================================================

extension ResponsiveExtensions on BuildContext {
  /// Obtient les informations responsive
  ResponsiveInfo get responsive {
    final screenSize = MediaQuery.sizeOf(this);
    final orientation = MediaQuery.orientationOf(this);

    return ResponsiveInfo(
      screenSize: screenSize,
      constraints: const BoxConstraints(), // Fallback
      orientation: orientation,
    );
  }

  /// Raccourcis pour les breakpoints
  bool get isMobile => AppBreakpoints.isMobile(this);
  bool get isTablet => AppBreakpoints.isTablet(this);
  bool get isDesktop => AppBreakpoints.isDesktop(this);
  bool get isVerySmall => MediaQuery.sizeOf(this).width < AppBreakpoints.verySmall;

  /// Raccourcis pour les espacements responsive
  EdgeInsets get responsivePadding => AppSpacing.getResponsiveSymmetric(this);
  EdgeInsets get responsiveHorizontal => AppSpacing.getResponsiveHorizontal(this);
  EdgeInsets get responsiveVertical => AppSpacing.getResponsiveVertical(this);

  /// Raccourcis pour les valeurs responsive
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) => AppBreakpoints.getResponsiveValue<T>(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
}
