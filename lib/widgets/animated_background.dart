import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

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

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _controller3 = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0, end: 2 * pi).animate(_controller1);
    _animation2 = Tween<double>(begin: 0, end: 2 * pi).animate(_controller2);
    _animation3 = Tween<double>(begin: 0, end: 2 * pi).animate(_controller3);
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
    return Container(
      decoration: const BoxDecoration(
        gradient: GlassColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Formes géométriques flottantes
          if (widget.showFloatingShapes) ...[
            _buildFloatingShape(
              animation: _animation1,
              size: 120,
              color: GlassColors.secondary,
              top: 0.1,
              left: 0.8,
            ),
            _buildFloatingShape(
              animation: _animation2,
              size: 80,
              color: GlassColors.accent,
              top: 0.3,
              left: 0.1,
            ),
            _buildFloatingShape(
              animation: _animation3,
              size: 100,
              color: GlassColors.tertiary,
              top: 0.7,
              left: 0.7,
            ),
            _buildFloatingShape(
              animation: _animation1,
              size: 60,
              color: GlassColors.primary,
              top: 0.6,
              left: 0.2,
              reverse: true,
            ),
            _buildFloatingShape(
              animation: _animation2,
              size: 90,
              color: GlassColors.secondary,
              top: 0.8,
              left: 0.9,
              reverse: true,
            ),
          ],

          // Contenu principal
          widget.child,
        ],
      ),
    );
  }

  Widget _buildFloatingShape({
    required Animation<double> animation,
    required double size,
    required Color color,
    required double top,
    required double left,
    bool reverse = false,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final animationValue =
            reverse ? (1 - animation.value) : animation.value;

        return Positioned(
          top: screenSize.height * top + sin(animationValue * 2 * pi) * 30,
          left: screenSize.width * left + cos(animationValue * 2 * pi) * 20,
          child: Transform.rotate(
            angle: animationValue * 2 * pi,
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
              [
                GlassColors.backgroundStart,
                GlassColors.backgroundEnd,
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _animation.value,
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
        );
      },
    );
  }
}
