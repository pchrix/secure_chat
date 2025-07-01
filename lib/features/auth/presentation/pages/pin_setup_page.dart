/// 🔐 PIN Setup Page - Page de configuration PIN
///
/// Page dédiée à la création et configuration d'un nouveau PIN
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

/// Page de configuration PIN
class PinSetupPage extends ConsumerStatefulWidget {
  final VoidCallback? onSetupComplete;

  const PinSetupPage({
    super.key,
    this.onSetupComplete,
  });

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController.forward();

    // S'assurer que nous sommes en mode setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinStateProvider.notifier).changeMode(PinMode.setup);
    });
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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

  Future<void> _onPinComplete(String pin) async {
    final pinState = ref.read(pinStateProvider);
    final notifier = ref.read(pinStateProvider.notifier);

    if (pinState.currentStep == 0) {
      // Première étape : stocker le PIN et passer à la confirmation
      notifier.nextStep();
      _progressController.animateTo(0.5);
    } else {
      // Deuxième étape : confirmer le PIN
      final success = await notifier.setupPin(pinState.confirmPin!, pin);

      if (success) {
        _progressController.animateTo(1.0);
        HapticFeedback.lightImpact();

        // Attendre un peu pour l'animation puis naviguer
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onSetupComplete?.call();
      } else {
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _onPinChanged(String pin) {
    // Effacer l'erreur lors de la saisie
    if (ref.read(pinStateProvider).errorMessage != null) {
      ref.read(pinStateProvider.notifier).clearError();
    }
  }

  void _onBackPressed() {
    final pinState = ref.read(pinStateProvider);
    if (pinState.currentStep > 0) {
      ref.read(pinStateProvider.notifier).previousStep();
      _progressController.animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final pinState = ref.watch(pinStateProvider);

    // Calculs responsive
    final isVeryCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE1;
    final isCompact =
        responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE2;

    // Espacements adaptatifs
    final topSpacing = isVeryCompact ? 20.0 : (isCompact ? 30.0 : 40.0);
    final sectionSpacing = isVeryCompact ? 20.0 : (isCompact ? 30.0 : 40.0);
    final pinContainerPadding =
        EdgeInsets.all(isVeryCompact ? 16.0 : (isCompact ? 20.0 : 24.0));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          SizedBox(height: topSpacing),

          // Bouton retour (si étape > 0)
          if (pinState.currentStep > 0) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  onPressed: _onBackPressed,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: topSpacing * 0.5),
          ],

          // Indicateur de progression
          _buildProgressIndicator(pinState),

          SizedBox(height: sectionSpacing),

          // En-tête avec titre et description
          _buildHeader(pinState, isVeryCompact, isCompact),

          SizedBox(height: sectionSpacing),

          // Interface PIN
          EnhancedGlassContainer(
            padding: pinContainerPadding,
            child: PinEntryWidget(
              pinLength: 4,
              onPinComplete: _onPinComplete,
              onPinChanged: _onPinChanged,
              enableBiometric: false,
            ),
          ),

          SizedBox(height: topSpacing),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(PinState pinState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Barre de progression
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final progress = pinState.currentStep == 0 ? 0.0 : 0.5;
              final animatedProgress =
                  progress + (_progressAnimation.value * 0.5);

              return LinearProgressIndicator(
                value: animatedProgress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 4,
              );
            },
          ),

          const SizedBox(height: 12),

          // Texte de progression
          Text(
            'Étape ${pinState.currentStep + 1} sur 2',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: AppTypography.fontSizeMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PinState pinState, bool isVeryCompact, bool isCompact) {
    return Column(
      children: [
        // Icône
        Container(
          width: isVeryCompact ? 50 : (isCompact ? 60 : 70),
          height: isVeryCompact ? 50 : (isCompact ? 60 : 70),
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
            pinState.currentStep == 0
                ? Icons.lock_outline
                : Icons.check_circle_outline,
            color: Colors.white,
            size: isVeryCompact ? 25 : (isCompact ? 30 : 35),
          ),
        ),

        SizedBox(height: isVeryCompact ? 16 : (isCompact ? 20 : 24)),

        // Titre de l'étape
        MorphTransition(
          child: Text(
            pinState.currentStep == 0
                ? 'Créer un mot de passe'
                : 'Confirmer le mot de passe',
            style: AppTheme.headlineLarge.copyWith(
              fontSize: isVeryCompact ? 20 : (isCompact ? 24 : 28),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        SizedBox(height: isVeryCompact ? 8 : 12),

        // Description
        Text(
          pinState.currentStep == 0
              ? 'Choisissez un mot de passe de 4 chiffres'
              : 'Saisissez à nouveau votre mot de passe',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isVeryCompact ? 14 : (isCompact ? 16 : 18),
          ),
        ),
      ],
    );
  }
}
