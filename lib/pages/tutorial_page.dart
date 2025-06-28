import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_components.dart';
import '../utils/responsive_utils.dart'; // ✅ AJOUTÉ pour responsive design unifié
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
                  // Header avec bouton Skip
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SecureChat',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentPage > 0)
                          GestureDetector(
                            onTap: _skipTutorial,
                            child: Text(
                              'Passer',
                              style: TextStyle(
                                color:
                                    GlassColors.primary.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
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
    final isCompactLayout = ResponsiveUtils.isVeryCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              constraints.maxHeight - 200, // Espace pour header et boutons
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: isCompactLayout ? 100 : 120,
              height: isCompactLayout ? 100 : 120,
              borderRadius: BorderRadius.circular(30),
              color: GlassColors.primary,
              opacity: 0.2,
              child: Icon(
                Icons.security,
                size: isCompactLayout ? 50 : 60,
                color: GlassColors.primary,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            Text(
              'Bienvenue dans SecureChat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isCompactLayout ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompactLayout ? 12 : 16),
            Text(
              'Votre nouvelle application de messagerie sécurisée avec chiffrement de bout en bout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: isCompactLayout ? 14 : 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityPage(BoxConstraints constraints) {
    final isCompactLayout = ResponsiveUtils.isVeryCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: isCompactLayout ? 100 : 120,
              height: isCompactLayout ? 100 : 120,
              borderRadius: BorderRadius.circular(30),
              color: GlassColors.secondary,
              opacity: 0.2,
              child: Icon(
                Icons.lock_outline,
                size: isCompactLayout ? 50 : 60,
                color: GlassColors.secondary,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            Text(
              'Sécurité Maximale',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isCompactLayout ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompactLayout ? 12 : 16),
            Text(
              'Vos conversations sont protégées par un chiffrement AES-256 de niveau militaire. Seuls vous et votre correspondant pouvez lire les messages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: isCompactLayout ? 14 : 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: isCompactLayout ? 16 : 24),
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
    final isCompactLayout = ResponsiveUtils.isVeryCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: isCompactLayout ? 100 : 120,
              height: isCompactLayout ? 100 : 120,
              borderRadius: BorderRadius.circular(30),
              color: GlassColors.accent,
              opacity: 0.2,
              child: Icon(
                Icons.chat_bubble_outline,
                size: isCompactLayout ? 50 : 60,
                color: GlassColors.accent,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            Text(
              'Salons Temporaires',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isCompactLayout ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompactLayout ? 12 : 16),
            Text(
              'Créez des salons sécurisés temporaires pour vos conversations. Chaque salon expire automatiquement pour une sécurité maximale.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: isCompactLayout ? 14 : 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: isCompactLayout ? 16 : 24),
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
    final isCompactLayout = ResponsiveUtils.isVeryCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: isCompactLayout ? 100 : 120,
              height: isCompactLayout ? 100 : 120,
              borderRadius: BorderRadius.circular(30),
              color: GlassColors.warning,
              opacity: 0.2,
              child: Icon(
                Icons.vpn_key_outlined,
                size: isCompactLayout ? 50 : 60,
                color: GlassColors.warning,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            Text(
              'Comment ça marche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isCompactLayout ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompactLayout ? 12 : 16),
            Text(
              'Tapez votre message, il sera chiffré automatiquement. Copiez le résultat et envoyez-le via n\'importe quelle application.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: isCompactLayout ? 14 : 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: isCompactLayout ? 16 : 24),
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
    final isCompactLayout = ResponsiveUtils.isVeryCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              width: isCompactLayout ? 100 : 120,
              height: isCompactLayout ? 100 : 120,
              borderRadius: BorderRadius.circular(30),
              color: GlassColors.secondary,
              opacity: 0.2,
              child: Icon(
                Icons.check_circle_outline,
                size: isCompactLayout ? 50 : 60,
                color: GlassColors.secondary,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            Text(
              'Vous êtes prêt !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: isCompactLayout ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompactLayout ? 12 : 16),
            Text(
              'Configurez maintenant votre code PIN pour sécuriser l\'accès à SecureChat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: isCompactLayout ? 14 : 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: isCompactLayout ? 24 : 32),
            GlassContainer(
              padding: EdgeInsets.all(isCompactLayout ? 12 : 16),
              color: GlassColors.primary,
              opacity: 0.1,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: GlassColors.primary,
                    size: isCompactLayout ? 20 : 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre code PIN sera votre seule façon d\'accéder à l\'application. Choisissez-le bien !',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: isCompactLayout ? 12 : 14,
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
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: GlassColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
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
    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        String step = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: GlassColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GlassColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: GlassColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Bouton Précédent
          if (_currentPage > 0) ...[
            Expanded(
              child: GlassButton(
                height: 48,
                color: Colors.white,
                onTap: _previousPage,
                child: const Text(
                  'Précédent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ] else ...[
            const Expanded(child: SizedBox()),
          ],

          // Bouton Suivant/Commencer
          Expanded(
            child: GlassButton(
              height: 48,
              color: GlassColors.primary,
              onTap: _nextPage,
              child: Text(
                _currentPage == _totalPages - 1 ? 'Commencer' : 'Suivant',
                style: const TextStyle(
                  color: GlassColors.primary,
                  fontSize: 16,
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
