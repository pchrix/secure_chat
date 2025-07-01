/// 🎨 AppTheme - Thème principal de l'application SecureChat
/// 
/// Définit les couleurs, typographies et styles pour un design glassmorphism moderne.
/// Optimisé pour l'accessibilité et la cohérence visuelle.

import 'package:flutter/material.dart';

/// Thème principal de l'application
class AppTheme {
  // Empêche l'instanciation
  AppTheme._();

  // ========== COULEURS ==========
  
  /// Couleur primaire - Bleu moderne
  static const Color primaryColor = Color(0xFF2196F3);
  
  /// Couleur secondaire - Violet élégant
  static const Color secondaryColor = Color(0xFF9C27B0);
  
  /// Couleur d'accent - Cyan vibrant
  static const Color accentColor = Color(0xFF00BCD4);
  
  /// Couleur de succès
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Couleur d'erreur
  static const Color errorColor = Color(0xFFF44336);
  
  /// Couleur d'avertissement
  static const Color warningColor = Color(0xFFFF9800);
  
  /// Couleur d'information
  static const Color infoColor = Color(0xFF2196F3);
  
  /// Couleur de surface
  static const Color surfaceColor = Color(0xFFFAFAFA);
  
  /// Couleur d'arrière-plan
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  /// Couleur désactivée
  static const Color disabledColor = Color(0xFF9E9E9E);
  
  /// Couleur de divider
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // ========== COULEURS DE TEXTE ==========
  
  /// Couleur de texte primaire
  static const Color textPrimaryColor = Color(0xFF212121);
  
  /// Couleur de texte secondaire
  static const Color textSecondaryColor = Color(0xFF757575);
  
  /// Couleur de texte sur fond sombre
  static const Color textOnDarkColor = Color(0xFFFFFFFF);
  
  /// Couleur de texte désactivé
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  
  // ========== TYPOGRAPHIE ==========
  
  /// Style de titre principal
  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppTypography.fontSize4xl,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Style de titre moyen
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  /// Style de titre petit
  static const TextStyle headlineSmall = TextStyle(
    fontSize: AppTypography.fontSize3xl,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );
  
  /// Style de titre de section
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );
  
  /// Style de titre moyen
  static const TextStyle titleMedium = TextStyle(
    fontSize: AppTypography.fontSizeLg,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  /// Style de titre petit
  static const TextStyle titleSmall = TextStyle(
    fontSize: AppTypography.fontSizeMd,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Style de corps de texte large
  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppTypography.fontSizeLg,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  /// Style de corps de texte moyen
  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppTypography.fontSizeMd,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  /// Style de corps de texte petit
  static const TextStyle bodySmall = TextStyle(
    fontSize: AppTypography.fontSizeSm,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  /// Style de label large
  static const TextStyle labelLarge = TextStyle(
    fontSize: AppTypography.fontSizeMd,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Style de label moyen
  static const TextStyle labelMedium = TextStyle(
    fontSize: AppTypography.fontSizeSm,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  /// Style de label petit
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  // ========== ESPACEMENTS ==========
  
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
  
  // ========== RAYONS DE BORDURE ==========
  
  /// Rayon petit
  static const double radiusS = 8.0;
  
  /// Rayon moyen
  static const double radiusM = 12.0;
  
  /// Rayon large
  static const double radiusL = 16.0;
  
  /// Rayon très large
  static const double radiusXL = 20.0;
  
  /// Rayon circulaire
  static const double radiusCircular = 50.0;
  
  // ========== ÉLÉVATIONS ==========
  
  /// Élévation faible
  static const double elevationLow = 2.0;
  
  /// Élévation moyenne
  static const double elevationMedium = 4.0;
  
  /// Élévation haute
  static const double elevationHigh = 8.0;
  
  /// Élévation très haute
  static const double elevationVeryHigh = 16.0;
  
  // ========== OPACITÉS ==========
  
  /// Opacité faible
  static const double opacityLow = 0.1;
  
  /// Opacité moyenne
  static const double opacityMedium = 0.15;
  
  /// Opacité haute
  static const double opacityHigh = 0.2;
  
  /// Opacité pour les overlays
  static const double opacityOverlay = 0.3;
  
  // ========== DURÉES D'ANIMATION ==========
  
  /// Animation rapide
  static const Duration animationFast = Duration(milliseconds: 150);
  
  /// Animation normale
  static const Duration animationNormal = Duration(milliseconds: 300);
  
  /// Animation lente
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // ========== BREAKPOINTS RESPONSIVE ==========
  
  /// Breakpoint mobile
  static const double breakpointMobile = 600;
  
  /// Breakpoint tablette
  static const double breakpointTablet = 900;
  
  /// Breakpoint desktop
  static const double breakpointDesktop = 1200;
  
  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient la couleur de texte appropriée pour un arrière-plan
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimaryColor : textOnDarkColor;
  }
  
  /// Obtient une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }
  
  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }
  
  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
  
  /// Obtient l'espacement responsive
  static double getResponsiveSpacing(BuildContext context) {
    if (isMobile(context)) return spacingM;
    if (isTablet(context)) return spacingL;
    return spacingXL;
  }
  
  /// Obtient la taille de police responsive
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
}
