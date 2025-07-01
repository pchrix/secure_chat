/// ✍️ AppTypography - Design Tokens pour la typographie
/// 
/// Système typographique cohérent basé sur Material Design 3
/// Optimisé pour la lisibilité et l'accessibilité
/// 
/// Usage:
/// ```dart
/// Text(
///   'Hello World',
///   style: AppTypography.headlineLarge,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens pour la typographie de l'application SecureChat
class AppTypography {
  // Empêche l'instanciation
  AppTypography._();

  // ========== FAMILLES DE POLICES ==========
  
  /// Police principale (Inter)
  static const String primaryFontFamily = 'Inter';
  
  /// Police secondaire (Roboto)
  static const String secondaryFontFamily = 'Roboto';
  
  /// Police monospace (JetBrains Mono)
  static const String monospaceFontFamily = 'JetBrains Mono';

  // ========== TAILLES DE POLICE ==========
  
  /// Taille extra small
  static const double fontSizeXs = 10.0;
  
  /// Taille small
  static const double fontSizeSm = 12.0;
  
  /// Taille medium (base)
  static const double fontSizeMd = 14.0;
  
  /// Taille large
  static const double fontSizeLg = 16.0;
  
  /// Taille extra large
  static const double fontSizeXl = 18.0;
  
  /// Taille 2xl
  static const double fontSize2xl = 20.0;
  
  /// Taille 3xl
  static const double fontSize3xl = 24.0;
  
  /// Taille 4xl
  static const double fontSize4xl = 32.0;
  
  /// Taille 5xl
  static const double fontSize5xl = 40.0;
  
  /// Taille 6xl
  static const double fontSize6xl = 48.0;

  // ========== HAUTEURS DE LIGNE ==========
  
  /// Hauteur de ligne serrée
  static const double lineHeightTight = 1.2;
  
  /// Hauteur de ligne normale
  static const double lineHeightNormal = 1.4;
  
  /// Hauteur de ligne relâchée
  static const double lineHeightRelaxed = 1.6;
  
  /// Hauteur de ligne large
  static const double lineHeightLoose = 1.8;

  // ========== POIDS DE POLICE ==========
  
  /// Poids léger
  static const FontWeight weightLight = FontWeight.w300;
  
  /// Poids normal
  static const FontWeight weightNormal = FontWeight.w400;
  
  /// Poids medium
  static const FontWeight weightMedium = FontWeight.w500;
  
  /// Poids semi-bold
  static const FontWeight weightSemiBold = FontWeight.w600;
  
  /// Poids bold
  static const FontWeight weightBold = FontWeight.w700;
  
  /// Poids extra bold
  static const FontWeight weightExtraBold = FontWeight.w800;

  // ========== STYLES DE TITRE ==========
  
  /// Display Large - 57px
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 57.0,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: -0.25,
  );
  
  /// Display Medium - 45px
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 45.0,
    fontWeight: weightBold,
    height: lineHeightTight,
    letterSpacing: 0.0,
  );
  
  /// Display Small - 36px
  static TextStyle get displaySmall => GoogleFonts.inter(
    fontSize: 36.0,
    fontWeight: weightSemiBold,
    height: lineHeightTight,
    letterSpacing: 0.0,
  );
  
  /// Headline Large - 32px
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: fontSize4xl,
    fontWeight: weightSemiBold,
    height: lineHeightTight,
    letterSpacing: 0.0,
  );
  
  /// Headline Medium - 28px
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 28.0,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
    letterSpacing: 0.0,
  );
  
  /// Headline Small - 24px
  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: fontSize3xl,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.0,
  );

  // ========== STYLES DE TITRE SECONDAIRE ==========
  
  /// Title Large - 22px
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22.0,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.0,
  );
  
  /// Title Medium - 16px
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: fontSizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.15,
  );
  
  /// Title Small - 14px
  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.1,
  );

  // ========== STYLES DE CORPS ==========
  
  /// Body Large - 16px
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: fontSizeLg,
    fontWeight: weightNormal,
    height: lineHeightRelaxed,
    letterSpacing: 0.5,
  );
  
  /// Body Medium - 14px
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: weightNormal,
    height: lineHeightRelaxed,
    letterSpacing: 0.25,
  );
  
  /// Body Small - 12px
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: weightNormal,
    height: lineHeightNormal,
    letterSpacing: 0.4,
  );

  // ========== STYLES DE LABEL ==========
  
  /// Label Large - 14px
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.1,
  );
  
  /// Label Medium - 12px
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.5,
  );
  
  /// Label Small - 11px
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11.0,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.5,
  );

  // ========== STYLES SPÉCIALISÉS ==========
  
  /// Style pour les boutons
  static TextStyle get button => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.1,
  );
  
  /// Style pour les captions
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: fontSizeSm,
    fontWeight: weightNormal,
    height: lineHeightNormal,
    letterSpacing: 0.4,
  );
  
  /// Style pour l'overline
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: fontSizeXs,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 1.5,
  );
  
  /// Style pour le code
  static TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: fontSizeMd,
    fontWeight: weightNormal,
    height: lineHeightNormal,
    letterSpacing: 0.0,
  );
  
  /// Style pour les liens
  static TextStyle get link => GoogleFonts.inter(
    fontSize: fontSizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
    letterSpacing: 0.25,
    decoration: TextDecoration.underline,
  );

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient un style responsive basé sur la taille d'écran
  static TextStyle getResponsiveStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double? mobileScale,
    double? tabletScale,
    double? desktopScale,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    double scale = 1.0;
    
    if (width < 480 && mobileScale != null) {
      scale = mobileScale;
    } else if (width < 768 && tabletScale != null) {
      scale = tabletScale;
    } else if (desktopScale != null) {
      scale = desktopScale;
    }
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? fontSizeMd) * scale,
    );
  }
  
  /// Obtient un style avec couleur
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Obtient un style avec opacité
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: (style.color ?? Colors.black).withValues(alpha: opacity),
    );
  }
  
  /// Obtient un style avec poids de police
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Obtient un style avec taille de police
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  // ========== THÈME TYPOGRAPHIQUE ==========
  
  /// Obtient le thème typographique complet
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
  
  /// Obtient le thème typographique avec couleurs
  static TextTheme getTextThemeWithColor(Color color) => TextTheme(
    displayLarge: withColor(displayLarge, color),
    displayMedium: withColor(displayMedium, color),
    displaySmall: withColor(displaySmall, color),
    headlineLarge: withColor(headlineLarge, color),
    headlineMedium: withColor(headlineMedium, color),
    headlineSmall: withColor(headlineSmall, color),
    titleLarge: withColor(titleLarge, color),
    titleMedium: withColor(titleMedium, color),
    titleSmall: withColor(titleSmall, color),
    bodyLarge: withColor(bodyLarge, color),
    bodyMedium: withColor(bodyMedium, color),
    bodySmall: withColor(bodySmall, color),
    labelLarge: withColor(labelLarge, color),
    labelMedium: withColor(labelMedium, color),
    labelSmall: withColor(labelSmall, color),
  );
}
