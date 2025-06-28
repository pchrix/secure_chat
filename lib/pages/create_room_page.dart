import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/room_provider_riverpod.dart';
import '../widgets/glass_components.dart';
import '../widgets/animated_background.dart';
import '../animations/enhanced_micro_interactions.dart';
import '../animations/page_transitions.dart';
import '../theme.dart';
import 'room_chat_page.dart';

class CreateRoomPage extends ConsumerStatefulWidget {
  const CreateRoomPage({super.key});

  @override
  ConsumerState<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends ConsumerState<CreateRoomPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedDuration = 6; // Durée par défaut en heures
  bool _isCreating = false;

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

                // Enhanced Content avec LayoutBuilder pour responsive - SOLUTION CRITIQUE
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculer la hauteur disponible pour le contenu
                      final availableHeight = constraints.maxHeight;
                      final isCompactLayout = availableHeight <
                          500; // ✅ Breakpoint ultra-agressif pour iPhone SE

                      return Column(
                        children: [
                          // Contenu scrollable
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),

                                  // Enhanced Hero Section (compacte)
                                  MorphTransition(
                                    child: _buildCompactHeroSection(),
                                  ),

                                  SizedBox(height: isCompactLayout ? 16 : 24),

                                  // Enhanced Duration Section
                                  WaveSlideAnimation(
                                    index: 1,
                                    child: _buildDurationSection(),
                                  ),

                                  SizedBox(height: isCompactLayout ? 12 : 20),

                                  // Enhanced Security Info (compacte)
                                  WaveSlideAnimation(
                                    index: 2,
                                    child: _buildCompactSecurityInfo(),
                                  ),

                                  // Espacement pour éviter que le bouton soit caché
                                  SizedBox(height: isCompactLayout ? 80 : 100),
                                ],
                              ),
                            ),
                          ),

                          // Bouton fixe en bas - SOLUTION CRITIQUE
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.1),
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SafeArea(
                              top: false,
                              child: WaveSlideAnimation(
                                index: 3,
                                child: _buildCreateButton(),
                              ),
                            ),
                          ),
                        ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Row(
        children: [
          // Enhanced Back Button
          EnhancedGlassButton(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            color: GlassColors.primary,
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
                GlassColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Créer un salon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const Spacer(),

          // Placeholder for balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCompactHeroSection() {
    return Center(
      child: Column(
        children: [
          // Enhanced Icon with Breathing Animation (plus petit)
          BreathingPulseAnimation(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: GlassColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: GlassColors.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_circle_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Enhanced Title (plus petit)
          ShaderMask(
            shaderCallback: (bounds) =>
                GlassColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Nouveau salon sécurisé',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Enhanced Subtitle (plus compact)
          const Text(
            'Configurez votre salon temporaire\navec chiffrement de bout en bout',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durée d\'expiration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Le salon sera automatiquement supprimé',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        _buildEnhancedDurationSelector(),
      ],
    );
  }

  Widget _buildCompactSecurityInfo() {
    return EnhancedGlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compact
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: GlassColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: GlassColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sécurité maximale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Protection garantie',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Security Features compactes
          _buildCompactSecurityFeature(Icons.people_outline, 'Salon 1-to-1'),
          const SizedBox(height: 8),
          _buildCompactSecurityFeature(Icons.timer_outlined, 'Auto-expiration'),
          const SizedBox(height: 8),
          _buildCompactSecurityFeature(Icons.lock_outline, 'AES-256'),
          const SizedBox(height: 8),
          _buildCompactSecurityFeature(
              Icons.cloud_off_outlined, 'Zéro stockage'),
        ],
      ),
    );
  }

  Widget _buildCompactSecurityFeature(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.white70,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: EnhancedGlassButton(
        height: 60,
        color: GlassColors.primary,
        onTap: _isCreating ? null : _createRoom,
        child: _isCreating
            ? const SizedBox(
                width: 24,
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
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Créer le salon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEnhancedDurationSelector() {
    final durations = [
      {'hours': 1, 'label': '1 heure', 'icon': Icons.access_time},
      {'hours': 3, 'label': '3 heures', 'icon': Icons.schedule},
      {'hours': 6, 'label': '6 heures', 'icon': Icons.timer},
      {'hours': 12, 'label': '12 heures', 'icon': Icons.timer_3},
      {'hours': 24, 'label': '24 heures', 'icon': Icons.timer_10},
    ];

    return Column(
      children: durations.asMap().entries.map((entry) {
        final index = entry.key;
        final duration = entry.value;
        final hours = duration['hours'] as int;
        final label = duration['label'] as String;
        final icon = duration['icon'] as IconData;
        final isSelected = _selectedDuration == hours;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaveSlideAnimation(
            index: index,
            delay: Duration(milliseconds: 50),
            child: EnhancedGlassButton(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: isSelected ? GlassColors.primary : Colors.white,
              onTap: () {
                setState(() {
                  _selectedDuration = hours;
                });
                HapticFeedback.lightImpact();
              },
              child: Row(
                children: [
                  // Enhanced Radio Button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: GlassColors.primary,
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Label
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),

                  // Selection Indicator
                  if (isSelected)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _createRoom() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final room = await ref.read(roomProvider.notifier).createAndJoinRoom(
            durationHours: _selectedDuration,
          );

      if (room != null && mounted) {
        // Naviguer vers la page de chat avec le salon créé
        Navigator.of(context).pushReplacementSlideFromRight(
          RoomChatPage(roomId: room.id),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: GlassColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
