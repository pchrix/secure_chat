import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../utils/responsive_utils.dart';
import '../utils/accessibility_utils.dart';

/// Cache pour les filtres ImageFilter afin d'éviter les recréations coûteuses
class _FilterCache {
  static final Map<String, ImageFilter> _cache = {};

  static ImageFilter getBlurFilter(double sigmaX, double sigmaY) {
    final key = '${sigmaX}_$sigmaY';
    return _cache.putIfAbsent(
      key,
      () => ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
    );
  }
}

/// Widget unifié pour créer des effets glassmorphism modernes et performants
/// Combine les fonctionnalités de GlassContainer et EnhancedGlassContainer
class UnifiedGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurIntensity;
  final double opacity;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool enableInnerShadow;
  final bool enableBorderGlow;
  final bool enableDepthEffect;
  final bool enablePerformanceMode;

  const UnifiedGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurIntensity = 20.0,
    this.opacity = 0.16,
    this.color,
    this.border,
    this.boxShadow,
    this.gradient,
    this.enableInnerShadow = true,
    this.enableBorderGlow = true,
    this.enableDepthEffect = true,
    this.enablePerformanceMode = true,
  });

  /// Constructeur simple pour compatibilité avec GlassContainer
  const UnifiedGlassContainer.simple({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    double blur = 15.0,
    this.opacity = 0.15,
    this.color,
    this.border,
    this.boxShadow,
  })  : blurIntensity = blur,
        gradient = null,
        enableInnerShadow = false,
        enableBorderGlow = false,
        enableDepthEffect = false,
        enablePerformanceMode = true;

  /// Constructeur avancé pour compatibilité avec EnhancedGlassContainer
  const UnifiedGlassContainer.enhanced({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurIntensity = 25.0,
    this.opacity = 0.18,
    this.color,
    this.border,
    this.boxShadow,
    this.gradient,
    this.enableInnerShadow = true,
    this.enableBorderGlow = true,
    this.enableDepthEffect = true,
  }) : enablePerformanceMode = true;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveColor = color ?? GlassColors.primary;

    // OPTIMISATION PERFORMANCE : Utiliser ResponsiveUtils pour optimiser les effets glass
    final glassConfig = ResponsiveUtils.getOptimizedGlassConfig(
      context,
      baseBlur: blurIntensity,
      baseOpacity: opacity,
      enableAdvancedEffects:
          enableDepthEffect || enableInnerShadow || enableBorderGlow,
    );

    Widget containerContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: border ?? _buildDefaultBorder(),
        gradient: gradient ??
            _buildDefaultGradient(effectiveColor, glassConfig.opacity),
      ),
      child: glassConfig.enableAdvancedEffects &&
              !ResponsiveUtils.isVeryCompact(context)
          ? _buildWithEffects(effectiveRadius)
          : child, // ✅ Version simplifiée sur iPhone SE pour performance
    );

    Widget glassContent = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: _FilterCache.getBlurFilter(
          glassConfig.blurIntensity,
          glassConfig.blurIntensity,
        ),
        child: containerContent,
      ),
    );

    // ✅ Performance mode adaptatif : activation automatique sur petits écrans
    final autoPerformanceMode = enablePerformanceMode ||
        ResponsiveUtils.isVeryCompact(context) ||
        ResponsiveUtils.shouldDisableAdvancedEffects(context);

    if (autoPerformanceMode) {
      glassContent = RepaintBoundary(child: glassContent);
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow:
            boxShadow ?? _buildOptimizedShadows(effectiveColor, glassConfig),
      ),
      child: glassContent,
    );
  }

  Widget _buildWithEffects(BorderRadius radius) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Effet de profondeur arrière
          if (enableDepthEffect)
            RepaintBoundary(child: _buildDepthEffect(radius)),

          // Contenu principal
          child,

          // Highlight supérieur
          if (enableInnerShadow)
            RepaintBoundary(child: _buildInnerHighlight(radius)),
        ],
      ),
    );
  }

  /// Construit des ombres optimisées basées sur la configuration glass et les performances
  List<BoxShadow> _buildOptimizedShadows(Color baseColor, GlassConfig config) {
    List<BoxShadow> shadows = [];

    // Ombre principale - toujours présente (couche 1)
    shadows.add(
      BoxShadow(
        color: Colors.black
            .withValues(alpha: config.shadowLayers >= 1 ? 0.25 : 0.2),
        blurRadius: config.shadowLayers >= 1 ? 20 : 15,
        offset: Offset(0, config.shadowLayers >= 1 ? 8 : 6),
        spreadRadius: enableDepthEffect ? -2 : 0,
      ),
    );

    // Ombre de contact - si au moins 2 couches (iPhone standard et plus)
    if (config.shadowLayers >= 2) {
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      );
    }

    // Lueur colorée - si 3 couches et effets avancés activés (grands écrans uniquement)
    if (config.shadowLayers >= 3 &&
        enableBorderGlow &&
        config.enableAdvancedEffects) {
      shadows.add(
        BoxShadow(
          color: baseColor.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 0),
          spreadRadius: 1,
        ),
      );
    }

    return shadows;
  }

  Border _buildDefaultBorder() {
    return Border.all(
      color: Colors.white.withValues(alpha: 0.25),
      width: 1.5,
    );
  }

  Gradient _buildDefaultGradient(Color baseColor, [double? adaptiveOpacity]) {
    final effectiveOpacity = adaptiveOpacity ?? opacity;

    if (enableDepthEffect) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: effectiveOpacity * 1.5),
          baseColor.withValues(alpha: effectiveOpacity * 0.8),
          Colors.white.withValues(alpha: effectiveOpacity * 0.6),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: effectiveOpacity * 1.2),
          Colors.white.withValues(alpha: effectiveOpacity * 0.8),
        ],
      );
    }
  }

  Widget _buildDepthEffect(BorderRadius radius) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.08),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildInnerHighlight(BorderRadius radius) {
    return Positioned(
      top: 1,
      left: 1,
      right: 1,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: radius.topLeft,
            topRight: radius.topRight,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton glassmorphism unifié avec animations fluides
class UnifiedGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool enableHapticFeedback;
  final bool enableRippleEffect;
  final Duration animationDuration;
  final bool enableAdvancedEffects;

  // Propriétés d'accessibilité
  final String? semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;

  // Propriétés responsives
  final bool adaptiveSize;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;

  const UnifiedGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.color,
    this.enableHapticFeedback = true,
    this.enableRippleEffect = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.enableAdvancedEffects = true,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.adaptiveSize = false,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
  });

  /// Constructeur simple pour compatibilité avec GlassButton
  const UnifiedGlassButton.simple({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.color,
    this.enableHapticFeedback = true,
    this.semanticLabel,
    this.tooltip,
  })  : enableRippleEffect = true,
        animationDuration = const Duration(milliseconds: 100),
        enableAdvancedEffects = false,
        excludeFromSemantics = false,
        adaptiveSize = false,
        mobileWidth = null,
        tabletWidth = null,
        desktopWidth = null;

  @override
  State<UnifiedGlassButton> createState() => _UnifiedGlassButtonState();
}

