/// 🔄 Design System Migration Helper
/// 
/// Utilitaires pour migrer les hardcoded values vers les design tokens
/// Facilite la transition vers le nouveau design system cohérent
/// 
/// Usage:
/// ```dart
/// // Au lieu de:
/// padding: EdgeInsets.all(AppSpacing.md),
/// 
/// // Utiliser:
/// padding: DesignSystemMigration.getSpacing(16.0),
/// ```

import 'package:flutter/material.dart';
import 'app_spacing.dart';
import 'app_sizes.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_breakpoints.dart';

/// Helper pour migrer les valeurs hardcodées vers les design tokens
class DesignSystemMigration {
  // Empêche l'instanciation
  DesignSystemMigration._();

  // ========== MIGRATION DES ESPACEMENTS ==========
  
  /// Migre une valeur d'espacement hardcodée vers AppSpacing
  static double getSpacing(double hardcodedValue) {
    // Mapping des valeurs communes vers les design tokens
    switch (hardcodedValue) {
      case 4.0:
        return AppSpacing.xs;
      case 8.0:
        return AppSpacing.sm;
      case 12.0:
        return AppSpacing.sm + AppSpacing.xs;
      case 16.0:
        return AppSpacing.md;
      case 20.0:
        return AppSpacing.lg - AppSpacing.xs;
      case 24.0:
        return AppSpacing.lg;
      case 32.0:
        return AppSpacing.xl;
      case 48.0:
        return AppSpacing.xxl;
      case 64.0:
        return AppSpacing.xxxl;
      default:
        // Pour les valeurs non standard, retourner la plus proche
        if (hardcodedValue <= 6.0) return AppSpacing.xs;
        if (hardcodedValue <= 12.0) return AppSpacing.sm;
        if (hardcodedValue <= 20.0) return AppSpacing.md;
        if (hardcodedValue <= 28.0) return AppSpacing.lg;
        if (hardcodedValue <= 40.0) return AppSpacing.xl;
        if (hardcodedValue <= 56.0) return AppSpacing.xxl;
        return AppSpacing.xxxl;
    }
  }

  // ========== MIGRATION DES TAILLES ==========
  
  /// Migre une hauteur de bouton hardcodée vers AppSizes
  static double getButtonHeight(double hardcodedValue) {
    if (hardcodedValue <= 36.0) return AppSizes.buttonHeightXs;
    if (hardcodedValue <= 44.0) return AppSizes.buttonHeightSm;
    if (hardcodedValue <= 52.0) return AppSizes.buttonHeightMd;
    if (hardcodedValue <= 60.0) return AppSizes.buttonHeightLg;
    return AppSizes.buttonHeightXl;
  }
  
  /// Migre une taille d'icône hardcodée vers AppSizes
  static double getIconSize(double hardcodedValue) {
    if (hardcodedValue <= 18.0) return AppSizes.iconXs;
    if (hardcodedValue <= 22.0) return AppSizes.iconSm;
    if (hardcodedValue <= 28.0) return AppSizes.iconMd;
    if (hardcodedValue <= 36.0) return AppSizes.iconLg;
    if (hardcodedValue <= 44.0) return AppSizes.iconXl;
    return AppSizes.iconXxl;
  }
  
  /// Migre un rayon de bordure hardcodé vers AppSizes
  static double getBorderRadius(double hardcodedValue) {
    if (hardcodedValue <= 6.0) return AppSizes.radiusXs;
    if (hardcodedValue <= 10.0) return AppSizes.radiusSm;
    if (hardcodedValue <= 16.0) return AppSizes.radiusMd;
    if (hardcodedValue <= 20.0) return AppSizes.radiusLg;
    if (hardcodedValue <= 30.0) return AppSizes.radiusXl;
    return AppSizes.radiusCircular;
  }

  // ========== MIGRATION DES COULEURS ==========
  
