import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../providers/room_provider_riverpod.dart';
import '../widgets/glass_components.dart';
import '../widgets/enhanced_room_card.dart';
import '../widgets/animated_background.dart';
import '../animations/page_transitions.dart';
import '../animations/micro_interactions.dart';
import '../animations/button_animations.dart';
import '../theme.dart';
import '../utils/ui_helpers.dart';
import '../utils/responsive_utils.dart';
import '../utils/accessibility_utils.dart';
import 'settings_page.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';
import 'room_chat_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();

    // MVP: Afficher message de bienvenue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UIHelpers.showWelcomeMessage(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomProvider);
    final rooms = roomState.rooms;
    final isLoading = roomState.isLoading;
    final error = roomState.error;

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ AJOUTÉ pour keyboard avoidance
      body: AnimatedBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: ResponsiveBuilder(
                builder: (context, deviceType) {
                  return _buildResponsiveLayout(
                      context, deviceType, rooms, isLoading, error);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    DeviceType deviceType,
    List<Room> rooms,
    bool isLoading,
    String? error,
  ) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isDesktop = deviceType == DeviceType.desktop;

    if (isDesktop) {
      return _buildDesktopLayout(context, rooms, isLoading, error, padding);
    } else {
      return _buildMobileLayout(context, rooms, isLoading, error, padding);
    }
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<Room> rooms,
    bool isLoading,
    String? error,
    EdgeInsets padding,
  ) {
    return Column(
      children: [
        // Header
        _buildHeader(context, padding),

        // Subtitle
        _buildSubtitle(context, padding),

        // Message d'erreur
        if (error != null) _buildErrorMessage(context, error),

        const SizedBox(height: 24),

        // Liste des salons ou état de chargement - Contrainte pour laisser place aux boutons
        Expanded(
          child: isLoading
              ? AccessibilityUtils.accessibleLoadingIndicator(
                  label: 'Chargement des salons',
                )
              : rooms.isEmpty
                  ? _buildEmptyState()
                  : _buildRoomsList(rooms),
        ),

        // Boutons d'action - Toujours visibles avec SafeArea
        SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom,
              top: 16,
            ),
            child: _buildActionButtons(context, EdgeInsets.zero),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    List<Room> rooms,
    bool isLoading,
    String? error,
    EdgeInsets padding,
  ) {
    return Row(
      children: [
        // Sidebar avec navigation - Largeur augmentée pour éviter l'overflow
        Container(
          width: 350, // Augmenté de 300 à 350 pour plus d'espace
          padding: padding,
          child: Column(
            children: [
              _buildHeader(context, EdgeInsets.zero),
              const SizedBox(height: 32),
              _buildActionButtons(context, EdgeInsets.zero),
              const Spacer(),
              if (error != null) _buildErrorMessage(context, error),
            ],
          ),
        ),

        // Contenu principal
        Expanded(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubtitle(context, EdgeInsets.zero),
                const SizedBox(height: 24),
                Expanded(
                  child: isLoading
                      ? AccessibilityUtils.accessibleLoadingIndicator(
                          label: 'Chargement des salons',
                        )
                      : rooms.isEmpty
                          ? _buildEmptyState()
                          : _buildRoomsList(rooms),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: AccessibilityUtils.accessibleHeader(
              label: 'SecureChat - Application de chat sécurisé',
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    GlassColors.primaryGradient.createShader(bounds),
                child: Text(
                  'SecureChat',
                  style: ResponsiveUtils.isMobile(context)
                      ? AppTextStyles.appTitle
                      : AppTextStyles.appTitle.copyWith(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 28,
                            tablet: 32,
                            desktop: 36,
                          ),
                        ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (!ResponsiveUtils.isMobile(context) ||
              MediaQuery.of(context).size.width > 300) ...[
            AccessibilityUtils.accessibleButton(
              onPressed: () => UIHelpers.showInstructions(context),
              semanticLabel: 'Afficher les instructions',
              tooltip: 'Instructions d\'utilisation',
              child: Icon(
                Icons.help_outline,
                color: Colors.white.withValues(alpha: 0.7),
                size: ResponsiveUtils.isMobile(context) ? 20 : 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          AccessibilityUtils.accessibleButton(
            onPressed: () {
              Navigator.of(context).pushSlideFromRight(
                const SettingsPage(),
              );
            },
            semanticLabel: 'Ouvrir les paramètres',
            tooltip: 'Paramètres de l\'application',
            child: Icon(
              Icons.settings_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: ResponsiveUtils.isMobile(context) ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Vos salons sécurisés',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AccessibilityUtils.accessibleErrorMessage(
        message: error,
        onRetry: () => ref.read(roomProvider.notifier).clearError(),
      ),
    );
  }

  Widget _buildRoomsList(List<Room> rooms) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.desktop) {
          // Grille pour desktop
          final gridConfig = ResponsiveUtils.getOrientationAwareGrid(context);
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridConfig.columns,
              childAspectRatio: gridConfig.aspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return SlideInAnimation(
                delay: Duration(milliseconds: index * 100),
                child: EnhancedRoomCard(
                  room: room,
                  onTap: () => _navigateToRoom(room),
                  onDelete: () => _deleteRoom(room),
                ),
              );
            },
          );
        } else {
          // Liste pour mobile/tablet
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return SlideInAnimation(
                delay: Duration(milliseconds: index * 100),
                child: EnhancedRoomCard(
                  room: room,
                  onTap: () => _navigateToRoom(room),
                  onDelete: () => _deleteRoom(room),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          final isDesktop = deviceType == DeviceType.desktop;

          return Column(
            children: [
              // Bouton Créer un salon avec animations
              ButtonPressAnimation(
                onTap: () => _navigateToCreateRoom(),
                child: ButtonHoverAnimation(
                  child: UnifiedGlassButton(
                    onTap: () => _navigateToCreateRoom(),
                    width: isDesktop ? 250 : double.infinity,
                    height: 56,
                    semanticLabel: 'Créer un nouveau salon sécurisé',
                    tooltip: 'Créer un salon',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Créer un salon',
                          style: AppTextStyles.buttonLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton Rejoindre un salon avec animations
              ButtonPressAnimation(
                onTap: () => _navigateToJoinRoom(),
                child: ButtonHoverAnimation(
                  child: UnifiedGlassButton(
                    onTap: () => _navigateToJoinRoom(),
                    width: isDesktop ? 250 : double.infinity,
                    height: 56,
                    semanticLabel: 'Rejoindre un salon existant',
                    tooltip: 'Rejoindre un salon',
                    color: GlassColors.secondary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.login,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rejoindre un salon',
                          style: AppTextStyles.buttonLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(30),
            color: GlassColors.primary,
            opacity: 0.1,
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: GlassColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun salon actif',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier salon sécurisé\npour commencer à échanger',
            textAlign: TextAlign.center,
            style: AppTextStyles.hintText,
          ),
        ],
      ),
    );
  }

  void _navigateToRoom(Room room) {
    Navigator.of(context).pushSlideFromRight(
      RoomChatPage(roomId: room.id),
    );
  }

  void _deleteRoom(Room room) {
    ref.read(roomProvider.notifier).deleteRoom(room.id);
  }

  void _navigateToCreateRoom() {
    Navigator.of(context).pushSlideFromRight(
      const CreateRoomPage(),
    );
  }

  void _navigateToJoinRoom() {
    Navigator.of(context).pushSlideFromRight(
      const JoinRoomPage(),
    );
  }
}
