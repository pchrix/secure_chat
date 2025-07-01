/// 🎨 AppThemeUnified - Thème unifié pour SecureChat
/// 
/// Centralise tous les design tokens et élimine les duplications
/// Intègre AppColors, AppSpacing, AppSizes, AppTypography, AppBreakpoints
/// Supporte dark/light theme avec glassmorphism cohérent
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppThemeUnified.lightTheme,
///   darkTheme: AppThemeUnified.darkTheme,
///   home: MyApp(),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_sizes.dart';
import 'app_typography.dart';
import 'app_breakpoints.dart';

/// Thème unifié de l'application SecureChat
class AppThemeUnified {
  // Empêche l'instanciation
  AppThemeUnified._();

  // ========== THÈMES PRINCIPAUX ==========
  
  /// Thème sombre (principal)
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
  );
  
  /// Thème clair
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
  );

  // ========== COLOR SCHEMES ==========
  
  /// Schéma de couleurs sombre
  static ColorScheme get _darkColorScheme => ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: AppColors.surface,
    surfaceContainerHighest: AppColors.surfaceContainer,
    surfaceContainer: AppColors.surfaceVariant,
    surfaceBright: AppColors.surfaceBright,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onTertiary: AppColors.onPrimary,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    onBackground: AppColors.onBackground,
    onError: AppColors.onPrimary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );
  
  /// Schéma de couleurs clair
  static ColorScheme get _lightColorScheme => ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: AppColors.lightSurface,
    background: AppColors.lightBackground,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onPrimary,
    onTertiary: AppColors.onPrimary,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    onBackground: AppColors.lightOnSurface,
    onError: AppColors.onPrimary,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightDivider,
  );

  // ========== CONSTRUCTION DU THÈME ==========
  
  /// Construit un thème complet avec tous les composants
  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      
      // Typographie
      textTheme: AppTypography.getTextThemeWithColor(
        isDark ? AppColors.onSurface : AppColors.lightOnSurface,
      ),
      
      // Configuration des composants
      appBarTheme: _buildAppBarTheme(colorScheme, isDark),
      elevatedButtonTheme: _buildElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(colorScheme),
      textButtonTheme: _buildTextButtonTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme, isDark),
      cardTheme: _buildCardTheme(colorScheme, isDark),
      dialogTheme: _buildDialogTheme(colorScheme, isDark),
      bottomNavigationBarTheme: _buildBottomNavTheme(colorScheme, isDark),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, isDark),
      floatingActionButtonTheme: _buildFABTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme, isDark),
      dividerTheme: _buildDividerTheme(colorScheme),
      
      // Extensions personnalisées
      extensions: [
        GlassmorphismTheme.fromBrightness(brightness),
      ],
    );
  }

  // ========== THÈMES DE COMPOSANTS ==========
  
  /// Thème de l'AppBar
  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme, bool isDark) {
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      foregroundColor: colorScheme.onSurface,
      elevation: AppSizes.elevationSm,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      systemOverlayStyle: isDark 
        ? SystemUiOverlayStyle.light 
        : SystemUiOverlayStyle.dark,
    );
  }
  
  /// Thème des boutons élevés
  static ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: Size(AppSizes.buttonMinWidth, AppSizes.buttonHeightMd),
        padding: AppSpacing.button,
        shape: RoundedRectangleBorder(
          borderRadius: AppSizes.buttonRadius,
        ),
        elevation: AppSizes.elevationMd,
        textStyle: AppTypography.button,
      ),
    );
  }
  
  /// Thème des boutons outlined
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: Size(AppSizes.buttonMinWidth, AppSizes.buttonHeightMd),
        padding: AppSpacing.button,
        shape: RoundedRectangleBorder(
          borderRadius: AppSizes.buttonRadius,
        ),
        side: BorderSide(
          color: colorScheme.primary,
          width: AppSizes.borderMedium,
        ),
        textStyle: AppTypography.button,
      ),
    );
  }
  
  /// Thème des boutons texte
  static TextButtonThemeData _buildTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: Size(AppSizes.buttonMinWidth, AppSizes.buttonHeightMd),
        padding: AppSpacing.button,
        shape: RoundedRectangleBorder(
          borderRadius: AppSizes.buttonRadius,
        ),
        textStyle: AppTypography.button,
      ),
    );
  }
  
  /// Thème des champs de texte
  static InputDecorationTheme _buildInputDecorationTheme(
    ColorScheme colorScheme, 
    bool isDark,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: AppSizes.inputRadius,
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: AppSizes.borderThin,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSizes.inputRadius,
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: AppSizes.borderThin,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSizes.inputRadius,
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: AppSizes.borderMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSizes.inputRadius,
        borderSide: BorderSide(
          color: colorScheme.error,
          width: AppSizes.borderMedium,
        ),
      ),
      contentPadding: AppSpacing.input,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.textHint : AppColors.lightOnSurfaceVariant,
      ),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
  
  /// Thème des cartes
  static CardTheme _buildCardTheme(ColorScheme colorScheme, bool isDark) {
    return CardTheme(
      color: isDark ? AppColors.surfaceContainer : AppColors.lightSurface,
      elevation: AppSizes.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: AppSizes.cardRadius,
      ),
      margin: AppSpacing.card,
    );
  }
  
  /// Thème des dialogs
  static DialogTheme _buildDialogTheme(ColorScheme colorScheme, bool isDark) {
    return DialogTheme(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      elevation: AppSizes.elevationXl,
      shape: RoundedRectangleBorder(
        borderRadius: AppSizes.modalRadius,
      ),
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
  
  /// Thème de la navigation bottom
  static BottomNavigationBarThemeData _buildBottomNavTheme(
    ColorScheme colorScheme, 
    bool isDark,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: AppSizes.elevationMd,
    );
  }
  
  /// Thème de la navigation bar
  static NavigationBarThemeData _buildNavigationBarTheme(
    ColorScheme colorScheme, 
    bool isDark,
  ) {
    return NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      elevation: AppSizes.elevationMd,
      height: AppSizes.bottomNavHeight,
    );
  }
  
  /// Thème du FAB
  static FloatingActionButtonThemeData _buildFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: AppSizes.elevationLg,
      shape: RoundedRectangleBorder(
        borderRadius: AppSizes.circularRadius,
      ),
    );
  }
  
  /// Thème des chips
  static ChipThemeData _buildChipTheme(ColorScheme colorScheme, bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
      selectedColor: colorScheme.primary,
      labelStyle: AppTypography.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
  
  /// Thème des dividers
  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: AppSizes.borderThin,
      space: AppSpacing.sm,
    );
  }
}

