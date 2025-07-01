/// 🎨 AppColors - Design Tokens pour les couleurs unifiées
/// 
/// Système de couleurs cohérent pour l'application SecureChat
/// Centralise toutes les couleurs GlassColors et élimine les duplications
/// Supporte les thèmes dark et light avec glassmorphism
/// 
/// Usage:
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text('Hello', style: TextStyle(color: AppColors.onPrimary)),
/// )
/// ```

import 'package:flutter/material.dart';

/// Design tokens pour les couleurs de l'application SecureChat
class AppColors {
  // Empêche l'instanciation
  AppColors._();

  // ========== COULEURS PRINCIPALES ==========
  
  /// Couleur primaire - Violet moderne
  static const Color primary = Color(0xFF6B46C1);
  
  /// Couleur secondaire - Rose/magenta
  static const Color secondary = Color(0xFFEC4899);
  
  /// Couleur d'accent - Orange vif
  static const Color accent = Color(0xFFF97316);
  
  /// Couleur tertiaire - Cyan
  static const Color tertiary = Color(0xFF06B6D4);

  // ========== COULEURS SÉMANTIQUES ==========
  
  /// Couleur de succès
  static const Color success = Color(0xFF10B981);
  
  /// Couleur d'erreur/danger
  static const Color error = Color(0xFFFF3366);
  
  /// Couleur d'avertissement
  static const Color warning = Color(0xFFFFB800);
  
  /// Couleur d'information
  static const Color info = Color(0xFF06B6D4);

  // ========== COULEURS DE SURFACE ==========
  
  /// Surface principale (dark theme)
  static const Color surface = Color(0xFF0F0F23);
  
  /// Surface variante
  static const Color surfaceVariant = Color(0xFF1A1A2E);
  
  /// Surface container
  static const Color surfaceContainer = Color(0xFF16213E);
  
  /// Surface bright
  static const Color surfaceBright = Color(0xFF1F1F3A);
  
  /// Background principal
  static const Color background = Color(0xFF0A0A1A);
  
  /// Background secondaire
  static const Color backgroundSecondary = Color(0xFF1C1C1E);

  // ========== COULEURS DE TEXTE ==========
  
  /// Texte principal sur surface sombre
  static const Color onSurface = Color(0xFFE1E1E6);
  
  /// Texte secondaire sur surface sombre
  static const Color onSurfaceVariant = Color(0xFFB0B0B8);
  
  /// Texte sur couleur primaire
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  /// Texte sur couleur secondaire
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  /// Texte sur background
  static const Color onBackground = Color(0xFFE1E1E6);
  
  /// Texte hint/placeholder
  static const Color textHint = Color(0x80FFFFFF);
  
  /// Texte disabled
  static const Color textDisabled = Color(0x60FFFFFF);

  // ========== COULEURS SPÉCIALISÉES ==========
  
  /// Couleur pour l'authentification
  static const Color authBackground = Color(0xFF1C1C1E);

  /// Couleur pour le setup/timer
  static const Color setupPurple = Color(0xFF9B59B6);

  /// Couleur pour le bouton copy
  static const Color copyBlue = Color(0xFF2E86AB);

  /// Couleurs alpha spécialisées (pour migration GlassColors)
  static Color get whiteAlpha10 => Colors.white.withValues(alpha: 0.1);
  static Color get whiteAlpha05 => Colors.white.withValues(alpha: 0.05);
  static Color get setupPurpleAlpha20 => setupPurple.withValues(alpha: 0.2);
  
  /// Couleur pour les bordures
  static const Color border = Color(0xFF2A2A3E);
  
  /// Couleur pour les dividers
  static const Color divider = Color(0xFF1F1F3A);

  // ========== COULEURS GLASSMORPHISM ==========
  
  /// Verre blanc avec opacité
  static Color get glassWhite => Colors.white.withValues(alpha: 0.15);
  
  /// Bordure de verre
  static Color get glassBorder => Colors.white.withValues(alpha: 0.25);
  
  /// Highlight de verre
  static Color get glassHighlight => Colors.white.withValues(alpha: 0.08);
  
