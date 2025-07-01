/// ⏳ AuthLoadingOverlay - Overlay de chargement pour l'authentification
/// 
/// Widget d'overlay avec effet glassmorphism pour indiquer les opérations
/// d'authentification en cours.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../../core/theme/app_theme.dart';
import 'glassmorphism_container.dart';

/// Overlay de chargement pour l'authentification
class AuthLoadingOverlay extends StatefulWidget {
  const AuthLoadingOverlay({
    super.key,
    this.message = 'Chargement...',
    this.showMessage = true,
    this.backgroundColor,
    this.blurSigma = 5.0,
  });

  /// Message à afficher
  final String message;

  /// Afficher le message
  final bool showMessage;

  /// Couleur d'arrière-plan
  final Color? backgroundColor;

  /// Intensité du flou
  final double blurSigma;

  @override
  State<AuthLoadingOverlay> createState() => _AuthLoadingOverlayState();
}

class _AuthLoadingOverlayState extends State<AuthLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeController.forward();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildOverlay(),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurSigma,
          sigmaY: widget.blurSigma,
        ),
        child: Container(
          color: widget.backgroundColor ??
                 Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: _buildLoadingContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return GlassmorphismVariants.modal(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de chargement personnalisé
          _buildCustomLoader(),
          
          if (widget.showMessage) ...[
            const AppSpacing.vGapLg,
            Text(
              widget.message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomLoader() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.accentColor,
                  AppTheme.secondaryColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.security,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Variantes prédéfinies d'AuthLoadingOverlay
class AuthLoadingOverlayVariants {
  /// Overlay pour la connexion
  static Widget signIn() {
    return const AuthLoadingOverlay(
      message: 'Connexion en cours...',
    );
  }

  /// Overlay pour l'inscription
  static Widget signUp() {
    return const AuthLoadingOverlay(
      message: 'Création du compte...',
    );
  }

  /// Overlay pour la déconnexion
  static Widget signOut() {
    return const AuthLoadingOverlay(
      message: 'Déconnexion...',
    );
  }

  /// Overlay pour la vérification PIN
  static Widget verifyPin() {
    return const AuthLoadingOverlay(
      message: 'Vérification du PIN...',
    );
  }

  /// Overlay pour la configuration PIN
  static Widget setupPin() {
    return const AuthLoadingOverlay(
      message: 'Configuration du PIN...',
    );
  }

  /// Overlay pour la récupération de mot de passe
  static Widget resetPassword() {
    return const AuthLoadingOverlay(
      message: 'Envoi de l\'email...',
    );
  }

  /// Overlay minimal sans message
  static Widget minimal() {
    return const AuthLoadingOverlay(
      showMessage: false,
      blurSigma: 3.0,
    );
  }
}

/// Extension pour faciliter l'utilisation des overlays
extension AuthLoadingOverlayExtension on Widget {
  /// Ajoute un overlay de chargement conditionnel
  Widget withLoadingOverlay({
    required bool isLoading,
    String message = 'Chargement...',
    bool showMessage = true,
    Color? backgroundColor,
    double blurSigma = 5.0,
  }) {
    return Stack(
      children: [
        this,
        if (isLoading)
          AuthLoadingOverlay(
            message: message,
            showMessage: showMessage,
            backgroundColor: backgroundColor,
            blurSigma: blurSigma,
          ),
      ],
    );
  }

  /// Ajoute un overlay de chargement pour la connexion
  Widget withSignInLoading(bool isLoading) {
    return Stack(
      children: [
        this,
        if (isLoading) AuthLoadingOverlayVariants.signIn(),
      ],
    );
  }

  /// Ajoute un overlay de chargement pour l'inscription
  Widget withSignUpLoading(bool isLoading) {
    return Stack(
      children: [
        this,
        if (isLoading) AuthLoadingOverlayVariants.signUp(),
      ],
    );
  }

  /// Ajoute un overlay de chargement minimal
  Widget withMinimalLoading(bool isLoading) {
    return Stack(
      children: [
        this,
        if (isLoading) AuthLoadingOverlayVariants.minimal(),
      ],
    );
  }
}

/// Gestionnaire d'overlay de chargement global
class AuthLoadingManager {
  static OverlayEntry? _currentOverlay;

  /// Affiche un overlay de chargement
  static void show(
    BuildContext context, {
    String message = 'Chargement...',
    bool showMessage = true,
    Color? backgroundColor,
    double blurSigma = 5.0,
  }) {
    hide(); // Masque l'overlay existant s'il y en a un

    _currentOverlay = OverlayEntry(
      builder: (context) => AuthLoadingOverlay(
        message: message,
        showMessage: showMessage,
        backgroundColor: backgroundColor,
        blurSigma: blurSigma,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Masque l'overlay de chargement
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Affiche un overlay pour la connexion
  static void showSignIn(BuildContext context) {
    show(context, message: 'Connexion en cours...');
  }

  /// Affiche un overlay pour l'inscription
  static void showSignUp(BuildContext context) {
    show(context, message: 'Création du compte...');
  }

  /// Affiche un overlay pour la déconnexion
  static void showSignOut(BuildContext context) {
    show(context, message: 'Déconnexion...');
  }
}
