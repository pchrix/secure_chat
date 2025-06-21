import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palette de couleurs glassmorphism - Design cible
class GlassColors {
  // Couleurs principales du design cible
  static const Color primary = Color(0xFF6B46C1); // Violet principal
  static const Color secondary = Color(0xFFEC4899); // Rose/magenta
  static const Color accent = Color(0xFFF97316); // Orange vif
  static const Color tertiary = Color(0xFF06B6D4); // Cyan
  static const Color danger = Color(0xFFFF3366); // Rouge vif
  static const Color warning = Color(0xFFFFB800); // Orange doré
  static const Color success = Color(0xFF10B981); // Vert succès

  // Arrière-plan avec dégradé
  static const Color backgroundStart = Color(0xFF1E1B4B); // Bleu foncé
  static const Color backgroundEnd = Color(0xFF6B46C1); // Violet
  static const Color background = Color(0xFF1A1625); // Base sombre
  static const Color surface = Color(0xFF2D1B69); // Surface violette
  static const Color surfaceVariant = Color(0xFF3730A3); // Variant plus clair

  // Couleurs de texte
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFFCBD5E1);

  // Couleurs glassmorphism avec opacité améliorée
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.08);
  static Color glassShadow = Colors.black.withValues(alpha: 0.25);

  // Dégradés pour les effets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B46C1), Color(0xFF9333EA)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1B4B), Color(0xFF6B46C1)],
  );
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: GlassColors.primary,
        secondary: GlassColors.secondary,
        tertiary: GlassColors.accent,
        surface: const Color(0xFFF1F4F8),
        error: GlassColors.danger,
        onPrimary: GlassColors.onPrimary,
        onSecondary: const Color(0xFF15161E),
        onTertiary: const Color(0xFF15161E),
        onSurface: const Color(0xFF15161E),
        onError: GlassColors.onPrimary,
        outline: const Color(0xFFB0BEC5),
      ),
      brightness: Brightness.light,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 57.0,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45.0,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32.0,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: GlassColors.primary,
        secondary: GlassColors.secondary,
        tertiary: GlassColors.accent,
        surface: GlassColors.surface,
        surfaceContainerHighest: GlassColors.surfaceVariant,
        error: GlassColors.danger,
        onPrimary: GlassColors.onPrimary,
        onSecondary: GlassColors.onSurface,
        onTertiary: GlassColors.onSurface,
        onSurface: GlassColors.onSurface,
        onError: GlassColors.onPrimary,
        outline: GlassColors.onSurfaceVariant,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GlassColors.background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 57.0,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45.0,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32.0,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
