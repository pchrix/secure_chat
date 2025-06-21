import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_container.dart';
import '../theme.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onBackspacePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;
  final bool enableHapticFeedback;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    this.onBackspacePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
    this.enableHapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Première ligne : 1, 2, 3
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 16),
          
          // Deuxième ligne : 4, 5, 6
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 16),
          
          // Troisième ligne : 7, 8, 9
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 16),
          
          // Quatrième ligne : biométrie/vide, 0, backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton biométrique ou espace vide
              if (showBiometric)
                _buildSpecialKey(
                  icon: Icons.fingerprint,
                  onPressed: onBiometricPressed,
                  color: GlassColors.secondary,
                )
              else
                const SizedBox(width: 72, height: 72),
              
              // Bouton 0
              _buildNumberKey('0'),
              
              // Bouton backspace
              _buildSpecialKey(
                icon: Icons.backspace_outlined,
                onPressed: onBackspacePressed,
                color: GlassColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildNumberKey(number)).toList(),
    );
  }

  Widget _buildNumberKey(String number) {
    return GlassButton(
      width: 72,
      height: 72,
      borderRadius: BorderRadius.circular(36),
      color: GlassColors.glassWhite,
      onTap: () {
        if (enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        onNumberPressed(number);
      },
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return GlassButton(
      width: 72,
      height: 72,
      borderRadius: BorderRadius.circular(36),
      color: color.withValues(alpha: 0.2),
      onTap: onPressed != null ? () {
        if (enableHapticFeedback) {
          HapticFeedback.mediumImpact();
        }
        onPressed();
      } : null,
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

class PinIndicator extends StatefulWidget {
  final int pinLength;
  final int currentLength;
  final bool isError;
  final Duration animationDuration;

  const PinIndicator({
    super.key,
    required this.pinLength,
    required this.currentLength,
    this.isError = false,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<PinIndicator> createState() => _PinIndicatorState();
}

class _PinIndicatorState extends State<PinIndicator>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _fillController;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _fillController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isError && !oldWidget.isError) {
      _triggerShakeAnimation();
    }
    
    if (widget.currentLength != oldWidget.currentLength) {
      _fillController.animateTo(widget.currentLength / widget.pinLength);
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildDot(index),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDot(int index) {
    final bool isFilled = index < widget.currentLength;
    final Color color = widget.isError 
        ? GlassColors.danger 
        : (isFilled ? GlassColors.primary : GlassColors.onSurfaceVariant);

    return AnimatedContainer(
      duration: widget.animationDuration,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? color : Colors.transparent,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: isFilled
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            )
          : null,
    );
  }
}
