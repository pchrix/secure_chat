import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Utilitaires pour le design responsive et l'accessibilité
class ResponsiveUtils {
  // Breakpoints pour les différentes tailles d'écran (largeur)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Breakpoints de hauteur ultra-agressifs (optimisés iPhone SE)
  static const double veryCompactHeightBreakpoint =
      700.0; // iPhone SE et plus petits
  static const double compactHeightBreakpoint = 800.0; // iPhone standard
  static const double normalHeightBreakpoint = 900.0; // Écrans normaux

  // Tailles minimales pour l'accessibilité
  static const double minTouchTargetSize = 44.0; // iOS guideline
  static const double minAndroidTouchTargetSize = 48.0; // Android guideline

  /// Obtenir le type d'appareil basé sur la largeur
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Vérifier si l'appareil est mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Vérifier si l'appareil est tablette
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Vérifier si l'appareil est desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Vérifier si l'écran est très compact en hauteur (iPhone SE)
  static bool isVeryCompact(BuildContext context) {
    return MediaQuery.of(context).size.height < veryCompactHeightBreakpoint;
  }

  /// Vérifier si l'écran est compact en hauteur (iPhone standard)
  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.height < compactHeightBreakpoint;
  }

  /// Vérifier si l'écran est normal ou grand en hauteur
  static bool isNormal(BuildContext context) {
    return MediaQuery.of(context).size.height >= compactHeightBreakpoint;
  }

  /// Obtenir la largeur responsive basée sur le type d'appareil
  static double getResponsiveWidth(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? MediaQuery.of(context).size.width * 0.9;
      case DeviceType.tablet:
        return tablet ?? MediaQuery.of(context).size.width * 0.7;
      case DeviceType.desktop:
        return desktop ?? MediaQuery.of(context).size.width * 0.5;
    }
  }

  /// Obtenir la hauteur responsive basée sur le type d'appareil
  static double getResponsiveHeight(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? MediaQuery.of(context).size.height * 0.8;
      case DeviceType.tablet:
        return tablet ?? MediaQuery.of(context).size.height * 0.7;
      case DeviceType.desktop:
        return desktop ?? MediaQuery.of(context).size.height * 0.6;
    }
  }

  /// Obtenir la taille de police responsive
  static double getResponsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 14.0;
      case DeviceType.tablet:
        return tablet ?? 16.0;
      case DeviceType.desktop:
        return desktop ?? 18.0;
    }
  }

  /// Obtenir le padding responsive
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return tablet ?? const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return desktop ?? const EdgeInsets.all(32.0);
    }
  }

  /// Obtenir le padding ultra-adaptatif basé sur la hauteur d'écran
  static EdgeInsets getUltraAdaptivePadding(BuildContext context) {
    if (isVeryCompact(context)) {
      return const EdgeInsets.all(12.0); // Ultra-compact pour iPhone SE
    } else if (isCompact(context)) {
      return const EdgeInsets.all(16.0); // Compact pour iPhone standard
    } else {
      return const EdgeInsets.all(24.0); // Normal pour grands écrans
    }
  }

  /// Obtenir l'espacement vertical ultra-adaptatif
  static double getUltraAdaptiveSpacing(
    BuildContext context, {
    double? veryCompact,
    double? compact,
    double? normal,
  }) {
    if (isVeryCompact(context)) {
      return veryCompact ?? 8.0; // Ultra-réduit pour iPhone SE
    } else if (isCompact(context)) {
      return compact ?? 16.0; // Réduit pour iPhone standard
    } else {
      return normal ?? 24.0; // Normal pour grands écrans
    }
  }

  /// Obtenir la hauteur de clavier ultra-adaptative
  static double getKeyboardHeight(BuildContext context) {
    if (isVeryCompact(context)) {
      return 160.0; // Ultra-compact pour iPhone SE
    } else if (isCompact(context)) {
      return 200.0; // Compact pour iPhone standard
    } else {
      return 240.0; // Normal pour grands écrans
    }
  }

  // ==================== OPTIMISATIONS GLASSMORPHISM ====================

  /// Obtenir l'intensité de flou optimisée pour la performance
  static double getOptimizedBlurIntensity(
      BuildContext context, double baseBlur) {
    if (isVeryCompact(context)) {
      return baseBlur * 0.5; // Réduction drastique pour iPhone SE (performance)
    } else if (isCompact(context)) {
      return baseBlur * 0.7; // Réduction modérée pour iPhone standard
    } else if (isMobile(context)) {
      return baseBlur * 0.8; // Légère réduction pour mobile
    } else {
      return baseBlur; // Plein effet sur tablette/desktop
    }
  }

  /// Obtenir l'opacité optimisée pour la lisibilité
  static double getOptimizedOpacity(BuildContext context, double baseOpacity) {
    if (isVeryCompact(context)) {
      return baseOpacity * 1.2; // Plus opaque pour compenser le flou réduit
    } else if (isCompact(context)) {
      return baseOpacity * 1.1; // Légèrement plus opaque
    } else {
      return baseOpacity; // Opacité normale
    }
  }

  /// Déterminer si les effets avancés doivent être désactivés
  static bool shouldDisableAdvancedEffects(BuildContext context) {
    return isVeryCompact(context); // Désactiver sur iPhone SE pour performance
  }

  /// Obtenir le nombre de couches d'ombre optimisé
  static int getOptimizedShadowLayers(BuildContext context) {
    if (isVeryCompact(context)) {
      return 1; // Une seule ombre sur iPhone SE
    } else if (isCompact(context)) {
      return 2; // Deux ombres sur iPhone standard
    } else {
      return 3; // Toutes les ombres sur grands écrans
    }
  }

  /// Obtenir la configuration glass optimisée
  static GlassConfig getOptimizedGlassConfig(
    BuildContext context, {
    double baseBlur = 20.0,
    double baseOpacity = 0.16,
    bool enableAdvancedEffects = true,
  }) {
    return GlassConfig(
      blurIntensity: getOptimizedBlurIntensity(context, baseBlur),
      opacity: getOptimizedOpacity(context, baseOpacity),
      enableAdvancedEffects:
          enableAdvancedEffects && !shouldDisableAdvancedEffects(context),
      enablePerformanceMode: true,
      shadowLayers: getOptimizedShadowLayers(context),
    );
  }

  /// Obtenir le nombre de colonnes pour une grille responsive
  static int getResponsiveColumns(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? 1;
      case DeviceType.tablet:
        return tablet ?? 2;
      case DeviceType.desktop:
        return desktop ?? 3;
    }
  }

  /// Vérifier si l'orientation est paysage
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Vérifier si l'orientation est portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Obtenir la taille minimale de cible tactile selon la plateforme
  static double getMinTouchTargetSize() {
    // Pour Flutter Web, utiliser la taille Android par défaut
    // Pour mobile, détecter via l'agent utilisateur ou utiliser une heuristique
    if (kIsWeb) {
      return minAndroidTouchTargetSize; // Standard web
    }

    // Pour les plateformes natives, utiliser la taille Android par défaut
    // (plus sûr que d'essayer de détecter iOS)
    return minAndroidTouchTargetSize;
  }

  /// Vérifier si une taille respecte les guidelines d'accessibilité
  static bool isAccessibleTouchTarget(double size) {
    return size >= getMinTouchTargetSize();
  }

  /// Obtenir la densité visuelle adaptée au type d'entrée
  static VisualDensity getAdaptiveVisualDensity(BuildContext context) {
    // Plus dense pour les appareils avec souris, moins dense pour le tactile
    final isTouch = isMobile(context) || isTablet(context);
    final densityValue = isTouch ? 0.0 : -1.0;

    return VisualDensity(
      horizontal: densityValue,
      vertical: densityValue,
    );
  }

  /// Obtenir les insets de sécurité
  static EdgeInsets getSafeAreaInsets(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Obtenir la hauteur disponible en excluant les insets de sécurité
  static double getAvailableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
  }

  /// Obtenir la largeur disponible en excluant les insets de sécurité
  static double getAvailableWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width -
        mediaQuery.padding.left -
        mediaQuery.padding.right;
  }

  /// Adapter la taille de texte selon les préférences d'accessibilité
  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(baseSize);
  }

  /// Limiter la mise à l'échelle du texte pour éviter les débordements
  static Widget withClampedTextScaling({
    required Widget child,
    double maxScaleFactor = 1.3,
  }) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxScaleFactor,
      child: child,
    );
  }

  /// Désactiver la mise à l'échelle du texte (pour les icônes)
  static Widget withNoTextScaling({required Widget child}) {
    return MediaQuery.withNoTextScaling(child: child);
  }

  /// Obtenir les contraintes adaptées pour un dialog
  static BoxConstraints getDialogConstraints(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return BoxConstraints(
          maxWidth: screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        );
      case DeviceType.tablet:
        return BoxConstraints(
          maxWidth: 500,
          maxHeight: screenSize.height * 0.7,
        );
      case DeviceType.desktop:
        return BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.6,
        );
    }
  }

  /// Obtenir la configuration de grille adaptée à l'orientation
  static GridConfiguration getOrientationAwareGrid(BuildContext context) {
    final isLandscapeMode = isLandscape(context);
    final deviceType = getDeviceType(context);

    int columns;
    double aspectRatio;

    if (deviceType == DeviceType.mobile) {
      columns = isLandscapeMode ? 3 : 2;
      aspectRatio = isLandscapeMode ? 1.2 : 1.0;
    } else if (deviceType == DeviceType.tablet) {
      columns = isLandscapeMode ? 4 : 3;
      aspectRatio = 1.1;
    } else {
      columns = isLandscapeMode ? 5 : 4;
      aspectRatio = 1.2;
    }

    return GridConfiguration(
      columns: columns,
      aspectRatio: aspectRatio,
    );
  }
}

/// Configuration de grille responsive
class GridConfiguration {
  final int columns;
  final double aspectRatio;

  const GridConfiguration({
    required this.columns,
    required this.aspectRatio,
  });
}

/// Types d'appareils
enum DeviceType {
  mobile,
  tablet,
  desktop,
}


/// Configuration optimisée pour les effets glassmorphism
class GlassConfig {
  final double blurIntensity;
  final double opacity;
  final bool enableAdvancedEffects;
  final bool enablePerformanceMode;
  final int shadowLayers;

  const GlassConfig({
    required this.blurIntensity,
    required this.opacity,
    required this.enableAdvancedEffects,
    required this.enablePerformanceMode,
    required this.shadowLayers,
  });
}

/// Widget helper pour les layouts responsives
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Widget pour les contraintes adaptatives
class AdaptiveConstraints extends StatelessWidget {
  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;

  const AdaptiveConstraints({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    double? maxWidth;
    switch (deviceType) {
      case DeviceType.mobile:
        maxWidth = mobileMaxWidth;
        break;
      case DeviceType.tablet:
        maxWidth = tabletMaxWidth;
        break;
      case DeviceType.desktop:
        maxWidth = desktopMaxWidth;
        break;
    }

    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      );
    }

    return child;
  }
}
