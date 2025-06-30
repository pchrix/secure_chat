/// 🔐 PIN Page - Page d'authentification PIN
///
/// Page dédiée à l'authentification par PIN avec design glassmorphism
/// Conforme aux meilleures pratiques Context7 et Clean Architecture

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../animations/enhanced_micro_interactions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive_builder.dart';
import '../../../../widgets/animated_background.dart';
import '../../../../widgets/glass_components.dart';
import '../providers/pin_state_provider.dart';
import '../widgets/pin_entry_widget.dart';

/// Page d'authentification PIN
class PinPage extends ConsumerStatefulWidget {
  final VoidCallback? onAuthenticationSuccess;
  final VoidCallback? onNavigateToSetup;

  const PinPage({
    super.key,
    this.onAuthenticationSuccess,
    this.onNavigateToSetup,
  });

  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoAnimation;

  final ShakeController _shakeController = ShakeController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController.forward();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _onPinComplete(String pin) async {
    final notifier = ref.read(pinStateProvider.notifier);
    final success = await notifier.authenticateWithPin(pin);

    if (success) {
      widget.onAuthenticationSuccess?.call();
    } else {
      _shakeController.shake();
      HapticFeedback.heavyImpact();
    }
  }

  void _onPinChanged(String pin) {
    // Effacer l'erreur lors de la saisie
    if (ref.read(pinStateProvider).errorMessage != null) {
      ref.read(pinStateProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinStateProvider);

    // Si aucun PIN n'est configuré, naviguer vers la configuration
    if (pinState.mode == PinMode.setup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onNavigateToSetup?.call();
      });
    }

    return Scaffold(
      body: AnimatedBackground(
        child: ResponsiveBuilder(
          builder: (context, responsive) {
            return SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: _buildContent(responsive),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ResponsiveInfo responsive) {
    // Calculs responsive
    final isVeryCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE1;
    final isCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE2;

    // Espacements adaptatifs
    final topSpacing = isVeryCompact ? 20.0 : (isCompact ? 40.0 : 60.0);
    final centerSpacing = isVeryCompact ? 30.0 : (isCompact ? 40.0 : 60.0);
    final pinContainerPadding =
        EdgeInsets.all(isVeryCompact ? 16.0 : (isCompact ? 20.0 : 24.0));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Espacement en haut flexible
            SizedBox(height: topSpacing),

            // Logo et titre avec animation
            _buildHeader(responsive: responsive),

            // Espacement au centre flexible
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
                  enableBiometric: true,
                ),
              ),
            ),

            // Espacement en bas flexible
            SizedBox(height: topSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required ResponsiveInfo responsive}) {
    final isVeryCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE1;
    final isCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE2;

    return Column(
      children: [
        // Logo animé
        ScaleTransition(
          scale: _logoAnimation,
          child: Container(
            width: isVeryCompact ? 60 : (isCompact ? 70 : 80),
            height: isVeryCompact ? 60 : (isCompact ? 70 : 80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: isVeryCompact ? 30 : (isCompact ? 35 : 40),
            ),
          ),
        ),

        SizedBox(height: isVeryCompact ? 16 : (isCompact ? 20 : 24)),

        // Titre principal avec effet de dégradé
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ).createShader(bounds),
          child: Text(
            'SecureChat',
            style: AppTheme.headlineLarge.copyWith(
              fontSize: isVeryCompact ? 24 : (isCompact ? 28 : 32),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: isVeryCompact ? 8 : 12),

        // Sous-titre
        Text(
          'Authentification sécurisée',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isVeryCompact ? 14 : (isCompact ? 16 : 18),
          ),
        ),
      ],
    );
  }
}
