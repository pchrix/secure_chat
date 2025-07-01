/// 🎨 Thème principal de l'application SecureChat
///
/// Définit le thème glassmorphism et les styles visuels cohérents
/// à travers toute l'application.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

/// Gestionnaire de thème principal
class AppTheme {
  AppTheme._();

  // 🎨 Couleurs principales
  static const Color primaryColor = Color(ThemeConstants.primaryColorValue);
  static const Color secondaryColor = Color(ThemeConstants.secondaryColorValue);
  static const Color accentColor = Color(ThemeConstants.accentColorValue);

  // 🌈 Palette de couleurs étendues
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color infoColor = Color(0xFF3B82F6);

  // 🌙 Couleurs mode sombre
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  static const Color darkBackgroundColor = Color(0xFF0F172A);
  static const Color darkCardColor = Color(0xFF334155);

  // 📝 Couleurs de texte
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  /// Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 🎨 Schéma de couleurs
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),

      // 📱 Configuration de l'app bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 🃏 Configuration des cartes
      cardTheme: CardThemeData(
        elevation: ThemeConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        color: cardColor.withValues(alpha: 0.8),
        shadowColor: primaryColor.withValues(alpha: 0.1),
      ),

      // 🔘 Configuration des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLg,
            vertical: ThemeConstants.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 📝 Configuration des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMd,
          vertical: ThemeConstants.spacingMd,
        ),
      ),

      // 📚 Typographie
      textTheme: _textTheme,

      // 🎭 Configuration des icônes
      iconTheme: const IconThemeData(
        color: textSecondaryLight,
        size: 24,
      ),

      // 🎨 Configuration des dividers
      dividerTheme: DividerThemeData(
        color: textTertiaryLight.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // 🔄 Configuration des indicateurs de progression
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Colors.transparent,
      ),

      // 🎯 Configuration des floating action buttons
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),

      // 📱 Configuration de la navigation bottom
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor.withValues(alpha: 0.9),
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // 🎨 Extensions personnalisées
      extensions: [
        GlassmorphismTheme.light(),
      ],
    );
  }

  /// Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 🎨 Schéma de couleurs
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),

      // 📱 Configuration de l'app bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 🃏 Configuration des cartes
      cardTheme: CardThemeData(
        elevation: ThemeConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        ),
        color: darkCardColor.withValues(alpha: 0.8),
        shadowColor: primaryColor.withValues(alpha: 0.1),
      ),

      // 🔘 Configuration des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLg,
            vertical: ThemeConstants.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 📝 Configuration des champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMd,
          vertical: ThemeConstants.spacingMd,
        ),
      ),

      // 📚 Typographie
      textTheme: _textTheme.apply(
        bodyColor: textPrimaryDark,
        displayColor: textPrimaryDark,
      ),

      // 🎭 Configuration des icônes
      iconTheme: const IconThemeData(
        color: textSecondaryDark,
        size: 24,
      ),

      // 🎨 Configuration des dividers
      dividerTheme: DividerThemeData(
        color: textTertiaryDark.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // 🔄 Configuration des indicateurs de progression
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Colors.transparent,
      ),

      // 🎯 Configuration des floating action buttons
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),

      // 📱 Configuration de la navigation bottom
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBackgroundColor.withValues(alpha: 0.9),
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // 🎨 Extensions personnalisées
      extensions: [
        GlassmorphismTheme.dark(),
      ],
    );
  }

  /// Typographie de l'application
  static const TextTheme _textTheme = TextTheme(
    // Titres
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),

    // En-têtes
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),

    // Titres de section
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),

    // Corps de texte
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),

    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  );
}

/// Extension de thème pour le glassmorphism
class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  final Color glassColor;
  final double glassOpacity;
  final double glassBlur;
  final Color borderColor;
  final double borderWidth;

  const GlassmorphismTheme({
    required this.glassColor,
    required this.glassOpacity,
    required this.glassBlur,
    required this.borderColor,
    required this.borderWidth,
  });

  factory GlassmorphismTheme.light() {
    return const GlassmorphismTheme(
      glassColor: Colors.white,
      glassOpacity: 0.1,
      glassBlur: 10.0,
      borderColor: Colors.white,
      borderWidth: 1.0,
    );
  }

  factory GlassmorphismTheme.dark() {
    return const GlassmorphismTheme(
      glassColor: Colors.white,
      glassOpacity: 0.05,
      glassBlur: 10.0,
      borderColor: Colors.white,
      borderWidth: 0.5,
    );
  }

  @override
  GlassmorphismTheme copyWith({
    Color? glassColor,
    double? glassOpacity,
    double? glassBlur,
    Color? borderColor,
    double? borderWidth,
  }) {
    return GlassmorphismTheme(
      glassColor: glassColor ?? this.glassColor,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      glassBlur: glassBlur ?? this.glassBlur,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  GlassmorphismTheme lerp(ThemeExtension<GlassmorphismTheme>? other, double t) {
    if (other is! GlassmorphismTheme) return this;

    return GlassmorphismTheme(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      glassOpacity: (glassOpacity * (1 - t)) + (other.glassOpacity * t),
      glassBlur: (glassBlur * (1 - t)) + (other.glassBlur * t),
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: (borderWidth * (1 - t)) + (other.borderWidth * t),
    );
  }
}