  /// Migre GlassColors vers AppColors
  static Color migrateGlassColor(String glassColorName) {
    switch (glassColorName) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'accent':
        return AppColors.accent;
      case 'tertiary':
        return AppColors.tertiary;
      case 'danger':
      case 'error':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      case 'info':
        return AppColors.info;
      case 'surface':
        return AppColors.surface;
      case 'background':
        return AppColors.background;
      case 'onSurface':
        return AppColors.onSurface;
      case 'onBackground':
        return AppColors.onBackground;
      case 'glassWhite':
        return AppColors.glassWhite;
      case 'glassBorder':
        return AppColors.glassBorder;
      default:
        return AppColors.primary; // Fallback
    }
  }

  // ========== MIGRATION DES BREAKPOINTS ==========
  
  /// Migre les breakpoints hardcodés vers AppBreakpoints
  static double getBreakpoint(double hardcodedValue) {
    if (hardcodedValue <= 375.0) return AppBreakpoints.verySmall;
    if (hardcodedValue <= 480.0) return AppBreakpoints.mobile;
    if (hardcodedValue <= 768.0) return AppBreakpoints.tablet;
    if (hardcodedValue <= 1024.0) return AppBreakpoints.desktop;
    return AppBreakpoints.largeDesktop;
  }

  // ========== MIGRATION DES TYPOGRAPHIES ==========
  
  /// Migre une taille de police hardcodée vers AppTypography
  static double getFontSize(double hardcodedValue) {
    if (hardcodedValue <= 11.0) return AppTypography.fontSizeXs;
    if (hardcodedValue <= 13.0) return AppTypography.fontSizeSm;
    if (hardcodedValue <= 15.0) return AppTypography.fontSizeMd;
    if (hardcodedValue <= 17.0) return AppTypography.fontSizeLg;
    if (hardcodedValue <= 19.0) return AppTypography.fontSizeXl;
    if (hardcodedValue <= 22.0) return AppTypography.fontSize2xl;
    if (hardcodedValue <= 28.0) return AppTypography.fontSize3xl;
    if (hardcodedValue <= 36.0) return AppTypography.fontSize4xl;
    if (hardcodedValue <= 44.0) return AppTypography.fontSize5xl;
    return AppTypography.fontSize6xl;
  }

  // ========== UTILITAIRES DE MIGRATION ==========
  
  /// Convertit un EdgeInsets hardcodé vers les design tokens
  static EdgeInsets migrateEdgeInsets(EdgeInsets hardcodedInsets) {
    return EdgeInsets.only(
      top: getSpacing(hardcodedInsets.top),
      right: getSpacing(hardcodedInsets.right),
      bottom: getSpacing(hardcodedInsets.bottom),
      left: getSpacing(hardcodedInsets.left),
    );
  }
  
  /// Convertit un BorderRadius hardcodé vers les design tokens
  static BorderRadius migrateBorderRadius(BorderRadius hardcodedRadius) {
    if (hardcodedRadius is BorderRadius) {
      final topLeft = hardcodedRadius.topLeft.x;
      final newRadius = getBorderRadius(topLeft);
      return BorderRadius.circular(newRadius);
    }
    return BorderRadius.circular(AppSizes.radiusMd);
  }
  
  /// Convertit une Size hardcodée vers les design tokens
  static Size migrateSize(Size hardcodedSize) {
    return Size(
      getSpacing(hardcodedSize.width),
      getSpacing(hardcodedSize.height),
    );
  }

  // ========== HELPERS POUR LA MIGRATION ==========
  
  /// Suggestions de migration pour les développeurs
  static Map<String, String> get migrationSuggestions => {
    'padding: EdgeInsets.all(AppSpacing.md)': 'padding: AppSpacing.page',
    'height: AppSizes.buttonHeightLg': 'height: AppSizes.buttonHeightMd',
    'fontSize: AppTypography.fontSizeLg': 'fontSize: AppTypography.fontSizeLg',
    'BorderRadius.circular(AppSizes.radiusMd)': 'BorderRadius.circular(AppSizes.radiusMd)',
    'Color(0xFF6B46C1)': 'AppColors.primary',
    'MediaQuery.of(context).size.width < 600': 'AppBreakpoints.isMobile(context)',
    'Colors.white.withOpacity(0.15)': 'AppColors.glassWhite',
  };
  
  /// Vérifie si une valeur est probablement hardcodée
  static bool isLikelyHardcoded(double value) {
    final commonDesignTokens = [
      AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.lg, AppSpacing.xl,
      AppSizes.buttonHeightSm, AppSizes.buttonHeightMd, AppSizes.buttonHeightLg,
      AppSizes.iconSm, AppSizes.iconMd, AppSizes.iconLg,
      AppSizes.radiusSm, AppSizes.radiusMd, AppSizes.radiusLg,
    ];
    
    return !commonDesignTokens.contains(value);
  }
  
  /// Génère un rapport de migration pour un fichier
  static String generateMigrationReport(String filePath, List<String> hardcodedValues) {
    final buffer = StringBuffer();
    buffer.writeln('# Migration Report for $filePath');
    buffer.writeln('');
    buffer.writeln('## Hardcoded values found:');
    
    for (final value in hardcodedValues) {
      buffer.writeln('- `$value`');
      if (migrationSuggestions.containsKey(value)) {
        buffer.writeln('  → Suggested: `${migrationSuggestions[value]}`');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('## Migration steps:');
    buffer.writeln('1. Import design tokens: `import \'../core/theme/app_*.dart\';`');
    buffer.writeln('2. Replace hardcoded values with design tokens');
    buffer.writeln('3. Test responsive behavior on different screen sizes');
    buffer.writeln('4. Verify glassmorphism effects are preserved');
    
    return buffer.toString();
  }
}
