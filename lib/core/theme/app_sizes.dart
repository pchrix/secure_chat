/// 📐 AppSizes - Design Tokens pour les tailles de composants
/// 
/// Système de tailles cohérent pour tous les composants UI
/// Basé sur les meilleures pratiques d'accessibilité et d'ergonomie
/// 
/// Usage:
/// ```dart
/// Container(
///   height: AppSizes.buttonHeight,
///   width: AppSizes.buttonMinWidth,
///   child: Text('Button'),
/// )
/// ```

import 'package:flutter/material.dart';

/// Design tokens pour les tailles de composants de l'application SecureChat
class AppSizes {
  // Empêche l'instanciation
  AppSizes._();

  // ========== TAILLES DE BOUTONS ==========
  
  /// Hauteur des boutons extra small
  static const double buttonHeightXs = 32.0;
  
  /// Hauteur des boutons small
  static const double buttonHeightSm = 40.0;
  
  /// Hauteur des boutons medium (standard)
  static const double buttonHeightMd = 48.0;
  
  /// Hauteur des boutons large
  static const double buttonHeightLg = 56.0;
  
  /// Hauteur des boutons extra large
  static const double buttonHeightXl = 64.0;
  
  /// Largeur minimale des boutons
  static const double buttonMinWidth = 88.0;
  
  /// Largeur des boutons icon
  static const double buttonIconSize = 48.0;

  // ========== TAILLES D'ICÔNES ==========
  
  /// Icône extra small
  static const double iconXs = 16.0;
  
  /// Icône small
  static const double iconSm = 20.0;
  
  /// Icône medium (standard)
  static const double iconMd = 24.0;
  
  /// Icône large
  static const double iconLg = 32.0;
  
  /// Icône extra large
  static const double iconXl = 40.0;
  
  /// Icône extra extra large
  static const double iconXxl = 48.0;

  // ========== TAILLES DE CHAMPS DE TEXTE ==========
  
  /// Hauteur des champs de texte small
  static const double inputHeightSm = 40.0;
  
  /// Hauteur des champs de texte medium
  static const double inputHeightMd = 48.0;
  
  /// Hauteur des champs de texte large
  static const double inputHeightLg = 56.0;
  
  /// Hauteur minimale des text areas
  static const double textAreaMinHeight = 80.0;

  // ========== TAILLES D'AVATARS ==========
  
  /// Avatar extra small
  static const double avatarXs = 24.0;
  
  /// Avatar small
  static const double avatarSm = 32.0;
  
  /// Avatar medium
  static const double avatarMd = 40.0;
  
  /// Avatar large
  static const double avatarLg = 56.0;
  
  /// Avatar extra large
  static const double avatarXl = 80.0;
  
  /// Avatar extra extra large
  static const double avatarXxl = 120.0;

  // ========== TAILLES DE CARTES ==========
  
  /// Hauteur minimale des cartes
  static const double cardMinHeight = 80.0;
  
  /// Largeur maximale des cartes
  static const double cardMaxWidth = 400.0;
  
  /// Hauteur des cartes compactes
  static const double cardCompactHeight = 60.0;
  
  /// Hauteur des cartes standard
  static const double cardStandardHeight = 120.0;
  
  /// Hauteur des cartes étendues
  static const double cardExpandedHeight = 200.0;

  // ========== TAILLES DE CONTENEURS ==========
  
  /// Largeur maximale du contenu principal
  static const double maxContentWidth = 1200.0;
  
  /// Largeur maximale des modals
  static const double maxModalWidth = 600.0;
  
  /// Hauteur maximale des modals
  static const double maxModalHeight = 800.0;
  
  /// Largeur des sidebars
  static const double sidebarWidth = 280.0;
  
  /// Largeur des sidebars compactes
  static const double sidebarCompactWidth = 72.0;

  // ========== TAILLES DE NAVIGATION ==========
  
  /// Hauteur de l'app bar
  static const double appBarHeight = 56.0;
  
  /// Hauteur de l'app bar large
  static const double appBarLargeHeight = 112.0;
  
  /// Hauteur de la bottom navigation
  static const double bottomNavHeight = 80.0;
  
  /// Hauteur des tabs
  static const double tabHeight = 48.0;

  // ========== TAILLES RESPONSIVE ==========
  
  /// Largeur minimale pour mobile
  static const double mobileMinWidth = 320.0;
  
