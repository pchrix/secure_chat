import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/secret_access_config.dart';
import '../widgets/change_password_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Accordion animation controller
  late AnimationController _accordionController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  // Accordion state
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize accordion animation controller
    _accordionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _accordionController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _accordionController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accordionController.dispose();
    super.dispose();
  }

  void _toggleAccordion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _accordionController.forward();
    } else {
      _accordionController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Title
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Home button (return to home)
                    GestureDetector(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pop(); // Pop twice to go back to home
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<AppStateProvider>(
                    builder: (context, provider, child) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Secret Access Configuration Section (Accordion)
                            _buildSecretAccessAccordion(provider),

                            const SizedBox(height: 32),

                            // Version info
                            _buildVersionInfo(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecretAccessAccordion(AppStateProvider provider) {
    final config = provider.secretAccessConfig;

    return AnimatedBuilder(
      animation: _accordionController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              // Accordion Header (always visible)
              _buildAccordionHeader(config),

              // Expandable Content
              ClipRect(
                child: SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: _buildAccordionContent(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccordionHeader(SecretAccessConfig config) {
    // Configuration description for password authentication
    String currentConfig = 'Mot de passe numérique (4-6 chiffres)';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleAccordion,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Security icon
              Icon(
                Icons.security,
                color: const Color(0xFF9B59B6),
                size: 24,
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mot de passe d\'authentification',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentConfig,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron icon with rotation animation
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value *
                        3.14159, // 180 degrees in radians
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionContent(AppStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.1),
            margin: const EdgeInsets.only(bottom: 20),
          ),

          // Current configuration display
          _buildCurrentConfigDisplay(provider.secretAccessConfig),

          const SizedBox(height: 20),

          // Password configuration options
          _buildPasswordConfigurationOptions(),
        ],
      ),
    );
  }

  Widget _buildCurrentConfigDisplay(SecretAccessConfig config) {
    String description =
        'Authentification par mot de passe numérique de 4 à 6 chiffres';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration actuelle:',
            style: TextStyle(
              color: Color(0xFF9B59B6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordConfigurationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion du mot de passe:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Change password option
        _buildPasswordOption(
          'Modifier le mot de passe',
          'Changer votre mot de passe actuel',
          Icons.edit,
          _showChangePasswordDialog,
        ),
      ],
    );
  }

  Widget _buildPasswordOption(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF2E86AB),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}
