import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/glass_components.dart';
import '../widgets/animated_background.dart';
import '../animations/enhanced_micro_interactions.dart';
import '../utils/responsive_utils.dart'; // ✅ AJOUTÉ pour responsive design
import '../theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
      body: AnimatedBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Enhanced Glass AppBar
                _buildGlassAppBar(),

                // Enhanced Settings Content avec LayoutBuilder responsive
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Utiliser ResponsiveUtils pour les espacements adaptatifs
                      final contentPadding =
                          ResponsiveUtils.getUltraAdaptivePadding(context);
                      final sectionSpacing =
                          ResponsiveUtils.getUltraAdaptiveSpacing(context);
                      final topSpacing =
                          ResponsiveUtils.getUltraAdaptiveSpacing(context,
                              veryCompact: 12.0, compact: 16.0, normal: 20.0);

                      return Padding(
                        padding: contentPadding,
                        child: Consumer(
                          builder: (context, ref, child) {
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: topSpacing),

                                  // Enhanced Password Management Section
                                  WaveSlideAnimation(
                                    index: 0,
                                    child: _buildEnhancedPasswordSection(),
                                  ),

                                  SizedBox(height: sectionSpacing),

                                  // Enhanced App Info Section
                                  WaveSlideAnimation(
                                    index: 1,
                                    child: _buildEnhancedAppInfoSection(),
                                  ),

                                  SizedBox(height: sectionSpacing),

                                  // Enhanced Version Info
                                  WaveSlideAnimation(
                                    index: 2,
                                    child: _buildEnhancedVersionInfo(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final appBarPadding = ResponsiveUtils.getUltraAdaptivePadding(context);

        return Padding(
          padding: appBarPadding,
          child: Row(
            children: [
              // Enhanced Back Button
              EnhancedGlassButton(
                width: AppSizes.iconXxl,
                height: AppSizes.buttonHeightMd,
                padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                color: AppColors.primary,
                onTap: () {
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const Spacer(),

              // Enhanced Title with Gradient
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'Paramètres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSize3xl,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const Spacer(),

              // Enhanced Home Button
              EnhancedGlassButton(
                width: AppSizes.iconXxl,
                height: AppSizes.buttonHeightMd,
                padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                color: AppColors.secondary,
                onTap: () {
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPasswordSection() {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Row(
            children: [
              Container(
                width: AppSizes.iconXxl,
                height: AppSizes.buttonHeightMd,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.iconXs),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sécurité',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSize2xl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Gestion de votre authentification',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTypography.fontSizeMd,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const AppSpacing.vGapLg,

          // Current Auth Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Authentification active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const AppSpacing.vGapSm,
                const Text(
                  'Code PIN numérique (4-6 chiffres)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ],
            ),
          ),

          const AppSpacing.vGapLg,

          // Action Button
          _buildEnhancedPasswordOption(
            'Modifier le mot de passe',
            'Changer votre code PIN de sécurité',
            Icons.edit_outlined,
            _showChangePasswordDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPasswordOption(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return EnhancedGlassButton(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
      color: AppColors.primary,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppSizes.iconXl,
            height: AppSizes.buttonHeightSm,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.iconXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.6),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppInfoSection() {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: AppSizes.iconXxl,
                height: AppSizes.buttonHeightMd,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.iconXs),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'À propos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSize2xl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Informations sur l\'application',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTypography.fontSizeMd,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // App Features
          _buildFeatureItem(
            Icons.lock,
            'Chiffrement AES-256',
            'Protection maximale de vos données',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.timer,
            'Salons temporaires',
            'Expiration automatique des conversations',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.phone_android,
            'Progressive Web App',
            'Disponible sur mobile et desktop',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedVersionInfo() {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const AppSpacing.vGapMd,
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'SecureChat',
              style: AppTextStyles.sectionTitle,
            ),
          ),
          const AppSpacing.vGapSm,
          Text(
            'Version 1.0.0',
            style: AppTextStyles.versionText,
          ),
          const SizedBox(height: 4),
          Text(
            'Messagerie sécurisée avec chiffrement de bout en bout',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
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