  /// Largeur maximale pour mobile
  static const double mobileMaxWidth = 480.0;
  
  /// Largeur minimale pour tablet
  static const double tabletMinWidth = 768.0;
  
  /// Largeur minimale pour desktop
  static const double desktopMinWidth = 1024.0;

  // ========== TAILLES D'ACCESSIBILITÉ ==========
  
  /// Taille minimale des zones tactiles (iOS)
  static const double minTouchTargetSize = 44.0;
  
  /// Taille minimale des zones tactiles (Android)
  static const double minTouchTargetSizeAndroid = 48.0;
  
  /// Taille recommandée des zones tactiles
  static const double recommendedTouchTargetSize = 48.0;

  // ========== RAYONS DE BORDURE ==========
  
  /// Rayon extra small
  static const double radiusXs = 4.0;
  
  /// Rayon small
  static const double radiusSm = 8.0;
  
  /// Rayon medium
  static const double radiusMd = 12.0;
  
  /// Rayon large
  static const double radiusLg = 16.0;
  
  /// Rayon extra large
  static const double radiusXl = 24.0;
  
  /// Rayon circulaire
  static const double radiusCircular = 999.0;

  // ========== ÉPAISSEURS DE BORDURE ==========
  
  /// Bordure fine
  static const double borderThin = 1.0;
  
  /// Bordure medium
  static const double borderMedium = 2.0;
  
  /// Bordure épaisse
  static const double borderThick = 4.0;

  // ========== ÉLÉVATIONS ==========
  
  /// Élévation nulle
  static const double elevationNone = 0.0;
  
  /// Élévation small
  static const double elevationSm = 2.0;
  
  /// Élévation medium
  static const double elevationMd = 4.0;
  
  /// Élévation large
  static const double elevationLg = 8.0;
  
  /// Élévation extra large
  static const double elevationXl = 16.0;

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient la taille de bouton responsive
  static double getResponsiveButtonHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 480) {
      return buttonHeightMd;
    } else if (width < 768) {
      return buttonHeightLg;
    } else {
      return buttonHeightXl;
    }
  }
  
  /// Obtient la taille d'icône responsive
  static double getResponsiveIconSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 480) {
      return iconMd;
    } else if (width < 768) {
      return iconLg;
    } else {
      return iconXl;
    }
  }
  
  /// Obtient la taille d'avatar responsive
  static double getResponsiveAvatarSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 480) {
      return avatarMd;
    } else if (width < 768) {
      return avatarLg;
    } else {
      return avatarXl;
    }
  }
  
  /// Obtient la largeur maximale du contenu responsive
  static double getResponsiveContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 768) {
      return width * 0.9;
    } else if (width < 1024) {
      return width * 0.8;
    } else {
      return maxContentWidth;
    }
  }
  
  /// Obtient le rayon de bordure responsive
  static double getResponsiveBorderRadius(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 480) {
      return radiusSm;
    } else if (width < 768) {
      return radiusMd;
    } else {
      return radiusLg;
    }
  }

  // ========== CONSTANTES PRÉDÉFINIES ==========
  
  /// BorderRadius pour les boutons
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(radiusMd));
  
  /// BorderRadius pour les cartes
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusLg));
  
  /// BorderRadius pour les champs de texte
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(radiusSm));
  
  /// BorderRadius pour les modals
  static const BorderRadius modalRadius = BorderRadius.all(Radius.circular(radiusXl));
  
  /// BorderRadius circulaire
  static const BorderRadius circularRadius = BorderRadius.all(Radius.circular(radiusCircular));

  // ========== CONTRAINTES DE TAILLE ==========
  
  /// Contraintes pour les boutons
  static const BoxConstraints buttonConstraints = BoxConstraints(
    minHeight: buttonHeightMd,
    minWidth: buttonMinWidth,
  );
  
  /// Contraintes pour les champs de texte
  static const BoxConstraints inputConstraints = BoxConstraints(
    minHeight: inputHeightMd,
  );
  
  /// Contraintes pour les cartes
  static const BoxConstraints cardConstraints = BoxConstraints(
    minHeight: cardMinHeight,
    maxWidth: cardMaxWidth,
  );
  
  /// Contraintes pour les modals
  static const BoxConstraints modalConstraints = BoxConstraints(
    maxWidth: maxModalWidth,
    maxHeight: maxModalHeight,
  );
}
