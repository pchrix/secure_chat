import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../widgets/glass_components.dart';
import '../widgets/enhanced_numeric_keypad.dart';
import '../widgets/animated_background.dart';
import '../animations/enhanced_micro_interactions.dart';
import '../theme.dart';
import 'home_page.dart';

class EnhancedAuthPage extends StatefulWidget {
  const EnhancedAuthPage({super.key});

  @override
  State<EnhancedAuthPage> createState() => _EnhancedAuthPageState();
}

class _EnhancedAuthPageState extends State<EnhancedAuthPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCheckingPassword = true;

  late AnimationController _pageController;
  late AnimationController _logoController;
  late AnimationController _errorController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  final ShakeController _shakeController = ShakeController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkPasswordStatus();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _errorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  Future<void> _checkPasswordStatus() async {
    final hasPassword = await AuthService.hasPasswordSet();
    setState(() {
      _isCheckingPassword = false;
    });

    if (!hasPassword) {
      _navigateToPasswordSetup();
    } else {
      _logoController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      _pageController.forward();
    }
  }

  void _navigateToPasswordSetup() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EnhancedPasswordSetupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onPinChanged(String pin) {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _onPinComplete(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.verifyPassword(pin);

      if (result.isSuccess) {
        _navigateToHome();
      } else {
        _handleAuthError(result.message ?? 'Erreur d\'authentification');
      }
    } catch (e) {
      _handleAuthError('Erreur lors de l\'authentification');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAuthError(String message) {
    setState(() {
      _errorMessage = message;
    });

    _shakeController.shake();
    HapticFeedback.heavyImpact();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPassword) {
      return Scaffold(
        resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
        body: AnimatedBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BreathingPulseAnimation(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: GlassColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: GlassColors.primary,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Initialisation...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
      body: AnimatedBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Obtenir les dimensions de l'écran et du clavier
                  final screenHeight = MediaQuery.of(context).size.height;
                  final keyboardHeight =
                      MediaQuery.of(context).viewInsets.bottom;

                  // Calculer les dimensions adaptatives avec breakpoints ultra-agressifs
                  final isVeryCompact = screenHeight <
                      700; // iPhone SE, petits écrans - seuil ultra-agressif
                  final isCompact = screenHeight <
                      800; // iPhone standard - seuil ultra-agressif

                  // Padding adaptatif ultra-compact
                  EdgeInsets adaptivePadding;
                  if (isVeryCompact) {
                    adaptivePadding = const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6); // Réduit encore plus
                  } else if (isCompact) {
                    adaptivePadding = const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10); // Réduit
                  } else {
                    adaptivePadding =
                        const EdgeInsets.all(20); // Réduit de 24 à 20
                  }

                  // Espacement adaptatif ultra-réduit
                  double topSpacing = isVeryCompact
                      ? 8
                      : (isCompact ? 16 : 24); // Réduit drastiquement
                  double centerSpacing = isVeryCompact
                      ? 6
                      : (isCompact ? 12 : 20); // Réduit drastiquement
                  double bottomSpacing = isVeryCompact
                      ? 6
                      : (isCompact ? 12 : 20); // Réduit drastiquement
                  double safetySpacing = isVeryCompact
                      ? 6
                      : (isCompact ? 10 : 16); // Réduit drastiquement

                  // Padding du container PIN adaptatif ultra-réduit
                  EdgeInsets pinContainerPadding;
                  if (isVeryCompact) {
                    pinContainerPadding =
                        const EdgeInsets.all(12); // Réduit de 20 à 12
                  } else if (isCompact) {
                    pinContainerPadding =
                        const EdgeInsets.all(18); // Réduit de 26 à 18
                  } else {
                    pinContainerPadding =
                        const EdgeInsets.all(24); // Réduit de 32 à 24
                  }

                  return SingleChildScrollView(
                    reverse: true, // ✅ AJOUTÉ pour keyboard avoidance
                    padding: adaptivePadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(
                          0, // ✅ CORRECTION : Empêcher les contraintes négatives
                          constraints.maxHeight -
                              (adaptivePadding.top + adaptivePadding.bottom) -
                              keyboardHeight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Espacement en haut
                          SizedBox(height: topSpacing),

                          // Logo et titre avec animation
                          _buildHeader(
                              isVeryCompact: isVeryCompact,
                              isCompact: isCompact),

                          // Espacement au centre
                          SizedBox(height: centerSpacing),

                          // Interface PIN avec gestion d'erreur
                          EnhancedShakeAnimation(
                            controller: _shakeController,
                            child: EnhancedGlassContainer(
                              padding: pinContainerPadding,
                              child: PinEntryWidget(
                                pinLength: 4,
                                onPinComplete: _onPinComplete,
                                onPinChanged: _onPinChanged,
                                errorMessage: _errorMessage,
                                isLoading: _isLoading,
                                enableBiometric: true,
                              ),
                            ),
                          ),

                          // Espacement en bas
                          SizedBox(height: bottomSpacing),

                          // Footer avec informations
                          _buildFooter(
                              isVeryCompact: isVeryCompact,
                              isCompact: isCompact),

                          // Espacement de sécurité en bas
                          SizedBox(height: safetySpacing),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({bool isVeryCompact = false, bool isCompact = false}) {
    // Dimensions adaptatives ultra-compactes
    double logoSize =
        isVeryCompact ? 70 : (isCompact ? 85 : 100); // Réduit significativement
    double iconSize =
        isVeryCompact ? 35 : (isCompact ? 42 : 50); // Réduit significativement
    double titleSpacing =
        isVeryCompact ? 12 : (isCompact ? 16 : 20); // Réduit significativement
    double subtitleSpacing =
        isVeryCompact ? 4 : (isCompact ? 6 : 8); // Réduit significativement
    double titleFontSize =
        isVeryCompact ? 22 : (isCompact ? 26 : 30); // Réduit significativement
    double subtitleFontSize =
        isVeryCompact ? 12 : (isCompact ? 14 : 16); // Réduit significativement

    return Column(
      children: [
        // Logo animé
        AnimatedBuilder(
          animation: _logoAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoAnimation.value,
              child: Transform.rotate(
                angle: _logoAnimation.value * 0.1,
                child: EnhancedGlassContainer(
                  width: logoSize,
                  height: logoSize,
                  color: GlassColors.primary,
                  child: Icon(
                    Icons.security,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: titleSpacing),

        // Titre avec effet de dégradé
        MorphTransition(
          child: ShaderMask(
            shaderCallback: (bounds) =>
                GlassColors.primaryGradient.createShader(bounds),
            child: Text(
              'SecureChat',
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
        ),

        SizedBox(height: subtitleSpacing),

        // Sous-titre
        WaveSlideAnimation(
          index: 0,
          delay: const Duration(milliseconds: 800),
          child: Text(
            'Authentification sécurisée',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter({bool isVeryCompact = false, bool isCompact = false}) {
    // Dimensions adaptatives ultra-compactes
    double iconSize = isVeryCompact ? 12 : 14; // Réduit
    double spacing = isVeryCompact ? 4 : 6; // Réduit
    double titleFontSize = isVeryCompact ? 10 : 12; // Réduit
    double descriptionFontSize = isVeryCompact ? 9 : 11; // Réduit

    return Column(
      children: [
        // Indicateur de sécurité
        WaveSlideAnimation(
          index: 0,
          delay: const Duration(milliseconds: 1000),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                color: GlassColors.success.withValues(alpha: 0.8),
                size: iconSize,
              ),
              SizedBox(width: spacing),
              Text(
                'Chiffrement AES-256',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spacing),

        // Informations de sécurité
        WaveSlideAnimation(
          index: 1,
          delay: const Duration(milliseconds: 1100),
          child: Text(
            'Vos données sont protégées par un chiffrement de niveau militaire',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: descriptionFontSize,
            ),
          ),
        ),
      ],
    );
  }
}

/// Page de configuration de mot de passe améliorée
class EnhancedPasswordSetupPage extends StatefulWidget {
  const EnhancedPasswordSetupPage({super.key});

  @override
  State<EnhancedPasswordSetupPage> createState() =>
      _EnhancedPasswordSetupPageState();
}

class _EnhancedPasswordSetupPageState extends State<EnhancedPasswordSetupPage>
    with TickerProviderStateMixin {
  String _currentPin = '';
  String _confirmPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0; // 0: création, 1: confirmation

  late AnimationController _pageController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController.forward();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onPinChanged(String pin) {
    setState(() {
      if (_currentStep == 0) {
        _currentPin = pin;
      } else {
        _confirmPin = pin;
      }
      _errorMessage = null;
    });
  }

  Future<void> _onPinComplete(String pin) async {
    if (_currentStep == 0) {
      // Première étape : validation du format
      if (!AuthService.isValidPasswordFormat(pin)) {
        setState(() {
          _errorMessage = 'Le mot de passe doit contenir 4 chiffres';
        });
        return;
      }

      // Passer à l'étape de confirmation
      setState(() {
        _currentStep = 1;
        _confirmPin = '';
      });

      _progressController.forward();
    } else {
      // Deuxième étape : confirmation
      setState(() {
        _confirmPin = pin;
      });

      if (_confirmPin != _currentPin) {
        setState(() {
          _errorMessage = 'Les mots de passe ne correspondent pas';
        });
        return;
      }

      // Enregistrer le mot de passe
      await _setupPassword();
    }
  }

  Future<void> _setupPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthService.setPassword(_currentPin);

      if (success) {
        _navigateToHome();
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la configuration du mot de passe';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la configuration';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep = 0;
        _confirmPin = '';
        _errorMessage = null;
      });
      _progressController.reverse();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
      body: AnimatedBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                return SingleChildScrollView(
                  reverse: true, // ✅ AJOUTÉ pour keyboard avoidance
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0, // ✅ CORRECTION : Empêcher les contraintes négatives
                        constraints.maxHeight - 48 - keyboardHeight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header avec progression
                        _buildProgressHeader(),

                        const Spacer(),

                        // Contenu principal
                        _buildMainContent(),

                        const Spacer(),

                        // Navigation
                        if (_currentStep > 0) _buildNavigationButtons(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        // Barre de progression
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      ((_currentStep + _progressAnimation.value) / 2) *
                      0.6,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: GlassColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // Titre de l'étape
        MorphTransition(
          child: Text(
            _currentStep == 0
                ? 'Créer un mot de passe'
                : 'Confirmer le mot de passe',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Description
        Text(
          _currentStep == 0
              ? 'Choisissez un mot de passe de 4 chiffres'
              : 'Saisissez à nouveau votre mot de passe',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return EnhancedGlassContainer(
      padding: const EdgeInsets.all(32),
      child: PinEntryWidget(
        pinLength: 4,
        onPinComplete: _onPinComplete,
        onPinChanged: _onPinChanged,
        errorMessage: _errorMessage,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Bouton retour
        Expanded(
          child: EnhancedGlassButton(
            onTap: _goBack,
            color: Colors.white.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Retour',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
