/// 📱 Constantes Responsive - SecureChat
/// 
/// Centralise toutes les constantes de responsive design pour éviter les magic numbers
/// et assurer une cohérence visuelle sur tous les écrans.

import 'package:flutter/material.dart';

/// Constantes pour le responsive design
class ResponsiveConstants {
  ResponsiveConstants._();

  // ========== BREAKPOINTS ==========
  
  /// Largeur minimale mobile (iPhone SE)
  static const double minMobileWidth = 320.0;
  
  /// Breakpoint mobile
  static const double mobileBreakpoint = 600.0;
  
  /// Breakpoint tablette
  static const double tabletBreakpoint = 900.0;
  
  /// Breakpoint desktop
  static const double desktopBreakpoint = 1200.0;
  
  /// Hauteur compacte (iPhone SE, petits écrans)
  static const double compactHeight = 700.0;
  
  /// Hauteur très compacte (iPhone SE 1ère génération)
  static const double veryCompactHeight = 600.0;

  // ========== ESPACEMENTS ADAPTATIFS ==========
  
  /// Espacement très petit
  static const double spacingXS = 4.0;
  
  /// Espacement petit
  static const double spacingS = 8.0;
  
  /// Espacement moyen
  static const double spacingM = 16.0;
  
  /// Espacement large
  static const double spacingL = 24.0;
  
  /// Espacement très large
  static const double spacingXL = 32.0;
  
  /// Espacement extra large
  static const double spacingXXL = 48.0;

  // ========== TAILLES DE COMPOSANTS ==========
  
  /// Hauteur de bouton standard
  static const double buttonHeight = 56.0;
  
  /// Hauteur de bouton compact
  static const double buttonHeightCompact = 48.0;
  
  /// Hauteur de bouton petit
  static const double buttonHeightSmall = 40.0;
  
  /// Taille d'icône standard
  static const double iconSize = 24.0;
  
  /// Taille d'icône petite
  static const double iconSizeSmall = 20.0;
  
  /// Taille d'icône grande
  static const double iconSizeLarge = 32.0;
  
  /// Taille minimale de cible tactile (accessibilité)
  static const double minTouchTarget = 44.0;

  // ========== RATIOS RESPONSIVE ==========
  
  /// Ratio de largeur pour conteneurs sur mobile
  static const double mobileWidthRatio = 0.9;
  
  /// Ratio de largeur pour conteneurs sur tablette
  static const double tabletWidthRatio = 0.7;
  
  /// Ratio de largeur pour conteneurs sur desktop
  static const double desktopWidthRatio = 0.5;
  
  /// Ratio de hauteur pour modales
  static const double modalHeightRatio = 0.8;
  
  /// Ratio de hauteur pour cartes
  static const double cardHeightRatio = 0.6;

  // ========== BORDURES ET RAYONS ==========
  
  /// Rayon de bordure petit
  static const double borderRadiusS = 8.0;
  
  /// Rayon de bordure moyen
  static const double borderRadiusM = 12.0;
  
  /// Rayon de bordure large
  static const double borderRadiusL = 16.0;
  
  /// Rayon de bordure très large
  static const double borderRadiusXL = 20.0;
  
  /// Rayon de bordure extra large
  static const double borderRadiusXXL = 24.0;

  // ========== GLASSMORPHISM ==========
  
  /// Opacité glassmorphism faible
  static const double glassOpacityLow = 0.08;
  
  /// Opacité glassmorphism moyenne
  static const double glassOpacityMedium = 0.12;
  
  /// Opacité glassmorphism haute
  static const double glassOpacityHigh = 0.16;
  
  /// Intensité de flou faible
  static const double blurIntensityLow = 8.0;
  
  /// Intensité de flou moyenne
  static const double blurIntensityMedium = 12.0;
  
  /// Intensité de flou haute
  static const double blurIntensityHigh = 20.0;

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient la largeur responsive basée sur le contexte
  static double getResponsiveWidth(BuildContext context, double ratio) {
    return MediaQuery.sizeOf(context).width * ratio;
  }
  
  /// Obtient la hauteur responsive basée sur le contexte
  static double getResponsiveHeight(BuildContext context, double ratio) {
    return MediaQuery.sizeOf(context).height * ratio;
  }
  
  /// Obtient l'espacement adaptatif basé sur la taille d'écran
  static double getAdaptiveSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return spacingM;
    if (width < tabletBreakpoint) return spacingL;
    return spacingXL;
  }
  
  /// Obtient le padding adaptatif basé sur la taille d'écran
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    
    if (height < veryCompactHeight) {
      return const EdgeInsets.all(spacingS);
    } else if (height < compactHeight) {
      return const EdgeInsets.all(spacingM);
    } else if (width < mobileBreakpoint) {
      return const EdgeInsets.all(spacingM);
    } else if (width < tabletBreakpoint) {
      return const EdgeInsets.all(spacingL);
    } else {
      return const EdgeInsets.all(spacingXL);
    }
  }
  
  /// Obtient la taille de police adaptative
  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return baseSize;
    if (width < tabletBreakpoint) return baseSize * 1.1;
    return baseSize * 1.2;
  }
  
  /// Vérifie si l'écran est compact en hauteur
  static bool isCompactHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < compactHeight;
  }
  
  /// Vérifie si l'écran est très compact en hauteur
  static bool isVeryCompactHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < veryCompactHeight;
  }
  
  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }
  
  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }
}

/// Extension pour faciliter l'utilisation des constantes responsive
extension ResponsiveExtension on BuildContext {
  /// Obtient la largeur responsive
  double responsiveWidth(double ratio) => 
      ResponsiveConstants.getResponsiveWidth(this, ratio);
  
  /// Obtient la hauteur responsive
  double responsiveHeight(double ratio) => 
      ResponsiveConstants.getResponsiveHeight(this, ratio);
  
  /// Obtient l'espacement adaptatif
  double get adaptiveSpacing => ResponsiveConstants.getAdaptiveSpacing(this);
  
  /// Obtient le padding adaptatif
  EdgeInsets get adaptivePadding => ResponsiveConstants.getAdaptivePadding(this);
  
  /// Vérifie si l'écran est compact
  bool get isCompactHeight => ResponsiveConstants.isCompactHeight(this);
  
  /// Vérifie si l'écran est très compact
  bool get isVeryCompactHeight => ResponsiveConstants.isVeryCompactHeight(this);
  
  /// Vérifie si l'écran est mobile
  bool get isMobile => ResponsiveConstants.isMobile(this);
  
  /// Vérifie si l'écran est tablette
  bool get isTablet => ResponsiveConstants.isTablet(this);
  
  /// Vérifie si l'écran est desktop
  bool get isDesktop => ResponsiveConstants.isDesktop(this);
}
