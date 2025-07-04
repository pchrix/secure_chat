import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../providers/room_provider_riverpod.dart';
import '../services/encryption_service.dart';
import '../services/room_key_service.dart';
import '../core/providers/service_providers.dart';
import '../utils/security_utils.dart';
import '../widgets/glass_components.dart';
import '../widgets/animated_background.dart';
import '../animations/enhanced_micro_interactions.dart';
import '../theme.dart';

class RoomChatPage extends ConsumerStatefulWidget {
  final String roomId;

  const RoomChatPage({
    super.key,
    required this.roomId,
  });

  @override
  ConsumerState<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends ConsumerState<RoomChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  // ✅ OPTIMISATION: Cache des valeurs responsive pour éviter MediaQuery répétés
  late double _screenHeight;
  late bool _isVeryCompact;
  late bool _isCompact;

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
    _initializeKey();
    _checkClipboard();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ OPTIMISATION: Cache les valeurs responsive une seule fois
    _screenHeight = MediaQuery.of(context).size.height;
    _isVeryCompact = _screenHeight < 700;
    _isCompact = _screenHeight < 800;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _resultController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeKey() async {
    // Vérifier si une clé existe pour ce salon et la générer si nécessaire
    final keyService = ref.read(roomKeyServiceProvider);
    final hasKey = await keyService.hasKeyForRoom(widget.roomId);
    if (!hasKey) {
      try {
        // Générer automatiquement une clé pour le salon
        await keyService.generateKeyForRoom(widget.roomId);
        if (mounted) {
          setState(() {
            // Trigger un rebuild pour afficher la clé disponible
          });
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Erreur lors de la génération de la clé: $e');
        }
      }
    }
  }

  Future<void> _checkClipboard() async {
    final clipboardText = await SecurityUtils.getFromClipboard();
    if (clipboardText != null &&
        EncryptionService.isValidEncryptedMessage(clipboardText)) {
      setState(() {
        _resultController.text = clipboardText;
      });
      _showSnackBar('Message chiffré détecté dans le presse-papiers');
    }
  }

