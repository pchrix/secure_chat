/// ✨ GlassmorphismContainer - Conteneur avec effet glassmorphism
/// 
/// Widget réutilisable qui applique un effet glassmorphism moderne
/// avec transparence, flou et bordures subtiles.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../../core/theme/app_theme.dart';

/// Conteneur avec effet glassmorphism
class GlassmorphismContainer extends StatelessWidget {
  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20.0,
    this.opacity = 0.15,
    this.blurSigma = 10.0,
    this.borderWidth = 1.0,
    this.borderOpacity = 0.2,
    this.shadowOpacity = 0.1,
    this.shadowBlurRadius = 20.0,
    this.shadowOffset = const Offset(0, 10),
  });

  /// Widget enfant à afficher dans le conteneur
  final Widget child;

  /// Largeur du conteneur (optionnelle)
  final double? width;

  /// Hauteur du conteneur (optionnelle)
  final double? height;

  /// Padding interne du conteneur
  final EdgeInsetsGeometry padding;

  /// Margin externe du conteneur
  final EdgeInsetsGeometry margin;

  /// Rayon des coins arrondis
  final double borderRadius;

  /// Opacité de l'arrière-plan
  final double opacity;

  /// Intensité du flou
  final double blurSigma;

  /// Épaisseur de la bordure
  final double borderWidth;

  /// Opacité de la bordure
  final double borderOpacity;

  /// Opacité de l'ombre
  final double shadowOpacity;

  /// Rayon de flou de l'ombre
  final double shadowBlurRadius;

  /// Décalage de l'ombre
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: shadowBlurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: borderWidth,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Variantes prédéfinies du GlassmorphismContainer
class GlassmorphismVariants {
  /// Conteneur pour les cartes
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismContainer(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      margin: margin ?? EdgeInsets.zero,
      borderRadius: 16.0,
      opacity: 0.1,
      blurSigma: 8.0,
      borderWidth: 0.5,
      borderOpacity: 0.15,
      shadowOpacity: 0.05,
      shadowBlurRadius: 15.0,
      shadowOffset: const Offset(0, 5),
      child: child,
    );
  }

  /// Conteneur pour les modales
  static Widget modal({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismContainer(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: margin ?? EdgeInsets.zero,
      borderRadius: 24.0,
      opacity: 0.2,
      blurSigma: 15.0,
      borderWidth: 1.5,
      borderOpacity: 0.25,
      shadowOpacity: 0.15,
      shadowBlurRadius: 30.0,
      shadowOffset: const Offset(0, 15),
      child: child,
    );
  }

  /// Conteneur pour les boutons
  static Widget button({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismContainer(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
        margin: margin ?? EdgeInsets.zero,
        borderRadius: 12.0,
        opacity: 0.12,
        blurSigma: 6.0,
        borderWidth: 1.0,
        borderOpacity: 0.2,
        shadowOpacity: 0.08,
        shadowBlurRadius: 12.0,
        shadowOffset: const Offset(0, 4),
        child: child,
      ),
    );
  }

  /// Conteneur pour les champs de texte
  static Widget textField({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismContainer(
      padding: padding ?? const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      margin: margin ?? EdgeInsets.zero,
      borderRadius: 12.0,
      opacity: 0.08,
      blurSigma: 4.0,
      borderWidth: 0.5,
      borderOpacity: 0.1,
      shadowOpacity: 0.03,
      shadowBlurRadius: 8.0,
      shadowOffset: const Offset(0, 2),
      child: child,
    );
  }

  /// Conteneur pour les notifications
  static Widget notification({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
  }) {
    return GlassmorphismContainer(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      margin: margin ?? EdgeInsets.zero,
      borderRadius: 14.0,
      opacity: 0.15,
      blurSigma: 10.0,
      borderWidth: 1.0,
      borderOpacity: 0.2,
      shadowOpacity: 0.1,
      shadowBlurRadius: 20.0,
      shadowOffset: const Offset(0, 8),
      child: Container(
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              )
            : null,
        child: child,
      ),
    );
  }
}

/// Extension pour faciliter l'utilisation du glassmorphism
extension GlassmorphismExtension on Widget {
  /// Applique un effet glassmorphism au widget
  Widget glassmorphism({
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 20.0,
    double opacity = 0.15,
    double blurSigma = 10.0,
    double borderWidth = 1.0,
    double borderOpacity = 0.2,
    double shadowOpacity = 0.1,
    double shadowBlurRadius = 20.0,
    Offset shadowOffset = const Offset(0, 10),
  }) {
    return GlassmorphismContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: margin ?? EdgeInsets.zero,
      borderRadius: borderRadius,
      opacity: opacity,
      blurSigma: blurSigma,
      borderWidth: borderWidth,
      borderOpacity: borderOpacity,
      shadowOpacity: shadowOpacity,
      shadowBlurRadius: shadowBlurRadius,
      shadowOffset: shadowOffset,
      child: this,
    );
  }

  /// Applique un effet glassmorphism de type carte
  Widget glassmorphismCard({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismVariants.card(
      padding: padding,
      margin: margin,
      child: this,
    );
  }

  /// Applique un effet glassmorphism de type modale
  Widget glassmorphismModal({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GlassmorphismVariants.modal(
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}
