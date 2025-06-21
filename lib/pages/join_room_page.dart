import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../widgets/glass_container.dart';
import '../animations/page_transitions.dart';
import '../theme.dart';
import 'room_chat_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage>
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
          'Rejoindre un salon',
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
                        color: GlassColors.secondary,
                        opacity: 0.2,
                        child: const Icon(
                          Icons.login,
                          size: 40,
                          color: GlassColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Rejoindre un salon',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saisissez l\'ID du salon partagé',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Champ ID du salon
                Text(
                  'ID du salon',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                GlassContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: Colors.white,
                  opacity: 0.05,
                  child: TextField(
                    controller: _roomIdController,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ex: ABC123',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _joinRoom(),
                  ),
                ),

                // Message d'erreur
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: GlassColors.danger,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: GlassColors.danger,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Instructions
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  color: GlassColors.accent,
                  opacity: 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: GlassColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comment ça marche',
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
                        '1. Demandez l\'ID du salon à votre correspondant\n'
                        '2. Saisissez l\'ID dans le champ ci-dessus\n'
                        '3. Appuyez sur "Rejoindre" pour accéder au salon\n'
                        '4. Commencez à échanger des messages chiffrés',
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

                // Boutons
                Row(
                  children: [
                    // Bouton Coller depuis le presse-papiers
                    Expanded(
                      child: GlassButton(
                        height: 48,
                        color: Colors.white,
                        opacity: 0.1,
                        onTap: _pasteFromClipboard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.content_paste,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Coller',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Bouton Rejoindre
                    Expanded(
                      flex: 2,
                      child: GlassButton(
                        height: 56,
                        color: GlassColors.secondary,
                        opacity: 0.2,
                        onTap: _isJoining ? null : _joinRoom,
                        child: _isJoining
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: GlassColors.secondary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Rejoindre',
                                style: TextStyle(
                                  color: GlassColors.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
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
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final room = await roomProvider.joinAndSetCurrentRoom(roomId);

      if (room != null && mounted) {
        // Naviguer vers la page de chat avec le salon rejoint
        Navigator.of(context).pushReplacementSlideFromRight(
          RoomChatPage(roomId: room.id),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = roomProvider.error ?? 'Erreur inconnue';
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
