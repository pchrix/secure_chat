/// 🔘 AuthButton - Bouton personnalisé pour l'authentification
///
/// Widget de bouton avec design glassmorphism et états de chargement.
/// Optimisé pour les actions d'authentification.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../utils/responsive_builder.dart';

/// Bouton personnalisé pour l'authentification
class AuthButton extends StatefulWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = AppSizes.buttonHeightMd,
    this.style = AuthButtonStyle.primary,
    this.icon,
    this.loadingText,
  });

  /// Texte du bouton
  final String text;

  /// Callback lors du clic
  final VoidCallback? onPressed;

  /// État de chargement
  final bool isLoading;

  /// Bouton activé
  final bool isEnabled;

  /// Largeur du bouton
  final double? width;

  /// Hauteur du bouton (utilise AppSizes.buttonHeightMd par défaut)
  final double height;

  /// Style du bouton
  final AuthButtonStyle style;

  /// Icône optionnelle
  final IconData? icon;

  /// Texte affiché pendant le chargement
  final String? loadingText;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canPress =>
      widget.isEnabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildButton(responsive),
            );
          },
        );
      },
    );
  }

  Widget _buildButton(ResponsiveInfo responsive) {
    // Calculer la largeur responsive
    double? effectiveWidth = widget.width;
    if (effectiveWidth == null) {
      effectiveWidth = responsive.isDesktop
          ? math.min(AppSizes.cardMaxWidth, responsive.availableWidth * 0.8)
          : responsive.availableWidth;
    }

    // Calculer la hauteur responsive basée sur les design tokens
    double effectiveHeight = widget.height;

    return GestureDetector(
      onTapDown: _canPress ? (_) => _onTapDown() : null,
      onTapUp: _canPress ? (_) => _onTapUp() : null,
      onTapCancel: _canPress ? () => _onTapCancel() : null,
      onTap: _canPress ? _onTap : null,
      child: Container(
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: _buildDecoration(),
        child: _buildContent(),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final colors = _getColors();

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.primary,
          colors.secondary,
        ],
      ),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      boxShadow: _canPress
          ? [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 12.0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Center(
        child:
            widget.isLoading ? _buildLoadingContent() : _buildNormalContent(),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSizes.iconSm,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTextColor(),
            ),
          ),
        ),
        if (widget.loadingText != null) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.loadingText!,
              style: AppTheme.bodyMedium.copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNormalContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _getTextColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: AppTheme.bodyMedium.copyWith(
              color: _getTextColor(),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  _ButtonColors _getColors() {
    switch (widget.style) {
      case AuthButtonStyle.primary:
        return _canPress
            ? _ButtonColors(
                primary: AppTheme.primaryColor,
                secondary: AppTheme.accentColor,
              )
            : _ButtonColors(
                primary: AppTheme.disabledColor,
                secondary: AppTheme.disabledColor.withValues(alpha: 0.8),
              );
      case AuthButtonStyle.secondary:
        return _canPress
            ? _ButtonColors(
                primary: AppTheme.secondaryColor,
                secondary: AppTheme.primaryColor.withValues(alpha: 0.8),
              )
            : _ButtonColors(
                primary: AppTheme.disabledColor,
                secondary: AppTheme.disabledColor.withValues(alpha: 0.8),
              );
      case AuthButtonStyle.outline:
        return _ButtonColors(
          primary: Colors.transparent,
          secondary: Colors.transparent,
        );
      case AuthButtonStyle.text:
        return _ButtonColors(
          primary: Colors.transparent,
          secondary: Colors.transparent,
        );
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case AuthButtonStyle.primary:
      case AuthButtonStyle.secondary:
        return _canPress ? Colors.white : AppTheme.textSecondaryColor;
      case AuthButtonStyle.outline:
      case AuthButtonStyle.text:
        return _canPress ? AppTheme.primaryColor : AppTheme.textSecondaryColor;
    }
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTap() {
    widget.onPressed?.call();
  }
}

/// Styles de bouton disponibles
enum AuthButtonStyle {
  primary,
  secondary,
  outline,
  text,
}

/// Couleurs du bouton
class _ButtonColors {
  final Color primary;
  final Color secondary;

  const _ButtonColors({
    required this.primary,
    required this.secondary,
  });
}

/// Variantes prédéfinies d'AuthButton
class AuthButtonVariants {
  /// Bouton principal
  static Widget primary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    String? loadingText,
    double? width,
  }) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AuthButtonStyle.primary,
      icon: icon,
      loadingText: loadingText,
      width: width,
    );
  }

  /// Bouton secondaire
  static Widget secondary({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    String? loadingText,
    double? width,
  }) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AuthButtonStyle.secondary,
      icon: icon,
      loadingText: loadingText,
      width: width,
    );
  }

  /// Bouton avec contour
  static Widget outline({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    String? loadingText,
    double? width,
  }) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AuthButtonStyle.outline,
      icon: icon,
      loadingText: loadingText,
      width: width,
    );
  }

  /// Bouton texte
  static Widget text({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    String? loadingText,
    double? width,
  }) {
    return AuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      style: AuthButtonStyle.text,
      icon: icon,
      loadingText: loadingText,
      width: width,
    );
  }
}
