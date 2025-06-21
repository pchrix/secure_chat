import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';

import '../services/encryption_service.dart';
import '../services/room_key_service.dart';
import '../utils/security_utils.dart';
import '../widgets/glass_container.dart';
import '../theme.dart';

class RoomChatPage extends StatefulWidget {
  final String roomId;

  const RoomChatPage({
    super.key,
    required this.roomId,
  });

  @override
  State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

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
  void dispose() {
    _messageController.dispose();
    _resultController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeKey() {
    // Vérifier si une clé existe pour ce salon
    // L'interface affichera l'état approprié
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
    final encryptedText =
        RoomKeyService.instance.encryptMessageForRoom(widget.roomId, text);

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
    final decryptedText =
        RoomKeyService.instance.decryptMessageForRoom(widget.roomId, text);

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
        backgroundColor: GlassColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        final room = roomProvider.findRoomById(widget.roomId);

        if (room == null) {
          return Scaffold(
            backgroundColor: GlassColors.background,
            body: const Center(
              child: Text(
                'Salon non trouvé',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        }

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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salon #${room.id}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  room.statusDisplay,
                  style: TextStyle(
                    color: room.status == RoomStatus.active
                        ? GlassColors.secondary
                        : GlassColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              // Bouton partager ID
              IconButton(
                onPressed: _shareRoomId,
                icon: Icon(
                  Icons.share,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              // Timer d'expiration
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: room.isExpired
                      ? GlassColors.danger.withValues(alpha: 0.2)
                      : GlassColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: room.isExpired
                        ? GlassColors.danger
                        : GlassColors.primary,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: room.isExpired
                          ? GlassColors.danger
                          : GlassColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.isExpired
                          ? 'Expiré'
                          : _formatTimeRemaining(room.timeRemaining),
                      style: TextStyle(
                        color: room.isExpired
                            ? GlassColors.danger
                            : GlassColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Zone de saisie
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        opacity: 0.05,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Votre message',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Tapez votre message ici...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Zone de résultat
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        opacity: 0.05,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Résultat',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (_resultController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: _copyResult,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: GlassColors.secondary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.copy,
                                            color: GlassColors.secondary,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Copier',
                                            style: TextStyle(
                                              color: GlassColors.secondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: TextField(
                                controller: _resultController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                readOnly: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Le résultat apparaîtra ici...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            height: 48,
                            color: GlassColors.primary,
                            opacity: 0.2,
                            onTap: _encryptMessage,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: GlassColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Chiffrer',
                                  style: TextStyle(
                                    color: GlassColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton(
                            height: 48,
                            color: GlassColors.secondary,
                            opacity: 0.2,
                            onTap: _decryptMessage,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_open_outlined,
                                  color: GlassColors.secondary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Déchiffrer',
                                  style: TextStyle(
                                    color: GlassColors.secondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassButton(
                          width: 48,
                          height: 48,
                          color: Colors.white,
                          opacity: 0.1,
                          onTap: _clearMessage,
                          child: Icon(
                            Icons.clear,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
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
      },
    );
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
