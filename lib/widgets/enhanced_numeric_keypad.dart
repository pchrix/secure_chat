import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_components.dart';
import '../utils/responsive_utils.dart'; // ✅ AJOUTÉ pour unifier les breakpoints
import '../utils/responsive_builder.dart'; // ✅ AJOUTÉ pour ResponsiveBuilder
import '../theme.dart';

/// Clavier numérique moderne avec effets visuels et animations
class EnhancedNumericKeypad extends StatefulWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBackspaceLongPress;
  final bool enableHapticFeedback;
  final bool enableSoundFeedback;
  final Color? accentColor;
  final double keySpacing;
  final EdgeInsetsGeometry? padding;

  const EnhancedNumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
    this.onBackspaceLongPress,
    this.enableHapticFeedback = true,
    this.enableSoundFeedback = false,
    this.accentColor,
    this.keySpacing = 16.0,
    this.padding,
  });

  @override
  State<EnhancedNumericKeypad> createState() => _EnhancedNumericKeypadState();
}

class _EnhancedNumericKeypadState extends State<EnhancedNumericKeypad>
    with TickerProviderStateMixin {
  final Map<String, GlobalKey<_NumericKeyState>> _keyStates = {};
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialiser les clés d'état pour chaque bouton
    for (int i = 0; i <= 9; i++) {
      _keyStates[i.toString()] = GlobalKey<_NumericKeyState>();
    }
    _keyStates['backspace'] = GlobalKey<_NumericKeyState>();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleKeyPress(String value) {
    // Animation de la touche
    _keyStates[value]?.currentState?.animate();

    // Feedback haptique
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Feedback sonore
    if (widget.enableSoundFeedback) {
      SystemSound.play(SystemSoundType.click);
    }

    // Callback
    if (value == 'backspace') {
      widget.onBackspacePressed();
    } else {
      widget.onNumberPressed(value);
    }
  }

  void _handleBackspaceLongPress() {
    if (widget.onBackspaceLongPress != null) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      widget.onBackspaceLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Utiliser ResponsiveUtils pour les breakpoints unifiés
          final isVeryCompact = ResponsiveUtils.isVeryCompact(context);
          final isCompact = ResponsiveUtils.isCompact(context);

          // ✅ CORRECTION CRITIQUE : Touch targets conformes accessibilité
          // Minimum 44px selon guidelines iOS/Android
          double keyHeight;
          if (isVeryCompact) {
            keyHeight = 44.0; // ✅ CONFORME : Minimum 44px même sur iPhone SE
          } else if (isCompact) {
            keyHeight = 48.0; // ✅ CONFORME : Confortable sur iPhone standard
          } else {
            keyHeight = 56.0; // ✅ CONFORME : Optimal sur écrans plus grands
          }

          // ✅ CORRECTION : Espacement adaptatif optimisé
          double spacing;
          if (isVeryCompact) {
            spacing = 4.0; // ✅ OPTIMISÉ : Minimal mais suffisant pour iPhone SE
          } else if (isCompact) {
            spacing = 6.0; // ✅ OPTIMISÉ : Équilibré pour iPhone standard
          } else {
            spacing = 8.0; // ✅ OPTIMISÉ : Confortable pour écrans plus grands
          }

          // Padding adaptatif ultra-réduit
          EdgeInsets adaptivePadding;
          if (isVeryCompact) {
            adaptivePadding = const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2); // ✅ ULTRA-COMPACT : Minimal
          } else if (isCompact) {
            adaptivePadding = const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4); // ✅ COMPACT : Réduit
          } else {
            adaptivePadding = const EdgeInsets.all(16); // ✅ NORMAL : Standard
          }

          return SingleChildScrollView(
            child: Padding(
              padding: widget.padding ?? adaptivePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Première rangée : 1, 2, 3
                  _buildKeyRow(const ['1', '2', '3'],
                      keyHeight: keyHeight, spacing: spacing),
                  SizedBox(height: spacing),

                  // Deuxième rangée : 4, 5, 6
                  _buildKeyRow(const ['4', '5', '6'],
                      keyHeight: keyHeight, spacing: spacing),
                  SizedBox(height: spacing),

                  // Troisième rangée : 7, 8, 9
                  _buildKeyRow(const ['7', '8', '9'],
                      keyHeight: keyHeight, spacing: spacing),
                  SizedBox(height: spacing),

                  // Quatrième rangée : vide, 0, backspace
                  _buildKeyRow(const ['', '0', 'backspace'],
                      keyHeight: keyHeight, spacing: spacing),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys, {double? keyHeight, double? spacing}) {
    final keySpacing = spacing ?? widget.keySpacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return Expanded(child: Container()); // Espace vide
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: keySpacing / 2),
            child: _NumericKey(
              key: _keyStates[key],
              value: key,
              onPressed: () => _handleKeyPress(key),
              onLongPress:
                  key == 'backspace' ? _handleBackspaceLongPress : null,
              accentColor: widget.accentColor ?? GlassColors.primary,
              keyHeight: keyHeight,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Widget pour une touche numérique individuelle
class _NumericKey extends StatefulWidget {
  final String value;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Color accentColor;
  final double? keyHeight;

  const _NumericKey({
    super.key,
    required this.value,
    required this.onPressed,
    this.onLongPress,
    required this.accentColor,
    this.keyHeight,
  });

  @override
  State<_NumericKey> createState() => _NumericKeyState();
}

class _NumericKeyState extends State<_NumericKey>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void animate() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isBackspace = widget.value == 'backspace';

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.keyHeight ?? 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Container principal glassmorphism
                  // ✅ CORRECTION : Désactiver les effets avancés pour éviter RepaintBoundary/Positioned conflicts
                  EnhancedGlassContainer(
                    width: double.infinity,
                    height: double.infinity,
                    color:
                        isBackspace ? Colors.red.withValues(alpha: 0.1) : null,
                    opacity: _isPressed ? 0.25 : 0.15,
                    enableDepthEffect:
                        false, // ✅ Désactiver pour éviter Positioned conflicts
                    enableInnerShadow:
                        false, // ✅ Désactiver pour éviter Positioned conflicts
                    child: Center(
                      child: isBackspace
                          ? Icon(
                              Icons.backspace_outlined,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 24,
                            )
                          : Text(
                              widget.value,
                              style: AppTextStyles.pinNumber,
                            ),
                    ),
                  ),

                  // Effet de ripple
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: _rippleAnimation.value * 0.8,
                            colors: [
                              widget.accentColor.withValues(
                                alpha: 0.3 * (1 - _rippleAnimation.value),
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Indicateur de PIN avec animations
class PinIndicator extends StatefulWidget {
  final int length;
  final int filledCount;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;
  final bool showError;

  const PinIndicator({
    super.key,
    required this.length,
    required this.filledCount,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 16.0,
    this.spacing = 16.0,
    this.showError = false,
  });

  @override
  State<PinIndicator> createState() => _PinIndicatorState();
}

class _PinIndicatorState extends State<PinIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _errorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animation lors de l'ajout d'un chiffre
    if (oldWidget.filledCount < widget.filledCount) {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
    }

    // Animation d'erreur
    if (widget.showError && !oldWidget.showError) {
      _errorController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _errorController.reverse();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? GlassColors.primary;
    final inactiveColor =
        widget.inactiveColor ?? Colors.white.withValues(alpha: 0.3);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _errorAnimation]),
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (index) {
              final isFilled = index < widget.filledCount;
              final isLast = index == widget.filledCount - 1;
              final shouldPulse = isLast && _pulseController.isAnimating;
              final errorIntensity =
                  widget.showError ? _errorAnimation.value : 0.0;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: Transform.scale(
                  scale: shouldPulse ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? Color.lerp(
                              activeColor,
                              Colors.red,
                              errorIntensity,
                            )
                          : inactiveColor,
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: Color.lerp(
                                  activeColor,
                                  Colors.red,
                                  errorIntensity,
                                )!
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: shouldPulse ? 2 : 0,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Widget combiné clavier + indicateur PIN
class PinEntryWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinComplete;
  final Function(String)? onPinChanged;
  final bool enableBiometric;
  final String? errorMessage;
  final bool isLoading;

  const PinEntryWidget({
    super.key,
    this.pinLength = 4,
    required this.onPinComplete,
    this.onPinChanged,
    this.enableBiometric = false,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  String _currentPin = '';
  bool _showError = false;

  void _onNumberPressed(String number) {
    if (_currentPin.length < widget.pinLength) {
      setState(() {
        _currentPin += number;
        _showError = false;
      });

      widget.onPinChanged?.call(_currentPin);

      if (_currentPin.length == widget.pinLength) {
        widget.onPinComplete(_currentPin);
      }
    }
  }

  void _onBackspacePressed() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _showError = false;
      });

      widget.onPinChanged?.call(_currentPin);
    }
  }

  void _onBackspaceLongPress() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = '';
        _showError = false;
      });

      widget.onPinChanged?.call(_currentPin);
    }
  }

  @override
  void didUpdateWidget(PinEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Afficher l'erreur si le message d'erreur change
    if (widget.errorMessage != null &&
        widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _showError = true;
        _currentPin = ''; // Effacer le PIN en cas d'erreur
      });

      // Cacher l'erreur après un délai
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Utiliser ResponsiveUtils pour les breakpoints unifiés
        final isVeryCompact = ResponsiveUtils.isVeryCompact(context);
        final isCompact = ResponsiveUtils.isCompact(context);

        // Espacement adaptatif pour les titres ultra-réduit
        double titleSpacing;
        if (isVeryCompact) {
          titleSpacing = 2.0; // Réduit de 4 à 2
        } else if (isCompact) {
          titleSpacing = 3.0; // Réduit de 6 à 3
        } else {
          titleSpacing = 4.0; // Réduit de 8 à 4
        }

        // Espacement adaptatif pour les sections ultra-réduit
        double sectionSpacing;
        if (isVeryCompact) {
          sectionSpacing = 8.0; // Réduit de 16 à 8
        } else if (isCompact) {
          sectionSpacing = 12.0; // Réduit de 24 à 12
        } else {
          sectionSpacing = 16.0; // Réduit de 32 à 16
        }

        // Espacement adaptatif pour l'indicateur PIN ultra-réduit
        double pinSpacing;
        if (isVeryCompact) {
          pinSpacing = 3.0; // Réduit de 6 à 3
        } else if (isCompact) {
          pinSpacing = 6.0; // Réduit de 12 à 6
        } else {
          pinSpacing = 8.0; // Réduit de 16 à 8
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            Text(
              'Saisir le code PIN',
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: isVeryCompact ? 18 : (isCompact ? 20 : 24),
              ),
            ),

            SizedBox(height: titleSpacing),

            // Sous-titre
            Text(
              'Entrez votre code à 4 chiffres',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isVeryCompact ? 13 : (isCompact ? 14 : 16),
              ),
            ),

            SizedBox(height: sectionSpacing),

            // Indicateur PIN
            PinIndicator(
              length: widget.pinLength,
              filledCount: _currentPin.length,
              showError: _showError,
              dotSize: isVeryCompact ? 12.0 : 16.0,
              spacing: isVeryCompact ? 10.0 : 16.0,
            ),

            SizedBox(height: pinSpacing),

            // Message d'erreur
            SizedBox(
              height: isVeryCompact ? 16 : 20,
              child: widget.errorMessage != null && _showError
                  ? Text(
                      widget.errorMessage!,
                      style: AppTextStyles.errorText.copyWith(
                        fontSize: isVeryCompact ? 11 : 14,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
            ),

            SizedBox(height: sectionSpacing),

            // Indicateur de chargement ou clavier
            if (widget.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(
                  color: GlassColors.primary,
                ),
              )
            else
              // ✅ CLAVIER FLEXIBLE SANS CONTRAINTE DE HAUTEUR
              Flexible(
                child: EnhancedNumericKeypad(
                  onNumberPressed: _onNumberPressed,
                  onBackspacePressed: _onBackspacePressed,
                  onBackspaceLongPress: _onBackspaceLongPress,
                  keySpacing: isVeryCompact ? 6.0 : (isCompact ? 10.0 : 16.0),
                  padding:
                      EdgeInsets.all(isVeryCompact ? 8 : (isCompact ? 12 : 20)),
                ),
              ),

            // Option biométrique
            if (widget.enableBiometric) ...[
              SizedBox(height: isVeryCompact ? 4 : (isCompact ? 6 : 12)),
              EnhancedGlassButton(
                onTap: () {
                  // Authentification biométrique non implémentée dans le MVP
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: isVeryCompact ? 18 : 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Utiliser l\'empreinte',
                      style: AppTextStyles.buttonMedium.copyWith(
                        fontSize: isVeryCompact ? 13 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