class _UnifiedGlassButtonState extends State<UnifiedGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.enableAdvancedEffects ? 0.96 : 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Calculer la largeur responsive
    double? effectiveWidth = widget.width;
    if (widget.adaptiveSize) {
      effectiveWidth = ResponsiveUtils.getResponsiveWidth(
        context,
        mobile: widget.mobileWidth,
        tablet: widget.tabletWidth,
        desktop: widget.desktopWidth,
      );
    }

    // Calculer le padding responsive
    EdgeInsetsGeometry effectivePadding =
        widget.padding ?? ResponsiveUtils.getResponsivePadding(context);

    // S'assurer que la taille respecte les guidelines d'accessibilité
    double minSize = ResponsiveUtils.getMinTouchTargetSize();

    Widget button = GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: UnifiedGlassContainer(
              width: effectiveWidth,
              height: widget.height,
              padding: effectivePadding,
              borderRadius: widget.borderRadius,
              color: widget.color,
              opacity: widget.enableAdvancedEffects
                  ? 0.2 + (_glowAnimation.value * 0.1)
                  : 0.2,
              enableBorderGlow: widget.enableAdvancedEffects,
              enableDepthEffect: widget.enableAdvancedEffects,
              boxShadow: _buildButtonShadows(),
              child: widget.child,
            ),
          );
        },
      ),
    );

    // Ajouter les contraintes d'accessibilité
    button = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: button,
    );

    // Ajouter l'accessibilité
    if (!widget.excludeFromSemantics) {
      button = AccessibilityUtils.accessibleButton(
        onPressed: widget.onTap ?? () {},
        semanticLabel: widget.semanticLabel,
        tooltip: widget.tooltip,
        enabled: widget.onTap != null,
        child: button,
      );
    }

    // Ajouter le tooltip si spécifié
    if (widget.tooltip != null) {
      button = AccessibilityUtils.accessibleTooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  List<BoxShadow> _buildButtonShadows() {
    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: widget.enableAdvancedEffects
            ? 20 + (_glowAnimation.value * 10)
            : 20,
        offset: widget.enableAdvancedEffects
            ? Offset(0, 8 - (_glowAnimation.value * 2))
            : const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];

    if (widget.enableAdvancedEffects && _isPressed) {
      shadows.add(BoxShadow(
        color: (widget.color ?? GlassColors.primary)
            .withValues(alpha: 0.4 * _glowAnimation.value),
        blurRadius: 20,
        offset: const Offset(0, 0),
        spreadRadius: 2,
      ));
    }

    return shadows;
  }
}

