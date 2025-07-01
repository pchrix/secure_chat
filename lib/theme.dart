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

  // Couleurs spécifiques identifiées dans la codebase
  static const Color authBackground =
      Color(0xFF1C1C1E); // Arrière-plan auth/settings
  static const Color setupPurple = Color(0xFF9B59B6); // Couleur setup/timer
  static const Color copyBlue = Color(0xFF2E86AB); // Couleur bouton copy
  static const Color textHint = Color(0x80FFFFFF); // Couleur texte hint

  // Couleurs glassmorphism avec opacité améliorée
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.08);
  static Color glassShadow = Colors.black.withValues(alpha: 0.25);

  // Variantes d'opacité standardisées pour Colors.white
  static Color get whiteAlpha05 => Colors.white.withValues(alpha: 0.05);
  static Color get whiteAlpha08 => Colors.white.withValues(alpha: 0.08);
  static Color get whiteAlpha10 => Colors.white.withValues(alpha: 0.10);
  static Color get whiteAlpha15 => Colors.white.withValues(alpha: 0.15);
  static Color get whiteAlpha20 => Colors.white.withValues(alpha: 0.20);
  static Color get whiteAlpha25 => Colors.white.withValues(alpha: 0.25);
  static Color get whiteAlpha30 => Colors.white.withValues(alpha: 0.30);
  static Color get whiteAlpha60 => Colors.white.withValues(alpha: 0.60);
  static Color get whiteAlpha80 => Colors.white.withValues(alpha: 0.80);
  static Color get whiteAlpha90 => Colors.white.withValues(alpha: 0.90);
  static Color get whiteAlpha95 => Colors.white.withValues(alpha: 0.95);

  // Variantes d'opacité standardisées pour Colors.black
  static Color get blackAlpha08 => Colors.black.withValues(alpha: 0.08);
  static Color get blackAlpha15 => Colors.black.withValues(alpha: 0.15);
  static Color get blackAlpha25 => Colors.black.withValues(alpha: 0.25);
  static Color get blackAlpha30 => Colors.black.withValues(alpha: 0.30);

  // Variantes d'opacité pour couleurs spécifiques
  static Color get primaryAlpha15 => primary.withValues(alpha: 0.15);
  static Color get primaryAlpha20 => primary.withValues(alpha: 0.20);
  static Color get primaryAlpha30 => primary.withValues(alpha: 0.30);
  static Color get setupPurpleAlpha20 => setupPurple.withValues(alpha: 0.20);
  static Color get setupPurpleAlpha50 => setupPurple.withValues(alpha: 0.50);
  static Color get copyBlueAlpha20 => copyBlue.withValues(alpha: 0.20);
  static Color get copyBlueAlpha30 => copyBlue.withValues(alpha: 0.30);

  // Couleurs sémantiques pour l'UI
  static Color get textPrimary => Colors.white;
  static Color get textSecondary => Colors.white.withValues(alpha: 0.8);
  static Color get textTertiary => Colors.white.withValues(alpha: 0.6);
  static Color get textPlaceholder => Colors.white.withValues(alpha: 0.5);
  static Color get textDisabled => Colors.white.withValues(alpha: 0.3);

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

/// Styles de texte standardisés pour SecureChat
class AppTextStyles {
  // Titres principaux
  static TextStyle get appTitle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: Colors.white,
      );

  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.8),
      );

  // Corps de texte
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.8),
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.7),
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.6),
      );

  // Labels et boutons
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      );

  // Styles spécialisés
  static TextStyle get pinNumber => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.95),
      );

  static TextStyle get roomTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Colors.white,
      );

  static TextStyle get statusText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get badgeText => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      );

  static TextStyle get hintText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.5),
      );

  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.red.withValues(alpha: 0.9),
      );

  static TextStyle get versionText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white60,
      );
}

/// Constantes d'animation standardisées pour SecureChat
class AppAnimations {
  // Durées standardisées
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 800);

  // Courbes d'animation standardisées
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeOutBack;

  // Durées spécialisées
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration ripple = Duration(milliseconds: 200);
  static const Duration shake = Duration(milliseconds: 600);
  static const Duration pulse = Duration(milliseconds: 2000);
  static const Duration particles = Duration(milliseconds: 4000);

  // Options d'accessibilité
  static bool get reduceMotion => false; // À connecter aux préférences système

  static Duration getDuration(Duration duration) {
    return reduceMotion ? Duration.zero : duration;
  }

  static Curve getCurve(Curve curve) {
    return reduceMotion ? Curves.linear : curve;
  }
}

/// Constantes responsive pour l'adaptabilité multi-écrans
class AppLayout {
  // Breakpoints responsive
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Espacements standardisés
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Tailles de composants
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 40.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeLarge = 32.0;

  // Rayons de bordure
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 30.0;

  // Méthodes utilitaires - DEPRECATED: Utiliser ResponsiveUtils à la place
  @Deprecated('Utiliser ResponsiveUtils.isMobile() à la place')
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  @Deprecated('Utiliser ResponsiveUtils.isTablet() à la place')
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  @Deprecated('Utiliser ResponsiveUtils.isDesktop() à la place')
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  @Deprecated('Utiliser ResponsiveUtils.getResponsivePadding() à la place')
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return spacingM;
    if (isTablet(context)) return spacingL;
    return spacingXL;
  }

  @Deprecated('Utiliser ResponsiveUtils.getResponsiveFontSize() à la place')
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return baseFontSize * 0.9; // 10% plus petit sur mobile
    }
    if (screenWidth > desktopBreakpoint) {
      return baseFontSize * 1.1; // 10% plus grand sur desktop
    }
    return baseFontSize;
  }
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