  /// Ombre de verre
  static Color get glassShadow => Colors.black.withValues(alpha: 0.25);
  
  /// Surface de verre
  static Color get glassSurface => surface.withValues(alpha: 0.8);
  
  /// Container de verre
  static Color get glassContainer => surfaceContainer.withValues(alpha: 0.6);

  // ========== COULEURS LIGHT THEME ==========
  
  /// Surface light
  static const Color lightSurface = Color(0xFFF1F4F8);
  
  /// Background light
  static const Color lightBackground = Color(0xFFFFFFFF);
  
  /// Texte sur surface light
  static const Color lightOnSurface = Color(0xFF15161E);
  
  /// Texte secondaire light
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);
  
  /// Bordure light
  static const Color lightBorder = Color(0xFFE5E7EB);
  
  /// Divider light
  static const Color lightDivider = Color(0xFFF3F4F6);

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient la couleur de texte appropriée pour un arrière-plan
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightOnSurface : onSurface;
  }
  
  /// Obtient une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Obtient une couleur glassmorphism personnalisée
  static Color getGlassColor(Color baseColor, {double opacity = 0.15}) {
    return baseColor.withValues(alpha: opacity);
  }
  
  /// Obtient la couleur de surface basée sur le thème
  static Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? surface : lightSurface;
  }
  
  /// Obtient la couleur de background basée sur le thème
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? background : lightBackground;
  }
  
  /// Obtient la couleur de texte basée sur le thème
  static Color getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? onSurface : lightOnSurface;
  }

  // ========== PALETTES DE COULEURS ==========
  
  /// Palette de couleurs primaires
  static const Map<int, Color> primarySwatch = {
    50: Color(0xFFF3F1FF),
    100: Color(0xFFE9E5FF),
    200: Color(0xFFD6CFFF),
    300: Color(0xFFB8ACFF),
    400: Color(0xFF9580FF),
    500: primary,
    600: Color(0xFF5B3BA3),
    700: Color(0xFF4C3085),
    800: Color(0xFF3D2567),
    900: Color(0xFF2E1A49),
  };
  
  /// Palette de couleurs secondaires
  static const Map<int, Color> secondarySwatch = {
    50: Color(0xFFFDF2F8),
    100: Color(0xFFFCE7F3),
    200: Color(0xFFFBCFE8),
    300: Color(0xFFF9A8D4),
    400: Color(0xFFF472B6),
    500: secondary,
    600: Color(0xFFDB2777),
    700: Color(0xFFBE185D),
    800: Color(0xFF9D174D),
    900: Color(0xFF831843),
  };
  
  /// Palette de couleurs d'accent
  static const Map<int, Color> accentSwatch = {
    50: Color(0xFFFFF7ED),
    100: Color(0xFFFFEDD5),
    200: Color(0xFFFED7AA),
    300: Color(0xFFFDBA74),
    400: Color(0xFFFB923C),
    500: accent,
    600: Color(0xFFEA580C),
    700: Color(0xFFC2410C),
    800: Color(0xFF9A3412),
    900: Color(0xFF7C2D12),
  };

  // ========== COULEURS DE STATUS ==========
  
  /// Status online
  static const Color statusOnline = success;
  
  /// Status offline
  static const Color statusOffline = Color(0xFF6B7280);
  
  /// Status away
  static const Color statusAway = warning;
  
  /// Status busy
  static const Color statusBusy = error;
  
  /// Status typing
  static const Color statusTyping = info;

  // ========== COULEURS D'INTERACTION ==========
  
  /// Couleur de hover
  static Color get hoverColor => glassWhite;
  
  /// Couleur de focus
  static Color get focusColor => primary.withValues(alpha: 0.2);
  
  /// Couleur de pressed
  static Color get pressedColor => primary.withValues(alpha: 0.3);
  
  /// Couleur de selected
  static Color get selectedColor => primary.withValues(alpha: 0.15);
  
  /// Couleur de disabled
  static Color get disabledColor => onSurface.withValues(alpha: 0.3);
}
