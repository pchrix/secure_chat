import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';
import '../theme.dart';
import '../utils/responsive_utils.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool showFloatingShapes;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.showFloatingShapes = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  // ✅ OPTIMISATION: Cache la taille de l'écran pour éviter MediaQuery à chaque frame
  late Size _screenSize;

  // ✅ OPTIMISATION: Pré-calculer les valeurs pour éviter calculs répétés
  static const double _twoPi = 2 * pi;

  @override
  void initState() {
    super.initState();

    // ✅ OPTIMISATION: Réduire la durée sur appareils bas de gamme
    final isLowEnd = ResponsiveUtils.isVeryCompact(context);
    final durationMultiplier = isLowEnd ? 2.0 : 1.0;

    _controller1 = AnimationController(
      duration: Duration(seconds: (20 * durationMultiplier).round()),
      vsync: this,
    )..repeat();

    _controller2 = AnimationController(
      duration: Duration(seconds: (15 * durationMultiplier).round()),
      vsync: this,
    )..repeat();

    _controller3 = AnimationController(
      duration: Duration(seconds: (25 * durationMultiplier).round()),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0, end: _twoPi).animate(_controller1);
    _animation2 = Tween<double>(begin: 0, end: _twoPi).animate(_controller2);
    _animation3 = Tween<double>(begin: 0, end: _twoPi).animate(_controller3);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ OPTIMISATION: Cache la taille une seule fois
    _screenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ OPTIMISATION: Désactiver animations sur appareils très bas de gamme
    final shouldShowAnimations = widget.showFloatingShapes &&
        !ResponsiveUtils.shouldDisableAdvancedEffects(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // ✅ OPTIMISATION: RepaintBoundary pour isoler les animations
          if (shouldShowAnimations)
            RepaintBoundary(
              child: _OptimizedFloatingShapes(
                animation1: _animation1,
                animation2: _animation2,
                animation3: _animation3,
                screenSize: _screenSize,
              ),
            ),

          // ✅ OPTIMISATION: RepaintBoundary pour le contenu principal
          RepaintBoundary(child: widget.child),
        ],
      ),
    );
  }

}

/// ✅ OPTIMISATION: Widget séparé pour les formes flottantes avec RepaintBoundary
class _OptimizedFloatingShapes extends StatelessWidget {
  final Animation<double> animation1;
  final Animation<double> animation2;
  final Animation<double> animation3;
  final Size screenSize;

  const _OptimizedFloatingShapes({
    required this.animation1,
    required this.animation2,
    required this.animation3,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _OptimizedFloatingShape(
          animation: animation1,
          size: 120,
          color: AppColors.secondary,
          top: 0.1,
          left: 0.8,
          screenSize: screenSize,
        ),
        _OptimizedFloatingShape(
          animation: animation2,
          size: 80,
          color: AppColors.accent,
          top: 0.3,
          left: 0.1,
          screenSize: screenSize,
        ),
        _OptimizedFloatingShape(
          animation: animation3,
          size: 100,
          color: AppColors.tertiary,
          top: 0.7,
          left: 0.7,
          screenSize: screenSize,
        ),
        _OptimizedFloatingShape(
          animation: animation1,
          size: 60,
          color: AppColors.primary,
          top: 0.6,
          left: 0.2,
          screenSize: screenSize,
          reverse: true,
        ),
        _OptimizedFloatingShape(
          animation: animation2,
          size: 90,
          color: AppColors.secondary,
          top: 0.8,
          left: 0.9,
          screenSize: screenSize,
          reverse: true,
        ),
      ],
    );
  }
}

/// ✅ OPTIMISATION: Widget optimisé pour une forme flottante individuelle
class _OptimizedFloatingShape extends StatelessWidget {
  final Animation<double> animation;
  final double size;
  final Color color;
  final double top;
  final double left;
  final Size screenSize;
  final bool reverse;

  // ✅ OPTIMISATION: Pré-calculer les valeurs constantes
  static const double _twoPi = 2 * pi;
  static const double _movementAmplitudeX = 20;
  static const double _movementAmplitudeY = 30;

  const _OptimizedFloatingShape({
    required this.animation,
    required this.size,
    required this.color,
    required this.top,
    required this.left,
    required this.screenSize,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      // ✅ OPTIMISATION: Passer le child pour éviter rebuild
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
      builder: (context, child) {
        final animationValue = reverse ? (1 - animation.value) : animation.value;

        // ✅ OPTIMISATION: Pré-calculer les valeurs trigonométriques
        final angle = animationValue * _twoPi;
        final sinValue = sin(angle);
        final cosValue = cos(angle);

        return Positioned(
          top: screenSize.height * top + sinValue * _movementAmplitudeY,
          left: screenSize.width * left + cosValue * _movementAmplitudeX,
          child: Transform.rotate(
            angle: angle,
            child: child,
          ),
        );
      },
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ??
              const [
                AppColors.backgroundStart,
                AppColors.backgroundEnd,
              ],
        ),
      ),
      child: child,
    );
  }
}

class FloatingOrb extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double initialX;
  final double initialY;

  const FloatingOrb({
    super.key,
    required this.size,
    required this.color,
    this.duration = const Duration(seconds: 10),
    this.initialX = 0.5,
    this.initialY = 0.5,
  });

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    final random = Random.secure();
    _animation = Tween<Offset>(
      begin: Offset(widget.initialX, widget.initialY),
      end: Offset(
        widget.initialX + (random.nextDouble() - 0.5) * 0.3,
        widget.initialY + (random.nextDouble() - 0.5) * 0.3,
      ),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        // ✅ OPTIMISATION: Passer le child pour éviter rebuild
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.color.withValues(alpha: 0.4),
                widget.color.withValues(alpha: 0.2),
                widget.color.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
        builder: (context, child) {
          return FractionalTranslation(
            translation: _animation.value,
            child: child,
          );
        },
      ),
    );
  }
}
