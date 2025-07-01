/// 📏 AppSpacing - Design Tokens pour les espacements
/// 
/// Système d'espacement cohérent basé sur une échelle de 4px
/// Inspiré des meilleures pratiques Material Design et Moon Design System
/// 
/// Usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: Text('Hello'),
/// )
/// ```

import 'package:flutter/material.dart';

/// Design tokens pour les espacements de l'application SecureChat
class AppSpacing {
  // Empêche l'instanciation
  AppSpacing._();

  // ========== ESPACEMENTS DE BASE ==========
  
  /// Extra small - 4px
  static const double xs = 4.0;
  
  /// Small - 8px  
  static const double sm = 8.0;
  
  /// Medium - 16px (base)
  static const double md = 16.0;
  
  /// Large - 24px
  static const double lg = 24.0;
  
  /// Extra large - 32px
  static const double xl = 32.0;
  
  /// Extra extra large - 48px
  static const double xxl = 48.0;
  
  /// Extra extra extra large - 64px
  static const double xxxl = 64.0;

  // ========== ESPACEMENTS SPÉCIALISÉS ==========
  
  /// Espacement pour les cartes et conteneurs
  static const double cardPadding = md;
  
  /// Espacement entre les sections
  static const double sectionSpacing = lg;
  
  /// Espacement pour les boutons
  static const double buttonPadding = md;
  
  /// Espacement pour les champs de texte
  static const double inputPadding = md;
  
  /// Espacement pour les listes
  static const double listItemSpacing = sm;
  
  /// Espacement pour les icônes
  static const double iconSpacing = sm;

  // ========== ESPACEMENTS RESPONSIVE ==========
  
  /// Espacement mobile (petits écrans)
  static const double mobilePadding = md;
  
  /// Espacement tablet (écrans moyens)
  static const double tabletPadding = lg;
  
  /// Espacement desktop (grands écrans)
  static const double desktopPadding = xl;

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient l'espacement responsive basé sur la largeur d'écran
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < 600) {
      return mobilePadding;
    } else if (screenWidth < 1024) {
      return tabletPadding;
    } else {
      return desktopPadding;
    }
  }
  
  /// Obtient l'espacement responsive via BuildContext
  static double getResponsivePaddingFromContext(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return getResponsivePadding(screenWidth);
  }
  
  /// EdgeInsets symétriques avec espacement responsive
  static EdgeInsets getResponsiveSymmetric(BuildContext context) {
    final padding = getResponsivePaddingFromContext(context);
    return EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.75);
  }
  
  /// EdgeInsets horizontaux avec espacement responsive
  static EdgeInsets getResponsiveHorizontal(BuildContext context) {
    final padding = getResponsivePaddingFromContext(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }
  
  /// EdgeInsets verticaux avec espacement responsive
  static EdgeInsets getResponsiveVertical(BuildContext context) {
    final padding = getResponsivePaddingFromContext(context);
    return EdgeInsets.symmetric(vertical: padding * 0.75);
  }

  // ========== ESPACEMENTS PRÉDÉFINIS ==========
  
  /// EdgeInsets pour les cartes
  static const EdgeInsets card = EdgeInsets.all(cardPadding);
  
  /// EdgeInsets pour les boutons
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: buttonPadding,
    vertical: sm,
  );
  
  /// EdgeInsets pour les champs de texte
  static const EdgeInsets input = EdgeInsets.all(inputPadding);
  
  /// EdgeInsets pour les éléments de liste
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: listItemSpacing,
  );
  
  /// EdgeInsets pour les pages
  static const EdgeInsets page = EdgeInsets.all(md);
  
  /// EdgeInsets pour les sections
  static const EdgeInsets section = EdgeInsets.symmetric(
    vertical: sectionSpacing,
  );

  // ========== CONSTANTES POUR LES GAPS ==========
  
  /// Gap extra small
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  
  /// Gap small
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  
  /// Gap medium
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  
  /// Gap large
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  
  /// Gap extra large
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  
  /// Gap extra extra large
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);

  // ========== GAPS DIRECTIONNELS ==========
  
  /// Gap vertical extra small
  static const SizedBox vGapXs = SizedBox(height: xs);
  
  /// Gap vertical small
  static const SizedBox vGapSm = SizedBox(height: sm);
  
  /// Gap vertical medium
  static const SizedBox vGapMd = SizedBox(height: md);
  
  /// Gap vertical large
  static const SizedBox vGapLg = SizedBox(height: lg);
  
  /// Gap vertical extra large
  static const SizedBox vGapXl = SizedBox(height: xl);
  
  /// Gap horizontal extra small
  static const SizedBox hGapXs = SizedBox(width: xs);
  
  /// Gap horizontal small
  static const SizedBox hGapSm = SizedBox(width: sm);
  
  /// Gap horizontal medium
  static const SizedBox hGapMd = SizedBox(width: md);
  
  /// Gap horizontal large
  static const SizedBox hGapLg = SizedBox(width: lg);
  
  /// Gap horizontal extra large
  static const SizedBox hGapXl = SizedBox(width: xl);
}
