/// 📱 AppBreakpoints - Design Tokens pour les points de rupture responsive
/// 
/// Système de breakpoints cohérent pour le design responsive
/// Basé sur les meilleures pratiques Flutter et les standards de l'industrie
/// 
/// Usage:
/// ```dart
/// if (AppBreakpoints.isMobile(context)) {
///   return MobileLayout();
/// }
/// ```

import 'package:flutter/material.dart';

/// Design tokens pour les breakpoints responsive de l'application SecureChat
class AppBreakpoints {
  // Empêche l'instanciation
  AppBreakpoints._();

  // ========== BREAKPOINTS PRINCIPAUX ==========
  
  /// Breakpoint mobile - 480px
  /// Couvre les smartphones en portrait
  static const double mobile = 480.0;
  
  /// Breakpoint tablet - 768px  
  /// Couvre les tablettes et smartphones en paysage
  static const double tablet = 768.0;
  
  /// Breakpoint desktop - 1024px
  /// Couvre les ordinateurs portables et de bureau
  static const double desktop = 1024.0;
  
  /// Breakpoint large desktop - 1440px
  /// Couvre les grands écrans et moniteurs
  static const double largeDesktop = 1440.0;

  // ========== BREAKPOINTS SPÉCIALISÉS ==========
  
  /// Breakpoint pour très petits écrans (iPhone SE)
  static const double verySmall = 320.0;
  
  /// Breakpoint pour petits écrans compacts
  static const double small = 375.0;
  
  /// Breakpoint pour écrans moyens
  static const double medium = 414.0;
  
  /// Breakpoint pour grands smartphones
  static const double large = 480.0;
  
  /// Breakpoint pour tablettes compactes
  static const double tabletCompact = 600.0;
  
  /// Breakpoint pour tablettes standard
  static const double tabletStandard = 768.0;
  
  /// Breakpoint pour tablettes larges
  static const double tabletLarge = 900.0;

  // ========== BREAKPOINTS DE HAUTEUR ==========
  
  /// Hauteur très compacte (iPhone SE)
  static const double veryCompactHeight = 700.0;
  
  /// Hauteur compacte (iPhone standard)
  static const double compactHeight = 800.0;
  
  /// Hauteur normale
  static const double normalHeight = 900.0;
  
  /// Hauteur large
  static const double largeHeight = 1000.0;

  // ========== MÉTHODES DE DÉTECTION ==========
  
  /// Vérifie si l'écran est très petit (iPhone SE)
  static bool isVerySmall(BuildContext context) {
    return MediaQuery.sizeOf(context).width < verySmall;
  }
  
  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobile;
  }
  
  /// Vérifie si l'écran est tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < desktop;
  }
  
  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktop;
  }
  
  /// Vérifie si l'écran est large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= largeDesktop;
  }

  // ========== MÉTHODES DE HAUTEUR ==========
  
  /// Vérifie si la hauteur est très compacte
  static bool isVeryCompactHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < veryCompactHeight;
  }
  
  /// Vérifie si la hauteur est compacte
  static bool isCompactHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < compactHeight;
  }
  
  /// Vérifie si la hauteur est normale
  static bool isNormalHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return height >= compactHeight && height < largeHeight;
  }
  
  /// Vérifie si la hauteur est large
  static bool isLargeHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height >= largeHeight;
  }

  // ========== MÉTHODES UTILITAIRES ==========
  
  /// Obtient le type d'appareil basé sur la largeur
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    
    if (width < mobile) {
      return DeviceType.mobile;
    } else if (width < desktop) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Obtient la taille d'écran basée sur la largeur et hauteur
  static ScreenSize getScreenSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    
    if (width < verySmall || height < veryCompactHeight) {
      return ScreenSize.verySmall;
    } else if (width < mobile) {
      return ScreenSize.small;
    } else if (width < tablet) {
      return ScreenSize.medium;
    } else if (width < desktop) {
      return ScreenSize.large;
    } else {
      return ScreenSize.veryLarge;
    }
  }
  
  /// Obtient une valeur responsive basée sur le type d'appareil
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    
    if (width >= AppBreakpoints.largeDesktop && largeDesktop != null) {
      return largeDesktop;
    } else if (width >= AppBreakpoints.desktop && desktop != null) {
      return desktop;
    } else if (width >= AppBreakpoints.mobile && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
  
  /// Obtient le nombre de colonnes responsive pour une grille
  static int getResponsiveColumns(BuildContext context) {
    return getResponsiveValue<int>(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }
  
  /// Obtient la largeur maximale du contenu
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue<double>(
      context,
      mobile: double.infinity,
      tablet: 600.0,
      desktop: 800.0,
      largeDesktop: 1200.0,
    );
  }
}

/// Énumération des types d'appareils
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Énumération des tailles d'écran
enum ScreenSize {
  verySmall,
  small,
  medium,
  large,
  veryLarge,
}

/// Extension pour faciliter l'usage des breakpoints
extension AppBreakpointsExtension on BuildContext {
  /// Vérifie si l'écran est mobile
  bool get isMobile => AppBreakpoints.isMobile(this);
  
  /// Vérifie si l'écran est tablet
  bool get isTablet => AppBreakpoints.isTablet(this);
  
  /// Vérifie si l'écran est desktop
  bool get isDesktop => AppBreakpoints.isDesktop(this);
  
  /// Obtient le type d'appareil
  DeviceType get deviceType => AppBreakpoints.getDeviceType(this);
  
  /// Obtient la taille d'écran
  ScreenSize get screenSize => AppBreakpoints.getScreenSize(this);
  
  /// Obtient une valeur responsive
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) => AppBreakpoints.getResponsiveValue<T>(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    largeDesktop: largeDesktop,
  );
}
