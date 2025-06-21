import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/room_card.dart';
import '../widgets/animated_background.dart';
import '../animations/page_transitions.dart';
import '../animations/micro_interactions.dart';
import '../theme.dart';
import 'settings_page.dart';
import 'create_room_page.dart';
import 'join_room_page.dart';
import 'room_chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        final rooms = roomProvider.rooms;
        final isLoading = roomProvider.isLoading;
        final error = roomProvider.error;

        return Scaffold(
          body: AnimatedBackground(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => GlassColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: const Text(
                                'SecureChat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushSlideFromRight(
                                  const SettingsPage(),
                                );
                              },
                              icon: Icon(
                                Icons.settings_outlined,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Vos salons sécurisés',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      // Message d'erreur
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            color: GlassColors.danger,
                            opacity: 0.1,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: GlassColors.danger,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: const TextStyle(
                                      color: GlassColors.danger,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => roomProvider.clearError(),
                                  child: const Icon(
                                    Icons.close,
                                    color: GlassColors.danger,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Liste des salons ou état de chargement
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: GlassColors.primary,
                                ),
                              )
                            : rooms.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    itemCount: rooms.length,
                                    itemBuilder: (context, index) {
                                      final room = rooms[index];
                                      return SlideInAnimation(
                                        delay:
                                            Duration(milliseconds: index * 100),
                                        child: RoomCard(
                                          room: room,
                                          onTap: () => _navigateToRoom(room),
                                          onDelete: () =>
                                              _deleteRoom(room, roomProvider),
                                        ),
                                      );
                                    },
                                  ),
                      ),

                      // Boutons d'action
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Bouton Créer un salon
                            BounceAnimation(
                              onTap: () => _navigateToCreateRoom(),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: GlassColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GlassColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToCreateRoom(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Créer un salon',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bouton Rejoindre un salon
                            BounceAnimation(
                              onTap: () => _navigateToJoinRoom(),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: GlassColors.secondaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GlassColors.secondary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToJoinRoom(),
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Rejoindre un salon',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier salon sécurisé\npour commencer à échanger',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
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

  void _deleteRoom(Room room, RoomProvider roomProvider) {
    roomProvider.deleteRoom(room.id);
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