/// Carte glassmorphism unifiée avec effets d'hover
class UnifiedGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool enableHoverEffect;
  final bool enableAdvancedEffects;

  const UnifiedGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.enableHoverEffect = true,
    this.enableAdvancedEffects = true,
  });

  /// Constructeur simple pour compatibilité avec GlassCard
  const UnifiedGlassCard.simple({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
  })  : enableHoverEffect = false,
        enableAdvancedEffects = false;

  @override
  State<UnifiedGlassCard> createState() => _UnifiedGlassCardState();
}

class _UnifiedGlassCardState extends State<UnifiedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHoverEnter() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = widget.enableAdvancedEffects
        ? _buildAdvancedCard()
        : _buildSimpleCard();

    if (widget.onTap != null) {
      Widget interactiveCard = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: cardContent,
        ),
      );

      return widget.enableHoverEffect
          ? MouseRegion(
              onEnter: (_) => _handleHoverEnter(),
              onExit: (_) => _handleHoverExit(),
              child: interactiveCard,
            )
          : interactiveCard;
    }

    return widget.enableHoverEffect
        ? MouseRegion(
            onEnter: (_) => _handleHoverEnter(),
            onExit: (_) => _handleHoverExit(),
            child: cardContent,
          )
        : cardContent;
  }

  Widget _buildAdvancedCard() {
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -2 * _hoverAnimation.value),
          child: UnifiedGlassContainer.enhanced(
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.all(20),
            margin: widget.margin,
            color: widget.color,
            opacity: 0.15 + (_hoverAnimation.value * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20 + (_hoverAnimation.value * 15),
                offset: Offset(0, 8 + (_hoverAnimation.value * 8)),
                spreadRadius: 0,
              ),
              if (_isHovered)
                BoxShadow(
                  color: (widget.color ?? GlassColors.primary)
                      .withValues(alpha: 0.2 * _hoverAnimation.value),
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                  spreadRadius: 1,
                ),
            ],
            child: widget.child,
          ),
        );
      },
    );
  }

  Widget _buildSimpleCard() {
    return UnifiedGlassContainer.simple(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(16),
      margin: widget.margin,
      color: widget.color,
      child: widget.child,
    );
  }
}

/// Alias pour compatibilité avec l'ancien GlassContainer
typedef GlassContainer = UnifiedGlassContainer;

/// Alias pour compatibilité avec l'ancien EnhancedGlassContainer
typedef EnhancedGlassContainer = UnifiedGlassContainer;

/// Alias pour compatibilité avec l'ancien GlassButton
typedef GlassButton = UnifiedGlassButton;

/// Alias pour compatibilité avec l'ancien EnhancedGlassButton
typedef EnhancedGlassButton = UnifiedGlassButton;

/// Alias pour compatibilité avec l'ancien GlassCard
typedef GlassCard = UnifiedGlassCard;

/// Alias pour compatibilité avec l'ancien EnhancedGlassCard
typedef EnhancedGlassCard = UnifiedGlassCard;