  Future<void> _encryptMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Veuillez saisir un message à chiffrer');
      return;
    }

    // Utiliser directement le service de clés du salon
    final keyService = ref.read(roomKeyServiceProvider);
    final encryptedText = await keyService
        .encryptMessageForRoom(widget.roomId, text);

    if (encryptedText == null) {
      _showSnackBar(
          'Aucune clé disponible pour ce salon. Générez une clé d\'abord.');
      return;
    }

    setState(() {
      _resultController.text = encryptedText;
    });
    await SecurityUtils.copyToClipboard(encryptedText);
    _showSnackBar('Message chiffré et copié dans le presse-papiers');
  }

  Future<void> _decryptMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Veuillez saisir un message chiffré à déchiffrer');
      return;
    }

    // Utiliser directement le service de clés du salon
    final keyService = ref.read(roomKeyServiceProvider);
    final decryptedText = await keyService
        .decryptMessageForRoom(widget.roomId, text);

    if (decryptedText == null) {
      _showSnackBar(
          'Échec du déchiffrement: Message invalide ou aucune clé pour ce salon');
      return;
    }

    setState(() {
      _resultController.text = decryptedText;
    });
    _showSnackBar('Message déchiffré avec succès');
  }

  void _clearMessage() {
    setState(() {
      _messageController.clear();
      _resultController.clear();
    });
  }

  Future<void> _copyResult() async {
    final text = _resultController.text;
    if (text.isEmpty) return;

    await SecurityUtils.copyToClipboard(text);
    _showSnackBar('Résultat copié dans le presse-papiers');
  }

  Future<void> _shareRoomId() async {
    await SecurityUtils.copyToClipboard(widget.roomId);
    _showSnackBar('ID du salon copié: ${widget.roomId}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    Room? room;
    try {
      room = roomState.rooms.firstWhere((r) => r.id == widget.roomId);
    } catch (e) {
      room = null;
    }

    // Gérer les états de chargement et d'erreur
    if (roomState.isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedBackground(
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (room == null) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: AnimatedBackground(
          child: Center(
            child: EnhancedGlassContainer(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const AppSpacing.vGapMd,
                  const Text(
                    'Salon non trouvé',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppSpacing.vGapSm,
                  const Text(
                    'Ce salon n\'existe pas ou a expiré',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: AppTypography.fontSizeLg,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const AppSpacing.vGapLg,
                  UnifiedGlassButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - keyboardHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Enhanced Glass AppBar
                          _buildEnhancedAppBar(room!),

                          // Enhanced Content
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // ✅ OPTIMISATION: Utiliser les valeurs cachées au lieu de MediaQuery répétés
                                // Espacements adaptatifs ultra-réduits
                                final contentPadding = _isVeryCompact
                                    ? const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs) // Divisé par 2
                                    : _isCompact
                                        ? const EdgeInsets.all(AppSpacing.md) // Réduit
                                        : const EdgeInsets.all(AppSpacing.lg); // Normal

                                final mainSpacing = _isVeryCompact
                                    ? 12.0
                                    : (_isCompact ? 16.0 : 24.0);
                                final secondarySpacing = _isVeryCompact
                                    ? 8.0
                                    : (_isCompact ? 12.0 : 16.0);

                                return Padding(
                                  padding: contentPadding,
                                  child: Column(
                                    children: [
                                      // Enhanced Room Status
                                      WaveSlideAnimation(
                                        index: 0,
                                        child: _buildRoomStatusCard(room!),
                                      ),

                                      SizedBox(height: mainSpacing),

                                      // Enhanced Message Input Area
                                      Expanded(
                                        flex: 2,
                                        child: WaveSlideAnimation(
                                          index: 1,
                                          child: _buildMessageInputArea(),
                                        ),
                                      ),

                                      SizedBox(height: secondarySpacing),

                                      // Enhanced Result Area
                                      Expanded(
                                        flex: 2,
                                        child: WaveSlideAnimation(
                                          index: 2,
                                          child: _buildResultArea(),
                                        ),
                                      ),

                                      SizedBox(height: mainSpacing),

                                      // Enhanced Action Buttons
                                      WaveSlideAnimation(
                                        index: 3,
                                        child: _buildActionButtons(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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

  Widget _buildEnhancedAppBar(Room room) {
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

          const SizedBox(width: AppSizes.iconXs),

          // Enhanced Room Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'Salon #${room.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(room.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      room.statusDisplay,
                      style: TextStyle(
                        color: _getStatusColor(room.status),
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Enhanced Share Button
          EnhancedGlassButton(
            width: AppSizes.iconXxl,
            height: AppSizes.buttonHeightMd,
            padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
            color: AppColors.secondary,
            onTap: _shareRoomId,
            child: const Icon(
              Icons.share,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStatusCard(Room room) {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
      child: Row(
        children: [
          // Enhanced Security Icon
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
              Icons.security,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: AppSizes.iconXs),

          // Room Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chiffrement actif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AES-256 • Messages sécurisés',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: AppTypography.fontSizeMd,
                  ),
                ),
              ],
            ),
          ),

          // Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: room.isExpired
                    ? [
                        AppColors.error.withValues(alpha: 0.2),
                        AppColors.error.withValues(alpha: 0.1)
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.1)
                      ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color:
                    room.isExpired ? AppColors.error : AppColors.primary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  color:
                      room.isExpired ? AppColors.error : AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  room.isExpired
                      ? 'Expiré'
                      : _formatTimeRemaining(room.timeRemaining),
                  style: TextStyle(
                    color: room.isExpired
                        ? AppColors.error
                        : AppColors.primary,
                    fontSize: AppTypography.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ OPTIMISATION: Utiliser les valeurs cachées au lieu de MediaQuery répétés
        // Espacements adaptatifs ultra-réduits
        final containerPadding = _isVeryCompact
            ? const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs) // Divisé par 2
            : _isCompact
                ? const EdgeInsets.all(AppSpacing.md) // Réduit
                : const EdgeInsets.all(AppSpacing.lg); // Normal

        final headerSpacing = _isVeryCompact ? 8.0 : (_isCompact ? 12.0 : 20.0);
        final iconSpacing = _isVeryCompact ? 8.0 : (_isCompact ? 10.0 : 12.0);

        return EnhancedGlassContainer(
          width: double.infinity,
          padding: containerPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: AppSizes.iconXl,
                    height: AppSizes.buttonHeightSm,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: iconSpacing),
                  const Text(
                    'Votre message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              SizedBox(height: headerSpacing),

              // Enhanced Input Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                    ), // ✅ AJOUTÉ pour keyboard avoidance
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeLg,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Tapez votre message ici...\nIl sera chiffré automatiquement avant l\'envoi',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: AppTypography.fontSizeLg,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ OPTIMISATION: Utiliser les valeurs cachées au lieu de MediaQuery répétés
        // Espacements adaptatifs ultra-réduits
        final containerPadding = _isVeryCompact
            ? const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs) // Divisé par 2
            : _isCompact
                ? const EdgeInsets.all(AppSpacing.md) // Réduit
                : const EdgeInsets.all(AppSpacing.lg); // Normal

        final iconSpacing = _isVeryCompact ? 8.0 : (_isCompact ? 10.0 : 12.0);

        return EnhancedGlassContainer(
          width: double.infinity,
          padding: containerPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Copy Button
              Row(
                children: [
                  Container(
                    width: AppSizes.iconXl,
                    height: AppSizes.buttonHeightSm,
                    decoration: BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.lock_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: iconSpacing),
                  const Text(
                    'Résultat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_resultController.text.isNotEmpty)
                    EnhancedGlassButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: AppColors.secondary,
                      onTap: () {
                        _copyResult();
                        HapticFeedback.lightImpact();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Copier',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTypography.fontSizeMd,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Enhanced Result Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _resultController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    readOnly: true,
                    scrollPadding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                    ), // ✅ AJOUTÉ pour keyboard avoidance
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSizeLg,
                      height: 1.5,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Le résultat du chiffrement/déchiffrement\napparaîtra ici...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: AppTypography.fontSizeLg,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xs),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Encrypt Button
        Expanded(
          child: EnhancedGlassButton(
            height: AppSizes.buttonHeightLg,
            color: AppColors.primary,
            onTap: _encryptMessage,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Chiffrer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSizes.iconXs),

        // Decrypt Button
        Expanded(
          child: EnhancedGlassButton(
            height: AppSizes.buttonHeightLg,
            color: AppColors.secondary,
            onTap: _decryptMessage,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Déchiffrer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSizes.iconXs),

        // Clear Button
        EnhancedGlassButton(
          width: 56,
          height: AppSizes.buttonHeightLg,
          padding: const EdgeInsets.all(AppSpacing.md),
          color: Colors.white,
          onTap: _clearMessage,
          child: Icon(
            Icons.clear_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 22,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return AppColors.warning;
      case RoomStatus.active:
        return AppColors.secondary;
      case RoomStatus.expired:
        return AppColors.error;
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
