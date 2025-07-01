import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

/// Animation de morphing fluide pour les transitions entre éléments
class MorphTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enableParticleEffect;

  const MorphTransition({
    super.key,
    required this.child,
    this.duration =
        const Duration(milliseconds: 800), // Garder pour l'effet élastique
    this.curve = Curves.elasticOut,
    this.enableParticleEffect = false,
  });

  @override
  State<MorphTransition> createState() => _MorphTransitionState();
}

class _MorphTransitionState extends State<MorphTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
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
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Animation fluide avec effet de vague pour les listes
class WaveSlideAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;

  const WaveSlideAnimation({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 600),
    this.delay = const Duration(milliseconds: 100),
    this.beginOffset = const Offset(100, 0),
  });

  @override
  State<WaveSlideAnimation> createState() => _WaveSlideAnimationState();
}

class _WaveSlideAnimationState extends State<WaveSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _delayTimer; // ✅ Timer trackable pour cleanup

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Délai basé sur l'index pour effet de vague avec cleanup approprié
    _delayTimer = Timer(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel(); // ✅ Cleanup critique du timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Controller pour l'animation de secousse
class ShakeController {
  _EnhancedShakeAnimationState? _state;

  void _attach(_EnhancedShakeAnimationState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void shake() {
    _state?.shake();
  }
}

/// Simple wrapper autour de ShakeAnimation existante pour compatibilité
class EnhancedShakeAnimation extends StatefulWidget {
  final Widget child;
  final ShakeController? controller;

  const EnhancedShakeAnimation({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<EnhancedShakeAnimation> createState() => _EnhancedShakeAnimationState();
}

class _EnhancedShakeAnimationState extends State<EnhancedShakeAnimation> {
  final GlobalKey<_ShakeAnimationState> _shakeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  void shake() {
    _shakeKey.currentState?.shake();
  }

  @override
  Widget build(BuildContext context) {
    return _ShakeAnimation(
      key: _shakeKey,
      child: widget.child,
    );
  }
}

/// Version interne de ShakeAnimation avec clé publique
class _ShakeAnimation extends StatefulWidget {
  final Widget child;

  const _ShakeAnimation({
    super.key,
    required this.child,
  });

  @override
  State<_ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<_ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue =
            (10.0 * math.sin(_animation.value * 2 * math.pi)).abs();
        return Transform.translate(
          offset: Offset(sineValue, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Animation de pulsation avec effet de respiration
class BreathingPulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final Color? glowColor;
  final bool enableGlow;

  const BreathingPulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 0.98,
    this.maxScale = 1.02,
    this.glowColor,
    this.enableGlow = true,
  });

  @override
  State<BreathingPulseAnimation> createState() =>
      _BreathingPulseAnimationState();
}

class _BreathingPulseAnimationState extends State<BreathingPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
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
          child: widget.enableGlow
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.glowColor ?? Colors.white)
                            .withValues(alpha: 0.3 * _glowAnimation.value),
                        blurRadius: 15 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: widget.child,
                )
              : widget.child,
        );
      },
    );
  }
}

/// Animation de rotation avec inertie naturelle
class SpinWithInertiaAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double rotations;
  final Curve curve;

  const SpinWithInertiaAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.rotations = 2.0,
    this.curve = Curves.elasticOut,
  });

  @override
  State<SpinWithInertiaAnimation> createState() =>
      _SpinWithInertiaAnimationState();
}

class _SpinWithInertiaAnimationState extends State<SpinWithInertiaAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.rotations * 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Animation de particules flottantes pour les arrière-plans
class FloatingParticlesAnimation extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final List<Color> particleColors;
  final double minSize;
  final double maxSize;
  final Duration animationDuration;

  const FloatingParticlesAnimation({
    super.key,
    required this.child,
    this.particleCount = 5, // Réduit de 20 à 5 pour les performances
    this.particleColors = const [
      Colors.white,
      Colors.blue,
      Colors.purple,
    ],
    this.minSize = 2.0,
    this.maxSize = 6.0,
    this.animationDuration = const Duration(seconds: 10),
  });

  @override
  State<FloatingParticlesAnimation> createState() =>
      _FloatingParticlesAnimationState();
}

class _FloatingParticlesAnimationState extends State<FloatingParticlesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _masterController;
  late List<_OptimizedParticle> _particles;
  static const int _maxParticles = 5; // Limite critique pour les performances

  @override
  void initState() {
    super.initState();
    _initializeOptimizedParticles();
  }

  void _initializeOptimizedParticles() {
    final random = math.Random();

    // Un seul controller maître pour toutes les particules
    _masterController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    // Limiter le nombre de particules pour les performances
    final effectiveParticleCount =
        math.min(widget.particleCount, _maxParticles);
    _particles = [];

    for (int i = 0; i < effectiveParticleCount; i++) {
      final particle = _OptimizedParticle(
        color:
            widget.particleColors[random.nextInt(widget.particleColors.length)],
        size: widget.minSize +
            random.nextDouble() * (widget.maxSize - widget.minSize),
        opacity: 0.3 + random.nextDouble() * 0.7,
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        endX: random.nextDouble(),
        endY: random.nextDouble(),
        phaseOffset: random.nextDouble() *
            2 *
            math.pi, // Décalage de phase pour la variété
        speedMultiplier: 0.5 + random.nextDouble() * 1.5, // Vitesse variable
      );

      _particles.add(particle);
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Arrière-plan avec particules optimisées
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _masterController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OptimizedParticlesPainter(
                    animationValue: _masterController.value,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
          // Contenu principal
          widget.child,
        ],
      ),
    );
  }
}

class _OptimizedParticle {
  final Color color;
  final double size;
  final double opacity;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double phaseOffset;
  final double speedMultiplier;

  _OptimizedParticle({
    required this.color,
    required this.size,
    required this.opacity,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.phaseOffset,
    required this.speedMultiplier,
  });

  // Calcule la position actuelle basée sur la valeur d'animation globale
  Offset getPosition(double animationValue) {
    final adjustedValue =
        (animationValue * speedMultiplier + phaseOffset) % 1.0;
    final t =
        (math.sin(adjustedValue * 2 * math.pi) + 1) / 2; // Oscillation 0-1

    return Offset(
      startX + (endX - startX) * t,
      startY + (endY - startY) * t,
    );
  }
}

class _OptimizedParticlesPainter extends CustomPainter {
  final double animationValue;
  final List<_OptimizedParticle> particles;

  _OptimizedParticlesPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(animationValue);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          position.dx * size.width,
          position.dy * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _OptimizedParticlesPainter ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Animation de liquidité pour les containers fluides
class LiquidAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color> colors;
  final double amplitude;

  const LiquidAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
    this.colors = const [
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ],
    this.amplitude = 20.0,
  });

  @override
  State<LiquidAnimation> createState() => _LiquidAnimationState();
}

class _LiquidAnimationState extends State<LiquidAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arrière-plan liquide
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _LiquidPainter(
                  animationValue: _controller.value,
                  colors: widget.colors,
                  amplitude: widget.amplitude,
                ),
              );
            },
          ),
        ),
        // Contenu principal
        widget.child,
      ],
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  final double amplitude;

  _LiquidPainter({
    required this.animationValue,
    required this.colors,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < colors.length; i++) {
      final path = Path();
      final waveOffset = (animationValue * 2 * math.pi) + (i * math.pi / 2);

      path.moveTo(0, size.height * 0.8);

      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height * 0.8 +
            amplitude * math.sin((x / size.width * 2 * math.pi) + waveOffset);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      paint.color = colors[i].withValues(alpha: 0.3 - (i * 0.1));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
