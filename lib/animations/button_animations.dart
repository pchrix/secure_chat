import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_manager.dart';

/// Animation de pression pour les boutons avec feedback haptique
class ButtonPressAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressScale;
  final bool enableHaptic;
  final bool enableRipple;

  const ButtonPressAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.pressScale = 0.95,
    this.enableHaptic = true,
    this.enableRipple = true,
  });

  @override
  State<ButtonPressAnimation> createState() => _ButtonPressAnimationState();
}

class _ButtonPressAnimationState extends State<ButtonPressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    final optimizedDuration =
        AnimationManager.getOptimizedDuration(widget.duration);
    _controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    AnimationManager().registerController(_controller);
  }

  @override
  void dispose() {
    AnimationManager().unregisterController(_controller);
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!AnimationManager.shouldAnimate()) return;

    _controller.forward();

    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (!mounted) return;

    _controller.reverse();

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animation de hover pour les boutons (desktop)
class ButtonHoverAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double hoverScale;
  final Color? hoverColor;
  final double elevation;

  const ButtonHoverAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.hoverScale = 1.05,
    this.hoverColor,
    this.elevation = 8.0,
  });

  @override
  State<ButtonHoverAnimation> createState() => _ButtonHoverAnimationState();
}

class _ButtonHoverAnimationState extends State<ButtonHoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();

    final optimizedDuration =
        AnimationManager.getOptimizedDuration(widget.duration);
    _controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.elevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    AnimationManager().registerController(_controller);
  }

  @override
  void dispose() {
    AnimationManager().unregisterController(_controller);
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    if (!AnimationManager.shouldAnimate()) return;

    _controller.forward();
  }

  void _onExit(PointerExitEvent event) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Animation de succès pour les boutons
class ButtonSuccessAnimation extends StatefulWidget {
  final Widget child;
  final Widget successChild;
  final Duration duration;
  final bool showSuccess;
  final VoidCallback? onComplete;

  const ButtonSuccessAnimation({
    super.key,
    required this.child,
    required this.successChild,
    this.duration = const Duration(milliseconds: 800),
    this.showSuccess = false,
    this.onComplete,
  });

  @override
  State<ButtonSuccessAnimation> createState() => _ButtonSuccessAnimationState();
}

class _ButtonSuccessAnimationState extends State<ButtonSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final optimizedDuration =
        AnimationManager.getOptimizedDuration(widget.duration);
    _controller = AnimationController(
      duration: optimizedDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    AnimationManager().registerController(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void didUpdateWidget(ButtonSuccessAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showSuccess && !oldWidget.showSuccess) {
      _controller.forward();
    } else if (!widget.showSuccess && oldWidget.showSuccess) {
      _controller.reverse();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Widget original
              Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child: widget.child,
              ),
              // Widget de succès
              Opacity(
                opacity: _fadeAnimation.value,
                child: widget.successChild,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animation de chargement pour les boutons
class ButtonLoadingAnimation extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? loadingColor;
  final double size;

  const ButtonLoadingAnimation({
    super.key,
    required this.child,
    this.isLoading = false,
    this.loadingColor,
    this.size = 20.0,
  });

  @override
  State<ButtonLoadingAnimation> createState() => _ButtonLoadingAnimationState();
}

class _ButtonLoadingAnimationState extends State<ButtonLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    AnimationManager().registerController(_controller);

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ButtonLoadingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Contenu original
        AnimatedOpacity(
          opacity: widget.isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: widget.child,
        ),
        // Indicateur de chargement
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.loadingColor ?? Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
