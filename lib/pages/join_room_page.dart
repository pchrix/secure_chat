import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/room_provider_riverpod.dart';
import '../widgets/glass_components.dart';
import '../widgets/animated_background.dart';
import '../animations/enhanced_micro_interactions.dart';
import '../animations/page_transitions.dart';
import '../theme.dart';
import 'room_chat_page.dart';

class JoinRoomPage extends ConsumerStatefulWidget {
  const JoinRoomPage({super.key});

  @override
  ConsumerState<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends ConsumerState<JoinRoomPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _roomIdController = TextEditingController();
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                return SingleChildScrollView(
                  reverse: true, // ✅ AJOUTÉ pour keyboard avoidance
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48 - keyboardHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Enhanced Glass AppBar
                          _buildGlassAppBar(),

                          // Enhanced Hero Section
                          MorphTransition(
                            child: _buildHeroSection(),
                          ),

                          const SizedBox(height: AppSizes.buttonHeightSm),

                          // Enhanced Input Section
                          WaveSlideAnimation(
                            index: 1,
                            child: _buildInputSection(),
                          ),

                          const AppSpacing.vGapXl,

                          // Enhanced Instructions
                          WaveSlideAnimation(
                            index: 2,
                            child: _buildInstructions(),
                          ),

                          const AppSpacing.vGapXl,

                          // Enhanced Action Buttons
                          WaveSlideAnimation(
                            index: 3,
                            child: _buildActionButtons(),
                          ),

                          const AppSpacing.vGapLg,
                        ],
                      ),
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

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        _roomIdController.text = clipboardData!.text!.toUpperCase();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Ignorer les erreurs de presse-papiers
    }
  }

  bool _isValidRoomId(String roomId) {
    // Vérifier le format de l'ID (6 caractères alphanumériques)
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(roomId.toUpperCase());
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Enhanced Back Button
          EnhancedGlassButton(
            width: AppSizes.iconXxl,
            height: AppSizes.buttonHeightMd,
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
            color: AppColors.primary,
            onTap: () => Navigator.of(context).pop(),
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
              'Rejoindre un salon',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSize3xl,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const Spacer(),

          // Placeholder for balance
          const SizedBox(width: AppSizes.iconXxl),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          // Enhanced Icon with Breathing Animation
          BreathingPulseAnimation(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.meeting_room_outlined,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const AppSpacing.vGapLg,

          // Enhanced Title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.secondaryGradient.createShader(bounds),
            child: const Text(
              'Rejoindre une conversation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Enhanced Subtitle
          const Text(
            'Saisissez l\'ID du salon partagé\npar votre correspondant',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppTypography.fontSizeLg,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
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
                  Icons.key,
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
                      'ID du salon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.fontSizeXl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Code à 6 caractères (ex: ABC123)',
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

          // Enhanced Input Field
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: _errorMessage != null
                    ? AppColors.error.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _roomIdController,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 100,
              ), // ✅ AJOUTÉ pour keyboard avoidance
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTypography.fontSizeXl,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: AppTypography.fontSizeXl,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
                counterText: '',
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: EnhancedGlassButton(
                    width: AppSizes.iconXl,
                    height: AppSizes.buttonHeightSm,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    color: AppColors.secondary,
                    onTap: _pasteFromClipboard,
                    child: const Icon(
                      Icons.paste,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Comment rejoindre ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSizeLg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const AppSpacing.vGapMd,
          _buildInstructionStep(
              '1', 'Demandez l\'ID du salon à votre correspondant'),
          const SizedBox(height: 12),
          _buildInstructionStep(
              '2', 'Saisissez le code de 6 caractères ci-dessus'),
          const SizedBox(height: 12),
          _buildInstructionStep(
              '3', 'Appuyez sur "Rejoindre" pour accéder au salon'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppSizes.iconMd,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppTypography.fontSizeMd,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Join Button
        SizedBox(
          width: double.infinity,
          child: EnhancedGlassButton(
            height: 60,
            color: AppColors.secondary,
            onTap: _isJoining ? null : _joinRoom,
            child: _isJoining
                ? const SizedBox(
                    width: AppSizes.iconMd,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Rejoindre le salon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.fontSizeXl,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const AppSpacing.vGapMd,

        // Alternative action
        SizedBox(
          width: double.infinity,
          child: EnhancedGlassButton(
            height: 50,
            color: Colors.white,
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Créer un nouveau salon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
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

  Future<void> _joinRoom() async {
    final roomId = _roomIdController.text.trim().toUpperCase();

    if (roomId.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir un ID de salon';
      });
      return;
    }

    if (!_isValidRoomId(roomId)) {
      setState(() {
        _errorMessage = 'ID de salon invalide (6 caractères requis)';
      });
      return;
    }

    if (_isJoining) return;

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final room =
          await ref.read(roomProvider.notifier).joinAndSetCurrentRoom(roomId);

      if (room != null && mounted) {
        // Naviguer vers la page de chat avec le salon rejoint
        Navigator.of(context).pushReplacementSlideFromRight(
          RoomChatPage(roomId: room.id),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = ref.read(roomProvider).error ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la connexion: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
}