/// Extension de thème pour le glassmorphism
class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  final Color glassColor;
  final Color borderColor;
  final double blur;
  final double opacity;

  const GlassmorphismTheme({
    required this.glassColor,
    required this.borderColor,
    required this.blur,
    required this.opacity,
  });

  factory GlassmorphismTheme.fromBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return GlassmorphismTheme(
      glassColor: isDark ? AppColors.glassWhite : AppColors.glassWhite,
      borderColor: isDark ? AppColors.glassBorder : AppColors.glassBorder,
      blur: 10.0,
      opacity: isDark ? 0.15 : 0.1,
    );
  }

  @override
  GlassmorphismTheme copyWith({
    Color? glassColor,
    Color? borderColor,
    double? blur,
    double? opacity,
  }) {
    return GlassmorphismTheme(
      glassColor: glassColor ?? this.glassColor,
      borderColor: borderColor ?? this.borderColor,
      blur: blur ?? this.blur,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  GlassmorphismTheme lerp(ThemeExtension<GlassmorphismTheme>? other, double t) {
    if (other is! GlassmorphismTheme) return this;
    return GlassmorphismTheme(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      blur: (blur * (1 - t)) + (other.blur * t),
      opacity: (opacity * (1 - t)) + (other.opacity * t),
    );
  }
}
