import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../widgets/glass_container.dart';
import '../animations/page_transitions.dart';
import '../theme.dart';
import 'room_chat_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage>
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
      backgroundColor: GlassColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        title: Text(
          'Créer un salon',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône et titre
                Center(
                  child: Column(
                    children: [
                      GlassContainer(
                        width: 80,
                        height: 80,
                        borderRadius: BorderRadius.circular(20),
                        color: GlassColors.primary,
                        opacity: 0.2,
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 40,
                          color: GlassColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nouveau salon sécurisé',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configurez votre salon temporaire',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Sélection de durée
                Text(
                  'Durée d\'expiration',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                _buildDurationSelector(),

                const SizedBox(height: 32),

                // Information de sécurité
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  color: GlassColors.secondary,
                  opacity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: GlassColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sécurité maximale',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Salon limité à 2 participants maximum\n'
                        '• Expiration automatique après la durée choisie\n'
                        '• Chiffrement AES-256 de bout en bout\n'
                        '• Aucune donnée stockée sur nos serveurs',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bouton de création
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    height: 56,
                    color: GlassColors.primary,
                    opacity: 0.2,
                    onTap: _isCreating ? null : _createRoom,
                    child: _isCreating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: GlassColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Créer le salon',
                            style: TextStyle(
                              color: GlassColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildDurationSelector() {
    final durations = [
      {'hours': 1, 'label': '1 heure'},
      {'hours': 3, 'label': '3 heures'},
      {'hours': 6, 'label': '6 heures'},
      {'hours': 12, 'label': '12 heures'},
      {'hours': 24, 'label': '24 heures'},
    ];

    return Column(
      children: durations.map((duration) {
        final hours = duration['hours'] as int;
        final label = duration['label'] as String;
        final isSelected = _selectedDuration == hours;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = hours;
              });
              HapticFeedback.lightImpact();
            },
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              color: isSelected ? GlassColors.primary : Colors.white,
              opacity: isSelected ? 0.2 : 0.05,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? GlassColors.primary
                            : Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      color:
                          isSelected ? GlassColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? GlassColors.primary
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.schedule,
                      color: GlassColors.primary,
                      size: 20,
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
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final room = await roomProvider.createAndJoinRoom(
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
