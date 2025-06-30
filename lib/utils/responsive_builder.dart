/// 📱 ResponsiveBuilder - Optimisé pour iPhone SE et petits écrans
///
/// Basé sur les meilleures pratiques Flutter Context7 + Exa Research :
/// - MediaQuery.sizeOf() pour performance optimale
/// - LayoutBuilder pour contraintes dynamiques
/// - Breakpoints ultra-agressifs pour iPhone SE (320px)
/// - Approche mobile-first avec scaling fluide

import 'package:flutter/material.dart';

// ============================================================================
// BREAKPOINTS ULTRA-AGRESSIFS POUR IPHONE SE
// ============================================================================

/// Breakpoints optimisés basés sur recherche Exa + Context7
class ResponsiveBreakpoints {
  // iPhone SE 1ère génération : 320x568
  static const double iphoneSE1 = 320.0;

  // iPhone SE 2ème génération : 375x667
  static const double iphoneSE2 = 375.0;

  // iPhone standard : 390x844
  static const double iphoneStandard = 390.0;

  // Tablette : 768px+
  static const double tablet = 768.0;

  // Desktop : 1024px+
  static const double desktop = 1024.0;

  // Hauteurs critiques - Ultra-agressives pour iPhone SE
  static const double veryCompactHeight = 700.0; // iPhone SE 1&2 (568, 667)
  static const double compactHeight = 800.0; // iPhone standard
  static const double normalHeight = 900.0; // Écrans normaux
}

// ============================================================================
// DEVICE TYPE DETECTION
// ============================================================================

enum DeviceType {
  iphoneSE1, // 320px - Ultra compact
  iphoneSE2, // 375px - Très compact
  iphoneStandard, // 390px+ - Compact
  tablet, // 768px+ - Large
  desktop, // 1024px+ - Extra large
}

enum ScreenHeight {
  veryCompact, // < 600px - iPhone SE
  compact, // < 700px - iPhone standard
  normal, // >= 700px - Écrans normaux
}

// ============================================================================
// RESPONSIVE BUILDER WIDGET
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

// ============================================================================
// RESPONSIVE INFO CLASS
// ============================================================================

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
  // DEVICE TYPE DETECTION
  // ============================================================================

  DeviceType get deviceType {
    final width = screenSize.width;

    if (width <= ResponsiveBreakpoints.iphoneSE1) {
      return DeviceType.iphoneSE1;
    } else if (width <= ResponsiveBreakpoints.iphoneSE2) {
      return DeviceType.iphoneSE2;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.iphoneStandard;
    } else if (width < ResponsiveBreakpoints.desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  ScreenHeight get screenHeight {
    final height = screenSize.height;

    if (height < ResponsiveBreakpoints.veryCompactHeight) {
      return ScreenHeight.veryCompact;
    } else if (height < ResponsiveBreakpoints.compactHeight) {
      return ScreenHeight.compact;
    } else {
      return ScreenHeight.normal;
    }
  }

  // ============================================================================
  // CONVENIENCE GETTERS
  // ============================================================================

  bool get isIPhoneSE1 => deviceType == DeviceType.iphoneSE1;
  bool get isIPhoneSE2 => deviceType == DeviceType.iphoneSE2;
  bool get isIPhoneSE => isIPhoneSE1 || isIPhoneSE2;
  bool get isIPhoneStandard => deviceType == DeviceType.iphoneStandard;
  bool get isMobile => deviceType.index <= DeviceType.iphoneStandard.index;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  bool get isVeryCompact => screenHeight == ScreenHeight.veryCompact;
  bool get isCompact => screenHeight == ScreenHeight.compact;
  bool get isNormal => screenHeight == ScreenHeight.normal;

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // ============================================================================
  // ADAPTIVE DIMENSIONS
  // ============================================================================

  /// Padding adaptatif ultra-optimisé pour iPhone SE
  EdgeInsets get adaptivePadding {
    if (isIPhoneSE1) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else if (isIPhoneSE2) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    } else if (isVeryCompact) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isCompact) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Espacement vertical adaptatif
  double get verticalSpacing {
    if (isIPhoneSE1) return 4.0;
    if (isIPhoneSE2) return 6.0;
    if (isVeryCompact) return 8.0;
    if (isCompact) return 12.0;
    return 16.0;
  }

  /// Espacement horizontal adaptatif
  double get horizontalSpacing {
    if (isIPhoneSE1) return 6.0;
    if (isIPhoneSE2) return 8.0;
    if (isVeryCompact) return 12.0;
    if (isCompact) return 16.0;
    return 20.0;
  }

  /// Taille de police adaptative
  double getAdaptiveFontSize(double baseSize) {
    if (isIPhoneSE1) return baseSize * 0.75;
    if (isIPhoneSE2) return baseSize * 0.85;
    if (isVeryCompact) return baseSize * 0.9;
    if (isCompact) return baseSize * 0.95;
    return baseSize;
  }

  /// Hauteur de bouton adaptative
  double get buttonHeight {
    if (isIPhoneSE1) return 36.0;
    if (isIPhoneSE2) return 40.0;
    if (isVeryCompact) return 44.0;
    if (isCompact) return 48.0;
    return 52.0;
  }

  /// Largeur maximale du contenu
  double get maxContentWidth {
    if (isMobile) return screenSize.width * 0.9;
    if (isTablet) return 600.0;
    return 800.0;
  }

  /// Hauteur du clavier numérique adaptative
  double get keypadHeight {
    if (isIPhoneSE1) return 140.0; // Ultra-compact
    if (isIPhoneSE2) return 160.0; // Très compact
    if (isVeryCompact) return 180.0; // Compact
    if (isCompact) return 220.0; // Standard
    return 260.0; // Large
  }

  /// Espacement du clavier adaptatif
  double get keypadSpacing {
    if (isIPhoneSE1) return 4.0;
    if (isIPhoneSE2) return 6.0;
    if (isVeryCompact) return 8.0;
    if (isCompact) return 12.0;
    return 16.0;
  }

  /// Taille des touches du clavier
  double get keySize {
    if (isIPhoneSE1) return 28.0;
    if (isIPhoneSE2) return 32.0;
    if (isVeryCompact) return 36.0;
    if (isCompact) return 42.0;
    return 48.0;
  }

  // ============================================================================
  // LAYOUT HELPERS
  // ============================================================================

  /// Détermine si on doit utiliser un layout compact
  bool get shouldUseCompactLayout => isVeryCompact || isIPhoneSE;

  /// Détermine si on doit désactiver les animations coûteuses
  bool get shouldDisableHeavyAnimations => isIPhoneSE1 || isVeryCompact;

  /// Détermine si on doit réduire les effets visuels
  bool get shouldReduceVisualEffects => isIPhoneSE || isVeryCompact;

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
}

// ============================================================================
// RESPONSIVE EXTENSIONS
// ============================================================================

extension ResponsiveExtensions on BuildContext {
  ResponsiveInfo get responsive {
    final screenSize = MediaQuery.sizeOf(this);
    final orientation = MediaQuery.orientationOf(this);

    return ResponsiveInfo(
      screenSize: screenSize,
      constraints: const BoxConstraints(), // Fallback
      orientation: orientation,
    );
  }
}
