import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../widgets/glass_components.dart';
import '../theme.dart';
import 'enhanced_auth_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const EnhancedAuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassColors.background,
      resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header avec bouton Skip - Responsive
                  Builder(
                    builder: (context) {
                      final screenHeight = MediaQuery.of(context).size.height;
                      final isVeryCompact = screenHeight < 700; // iPhone SE
                      final isCompact = screenHeight < 800; // iPhone Standard

                      final headerPadding =
                          isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);
                      final titleFontSize =
                          isVeryCompact ? 16.0 : (isCompact ? 18.0 : 20.0);
                      final skipFontSize =
                          isVeryCompact ? 14.0 : (isCompact ? 15.0 : 16.0);

                      return Padding(
                        padding: EdgeInsets.all(headerPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'SecureChat',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_currentPage > 0)
                              GestureDetector(
                                onTap: _skipTutorial,
                                child: Text(
                                  'Passer',
                                  style: TextStyle(
                                    color: GlassColors.primary
                                        .withValues(alpha: 0.8),
                                    fontSize: skipFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Indicateurs de progression
                  _buildProgressIndicator(),

                  const SizedBox(height: 16),

                  // Contenu des pages avec scroll
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        HapticFeedback.lightImpact();
                      },
                      children: [
                        _buildWelcomePage(constraints),
                        _buildSecurityPage(constraints),
                        _buildRoomsPage(constraints),
                        _buildEncryptionPage(constraints),
                        _buildReadyPage(constraints),
                      ],
                    ),
                  ),

                  // Boutons de navigation
                  _buildNavigationButtons(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(_totalPages, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < _totalPages - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? GlassColors.primary
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage(BoxConstraints constraints) {
    // Breakpoints ultra-agressifs pour iPhone SE et petits écrans
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    // Tailles d'icônes ultra-compactes
    final iconSize = isVeryCompact ? 80 : (isCompact ? 100 : 120);
    final iconInnerSize = isVeryCompact ? 40 : (isCompact ? 50 : 60);

    // Tailles de texte ultra-adaptatives
    final titleSize = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
    final subtitleSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);

    // Espacements ultra-réduits
    final titleSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);
    final subtitleSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(adaptivePadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Réduction drastique de l'espace réservé pour éviter débordement
          minHeight:
              math.max(0, constraints.maxHeight - (isVeryCompact ? 180 : 220)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: iconSize.toDouble(),
              height: iconSize.toDouble(),
              borderRadius: BorderRadius.circular(isVeryCompact ? 20 : 30),
              color: GlassColors.primary,
              opacity: 0.2,
              child: Icon(
                Icons.security,
                size: iconInnerSize.toDouble(),
                color: GlassColors.primary,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Bienvenue dans SecureChat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                // Réduction de la hauteur de ligne sur petits écrans
                height: isVeryCompact ? 1.2 : 1.3,
              ),
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              'Votre nouvelle application de messagerie sécurisée avec chiffrement de bout en bout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: isVeryCompact ? 1.3 : 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityPage(BoxConstraints constraints) {
    // Breakpoints ultra-agressifs cohérents
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    // Tailles d'icônes ultra-compactes
    final iconSize = isVeryCompact ? 80 : (isCompact ? 100 : 120);
    final iconInnerSize = isVeryCompact ? 40 : (isCompact ? 50 : 60);

    // Tailles de texte ultra-adaptatives
    final titleSize = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
    final subtitleSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);

    // Espacements ultra-réduits
    final titleSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);
    final subtitleSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final featureSpacing = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(adaptivePadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              math.max(0, constraints.maxHeight - (isVeryCompact ? 180 : 220)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: iconSize.toDouble(),
              height: iconSize.toDouble(),
              borderRadius: BorderRadius.circular(isVeryCompact ? 20 : 30),
              color: GlassColors.secondary,
              opacity: 0.2,
              child: Icon(
                Icons.lock_outline,
                size: iconInnerSize.toDouble(),
                color: GlassColors.secondary,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Sécurité Maximale',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                height: isVeryCompact ? 1.2 : 1.3,
              ),
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              'Vos conversations sont protégées par un chiffrement AES-256 de niveau militaire. Seuls vous et votre correspondant pouvez lire les messages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: isVeryCompact ? 1.3 : 1.5,
              ),
            ),
            SizedBox(height: featureSpacing),
            _buildFeatureList([
              'Chiffrement AES-256',
              'Aucune donnée stockée sur nos serveurs',
              'Authentification par code PIN',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsPage(BoxConstraints constraints) {
    // Breakpoints ultra-agressifs cohérents
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    // Tailles d'icônes ultra-compactes
    final iconSize = isVeryCompact ? 80 : (isCompact ? 100 : 120);
    final iconInnerSize = isVeryCompact ? 40 : (isCompact ? 50 : 60);

    // Tailles de texte ultra-adaptatives
    final titleSize = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
    final subtitleSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);

    // Espacements ultra-réduits
    final titleSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);
    final subtitleSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final featureSpacing = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(adaptivePadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              math.max(0, constraints.maxHeight - (isVeryCompact ? 180 : 220)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: iconSize.toDouble(),
              height: iconSize.toDouble(),
              borderRadius: BorderRadius.circular(isVeryCompact ? 20 : 30),
              color: GlassColors.accent,
              opacity: 0.2,
              child: Icon(
                Icons.chat_bubble_outline,
                size: iconInnerSize.toDouble(),
                color: GlassColors.accent,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Salons Temporaires',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                height: isVeryCompact ? 1.2 : 1.3,
              ),
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              'Créez des salons sécurisés temporaires pour vos conversations. Chaque salon expire automatiquement pour une sécurité maximale.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: isVeryCompact ? 1.3 : 1.5,
              ),
            ),
            SizedBox(height: featureSpacing),
            _buildFeatureList([
              'Salons 1-to-1 uniquement',
              'Expiration automatique',
              'Partage par ID unique',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildEncryptionPage(BoxConstraints constraints) {
    // Breakpoints ultra-agressifs cohérents
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    // Tailles d'icônes ultra-compactes
    final iconSize = isVeryCompact ? 80 : (isCompact ? 100 : 120);
    final iconInnerSize = isVeryCompact ? 40 : (isCompact ? 50 : 60);

    // Tailles de texte ultra-adaptatives
    final titleSize = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
    final subtitleSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);

    // Espacements ultra-réduits
    final titleSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);
    final subtitleSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final stepsSpacing = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(adaptivePadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              math.max(0, constraints.maxHeight - (isVeryCompact ? 180 : 220)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: iconSize.toDouble(),
              height: iconSize.toDouble(),
              borderRadius: BorderRadius.circular(isVeryCompact ? 20 : 30),
              color: GlassColors.warning,
              opacity: 0.2,
              child: Icon(
                Icons.vpn_key_outlined,
                size: iconInnerSize.toDouble(),
                color: GlassColors.warning,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Comment ça marche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                height: isVeryCompact ? 1.2 : 1.3,
              ),
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              'Tapez votre message, il sera chiffré automatiquement. Copiez le résultat et envoyez-le via n\'importe quelle application.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: isVeryCompact ? 1.3 : 1.5,
              ),
            ),
            SizedBox(height: stepsSpacing),
            _buildStepsList([
              'Créez ou rejoignez un salon',
              'Tapez votre message',
              'Le message est chiffré automatiquement',
              'Copiez et envoyez via WhatsApp, SMS...',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyPage(BoxConstraints constraints) {
    // Breakpoints ultra-agressifs cohérents
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 24.0);

    // Tailles d'icônes ultra-compactes
    final iconSize = isVeryCompact ? 80 : (isCompact ? 100 : 120);
    final iconInnerSize = isVeryCompact ? 40 : (isCompact ? 50 : 60);

    // Tailles de texte ultra-adaptatives
    final titleSize = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 28.0);
    final subtitleSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);
    final infoSize = isVeryCompact ? 11.0 : (isCompact ? 12.0 : 14.0);

    // Espacements ultra-réduits
    final titleSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);
    final subtitleSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final infoSpacing = isVeryCompact ? 16.0 : (isCompact ? 24.0 : 32.0);

    // Tailles d'icônes info
    final infoIconSize = isVeryCompact ? 18.0 : (isCompact ? 20.0 : 24.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(adaptivePadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              math.max(0, constraints.maxHeight - (isVeryCompact ? 180 : 220)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: iconSize.toDouble(),
              height: iconSize.toDouble(),
              borderRadius: BorderRadius.circular(isVeryCompact ? 20 : 30),
              color: GlassColors.secondary,
              opacity: 0.2,
              child: Icon(
                Icons.check_circle_outline,
                size: iconInnerSize.toDouble(),
                color: GlassColors.secondary,
              ),
            ),
            SizedBox(height: titleSpacing),
            Text(
              'Vous êtes prêt !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                height: isVeryCompact ? 1.2 : 1.3,
              ),
            ),
            SizedBox(height: subtitleSpacing),
            Text(
              'Configurez maintenant votre code PIN pour sécuriser l\'accès à SecureChat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: isVeryCompact ? 1.3 : 1.5,
              ),
            ),
            SizedBox(height: infoSpacing),
            GlassContainer(
              padding:
                  EdgeInsets.all(isVeryCompact ? 10 : (isCompact ? 12 : 16)),
              color: GlassColors.primary,
              opacity: 0.1,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: GlassColors.primary,
                    size: infoIconSize,
                  ),
                  SizedBox(width: isVeryCompact ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Votre code PIN sera votre seule façon d\'accéder à l\'application. Choisissez-le bien !',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: infoSize,
                        height: isVeryCompact ? 1.3 : 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    // Breakpoints ultra-agressifs pour les listes
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Tailles adaptatives pour les listes
    final iconSize = isVeryCompact ? 16.0 : (isCompact ? 18.0 : 20.0);
    final fontSize = isVeryCompact ? 12.0 : (isCompact ? 13.0 : 14.0);
    final verticalPadding = isVeryCompact ? 2.0 : (isCompact ? 3.0 : 4.0);
    final horizontalSpacing = isVeryCompact ? 8.0 : (isCompact ? 10.0 : 12.0);

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: GlassColors.secondary,
                size: iconSize,
              ),
              SizedBox(width: horizontalSpacing),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: fontSize,
                    height: isVeryCompact ? 1.3 : 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsList(List<String> steps) {
    // Breakpoints ultra-agressifs pour les étapes
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Tailles adaptatives pour les étapes
    final circleSize = isVeryCompact ? 20.0 : (isCompact ? 22.0 : 24.0);
    final numberFontSize = isVeryCompact ? 10.0 : (isCompact ? 11.0 : 12.0);
    final textFontSize = isVeryCompact ? 12.0 : (isCompact ? 13.0 : 14.0);
    final verticalPadding = isVeryCompact ? 4.0 : (isCompact ? 5.0 : 6.0);
    final horizontalSpacing = isVeryCompact ? 8.0 : (isCompact ? 10.0 : 12.0);
    final borderWidth = isVeryCompact ? 1.5 : 2.0;

    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        String step = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: GlassColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GlassColors.primary,
                    width: borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: GlassColors.primary,
                      fontSize: numberFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: horizontalSpacing),
              Expanded(
                child: Text(
                  step,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: textFontSize,
                    height: isVeryCompact ? 1.3 : 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    // Breakpoints ultra-agressifs pour les boutons
    final screenHeight = MediaQuery.of(context).size.height;
    final isVeryCompact = screenHeight < 700; // iPhone SE
    final isCompact = screenHeight < 800; // iPhone Standard

    // Padding adaptatif ultra-réduit
    final adaptivePadding = isVeryCompact ? 16.0 : (isCompact ? 20.0 : 24.0);

    // Hauteur des boutons adaptative - AUGMENTÉE pour éviter les boutons coupés
    final buttonHeight = isVeryCompact ? 48.0 : (isCompact ? 52.0 : 56.0);

    // Taille de police adaptative
    final fontSize = isVeryCompact ? 15.0 : (isCompact ? 16.0 : 17.0);

    // Espacement entre boutons adaptatif
    final buttonSpacing = isVeryCompact ? 16.0 : (isCompact ? 18.0 : 20.0);

    return Padding(
      padding: EdgeInsets.all(adaptivePadding),
      child: Row(
        children: [
          // Bouton Précédent
          if (_currentPage > 0) ...[
            Expanded(
              child: GlassButton(
                height: buttonHeight,
                color: Colors.white,
                onTap: _previousPage,
                child: Text(
                  'Précédent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: buttonSpacing),
          ] else ...[
            const Expanded(child: SizedBox()),
          ],

          // Bouton Suivant/Commencer
          Expanded(
            child: GlassButton(
              height: buttonHeight,
              color: GlassColors.primary,
              onTap: _nextPage,
              child: Text(
                _currentPage == _totalPages - 1 ? 'Commencer' : 'Suivant',
                style: TextStyle(
                  color: GlassColors.primary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
