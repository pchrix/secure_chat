import 'package:flutter/material.dart';

/// Gestionnaire centralisé des animations pour optimiser les performances
class AnimationManager {
  static final AnimationManager _instance = AnimationManager._internal();
  factory AnimationManager() => _instance;
  AnimationManager._internal();

  // Configuration globale des animations
  static bool _animationsEnabled = true;
  static bool _reduceMotion = false;
  static double _globalAnimationSpeed = 1.0;

  // Registre des contrôleurs actifs pour optimisation
  final Set<AnimationController> _activeControllers = {};

  /// Initialiser le gestionnaire avec les préférences système
  static void initialize() {
    try {
      // Détecter les préférences d'accessibilité de manière sécurisée
      _reduceMotion = WidgetsBinding
          .instance.platformDispatcher.accessibilityFeatures.reduceMotion;
    } catch (e) {
      // Fallback sûr si l'accès aux accessibilityFeatures échoue
      _reduceMotion = false;
      debugPrint(
          'AnimationManager: Impossible d\'accéder aux préférences d\'accessibilité: $e');
    }

    // Ajuster la vitesse selon les performances
    _globalAnimationSpeed = _reduceMotion ? 0.5 : 1.0;
  }

  /// Enregistrer un contrôleur d'animation
  void registerController(AnimationController controller) {
    _activeControllers.add(controller);
  }

  /// Désenregistrer un contrôleur d'animation
  void unregisterController(AnimationController controller) {
    _activeControllers.remove(controller);
  }

  /// Obtenir la durée optimisée selon les préférences
  static Duration getOptimizedDuration(Duration baseDuration) {
    if (!_animationsEnabled || _reduceMotion) {
      return Duration(
          milliseconds: (baseDuration.inMilliseconds * 0.3).round());
    }
    return Duration(
        milliseconds:
            (baseDuration.inMilliseconds * _globalAnimationSpeed).round());
  }

  /// Obtenir la courbe optimisée selon les performances
  static Curve getOptimizedCurve(Curve baseCurve) {
    if (_reduceMotion) {
      return Curves.linear;
    }
    return baseCurve;
  }

  /// Vérifier si les animations doivent être activées
  static bool shouldAnimate() {
    return _animationsEnabled && !_reduceMotion;
  }

  /// Activer/désactiver les animations globalement
  static void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
  }

  /// Définir la vitesse globale des animations
  static void setGlobalSpeed(double speed) {
    _globalAnimationSpeed = speed.clamp(0.1, 3.0);
  }

  /// Obtenir le nombre de contrôleurs actifs (pour debug)
  int get activeControllersCount => _activeControllers.length;

  /// Nettoyer les contrôleurs disposés
  void cleanup() {
    _activeControllers.removeWhere((controller) => !controller.isAnimating);
  }

  /// Pauser toutes les animations actives
  void pauseAll() {
    for (final controller in _activeControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
  }

  /// Reprendre toutes les animations
  void resumeAll() {
    for (final controller in _activeControllers) {
      if (!controller.isAnimating && controller.value < 1.0) {
        controller.forward();
      }
    }
  }
}

/// Widget wrapper pour optimiser automatiquement les animations
class OptimizedAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool autoStart;

  const OptimizedAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.autoStart = true,
  });

  @override
  State<OptimizedAnimation> createState() => _OptimizedAnimationState();
}

class _OptimizedAnimationState extends State<OptimizedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final optimizedDuration =
        AnimationManager.getOptimizedDuration(widget.duration);
    final optimizedCurve = AnimationManager.getOptimizedCurve(widget.curve);

    _controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: optimizedCurve),
    );

    // Enregistrer le contrôleur
    AnimationManager().registerController(_controller);

    if (widget.autoStart && AnimationManager.shouldAnimate()) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    AnimationManager().unregisterController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AnimationManager.shouldAnimate()) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Mixin pour optimiser les animations dans les widgets
mixin OptimizedAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final List<AnimationController> _controllers = [];

  /// Créer un contrôleur optimisé
  AnimationController createOptimizedController({
    required Duration duration,
    String? debugLabel,
  }) {
    final optimizedDuration = AnimationManager.getOptimizedDuration(duration);
    final controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
      debugLabel: debugLabel,
    );

    _controllers.add(controller);
    AnimationManager().registerController(controller);
    return controller;
  }

  /// Créer une animation optimisée
  Animation<U> createOptimizedAnimation<U>({
    required AnimationController controller,
    required Tween<U> tween,
    Curve curve = Curves.easeInOut,
  }) {
    final optimizedCurve = AnimationManager.getOptimizedCurve(curve);
    return tween.animate(
      CurvedAnimation(parent: controller, curve: optimizedCurve),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      AnimationManager().unregisterController(controller);
      controller.dispose();
    }
    super.dispose();
  }
}

/// Utilitaires pour les animations responsives
class ResponsiveAnimations {
  /// Obtenir une durée responsive selon la taille d'écran
  static Duration getResponsiveDuration(
    BuildContext context, {
    Duration mobile = const Duration(milliseconds: 300),
    Duration tablet = const Duration(milliseconds: 400),
    Duration desktop = const Duration(milliseconds: 500),
  }) {
    final width = MediaQuery.of(context).size.width;
    Duration baseDuration;

    if (width < 600) {
      baseDuration = mobile;
    } else if (width < 900) {
      baseDuration = tablet;
    } else {
      baseDuration = desktop;
    }

    return AnimationManager.getOptimizedDuration(baseDuration);
  }

  /// Obtenir un délai responsive pour les animations en cascade
  static Duration getResponsiveDelay(BuildContext context, int index) {
    final width = MediaQuery.of(context).size.width;
    final baseDelay = width < 600 ? 50 : (width < 900 ? 75 : 100);

    return Duration(milliseconds: index * baseDelay);
  }
}

/// Widget pour animations en cascade optimisées
class OptimizedStaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration duration;
  final Curve curve;

  const OptimizedStaggeredAnimation({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    if (!AnimationManager.shouldAnimate()) {
      return Column(children: children);
    }

    return Column(
      children: children.map((child) {
        return OptimizedAnimation(
          duration: duration,
          curve: curve,
          child: child,
        );
      }).toList(),
    );
  }
}
