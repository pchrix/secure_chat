import 'package:flutter/material.dart';
import 'animation_manager.dart';

/// Transitions de pages améliorées avec optimisations
class EnhancedPageTransitions {
  /// Transition slide avec glassmorphism
  static PageRouteBuilder<T> slideWithGlass<T>({
    required Widget page,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
  }) {
    final optimizedDuration = AnimationManager.getOptimizedDuration(duration);
    final optimizedCurve = AnimationManager.getOptimizedCurve(curve);

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: optimizedDuration,
      reverseTransitionDuration: optimizedDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Offset selon la direction
        Offset begin;
        switch (direction) {
          case SlideDirection.right:
            begin = const Offset(1.0, 0.0);
            break;
          case SlideDirection.left:
            begin = const Offset(-1.0, 0.0);
            break;
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            break;
        }

        // Animation de slide
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        // Animation de fade pour la page précédente
        final fadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: optimizedCurve,
        ));

        // Animation de scale pour effet de profondeur
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        return Stack(
          children: [
            // Page précédente avec fade out
            FadeTransition(
              opacity: fadeAnimation,
              child: Transform.scale(
                scale: 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            // Nouvelle page avec slide in
            SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Transition fade avec blur
  static PageRouteBuilder<T> fadeWithBlur<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOut,
  }) {
    final optimizedDuration = AnimationManager.getOptimizedDuration(duration);
    final optimizedCurve = AnimationManager.getOptimizedCurve(curve);

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: optimizedDuration,
      reverseTransitionDuration: optimizedDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de fade
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        // Animation de blur (simulée avec opacity)
        final blurAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: optimizedCurve,
        ));

        return Stack(
          children: [
            // Page précédente avec blur
            Opacity(
              opacity: blurAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
            ),
            // Nouvelle page avec fade
            FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ],
        );
      },
    );
  }

  /// Transition scale avec rotation
  static PageRouteBuilder<T> scaleWithRotation<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
  }) {
    final optimizedDuration = AnimationManager.getOptimizedDuration(duration);
    final optimizedCurve = AnimationManager.getOptimizedCurve(curve);

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: optimizedDuration,
      reverseTransitionDuration: optimizedDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de scale
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        // Animation de rotation
        final rotationAnimation = Tween<double>(
          begin: 0.1,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  /// Transition personnalisée pour les modales
  static PageRouteBuilder<T> modalTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) {
    final optimizedDuration = AnimationManager.getOptimizedDuration(duration);
    final optimizedCurve = AnimationManager.getOptimizedCurve(curve);

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: optimizedDuration,
      reverseTransitionDuration: optimizedDuration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de slide depuis le bas
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        // Animation de fade pour le background
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: optimizedCurve,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Direction de slide pour les transitions
enum SlideDirection {
  left,
  right,
  up,
  down,
}

/// Extensions pour faciliter l'utilisation des transitions
extension EnhancedNavigationExtensions on NavigatorState {
  /// Push avec transition slide améliorée
  Future<T?> pushSlideEnhanced<T extends Object?>(
    Widget page, {
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return push<T>(
      EnhancedPageTransitions.slideWithGlass(
        page: page,
        direction: direction,
        duration: duration,
      ),
    );
  }

  /// Push avec transition fade améliorée
  Future<T?> pushFadeEnhanced<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return push<T>(
      EnhancedPageTransitions.fadeWithBlur(
        page: page,
        duration: duration,
      ),
    );
  }

  /// Push avec transition scale améliorée
  Future<T?> pushScaleEnhanced<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return push<T>(
      EnhancedPageTransitions.scaleWithRotation(
        page: page,
        duration: duration,
      ),
    );
  }

  /// Push modal avec transition améliorée
  Future<T?> pushModalEnhanced<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return push<T>(
      EnhancedPageTransitions.modalTransition(
        page: page,
        duration: duration,
      ),
    );
  }
}

/// Widget pour prévisualiser les transitions
class TransitionPreview extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const TransitionPreview({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<TransitionPreview> createState() => _TransitionPreviewState();
}

class _TransitionPreviewState extends State<TransitionPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final optimizedDuration =
        AnimationManager.getOptimizedDuration(widget.duration);
    _controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    AnimationManager().registerController(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    AnimationManager().unregisterController(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
