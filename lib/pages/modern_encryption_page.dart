import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state_provider.dart';
import '../services/encryption_service.dart';
import '../utils/security_utils.dart';
import 'contacts_page.dart';
import 'settings_page.dart';

class ModernEncryptionPage extends StatefulWidget {
  const ModernEncryptionPage({super.key});

  @override
  State<ModernEncryptionPage> createState() => _ModernEncryptionPageState();
}

class _ModernEncryptionPageState extends State<ModernEncryptionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  String? _temporaryKey;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Subscription timer simulation
  late Timer _subscriptionTimer;
  Duration _remainingTime = const Duration(days: 23, hours: 14, minutes: 32);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _initializeKey();
    _checkClipboard();
    _startSubscriptionTimer();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _resultController.dispose();
    _animationController.dispose();
    _subscriptionTimer.cancel();
    super.dispose();
  }

  void _startSubscriptionTimer() {
    _subscriptionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        if (_remainingTime.inMinutes > 0) {
          _remainingTime = Duration(minutes: _remainingTime.inMinutes - 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _formatRemainingTime() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;

    if (days > 0) {
      return '${days}j ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  void _initializeKey() {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    if (provider.isKeyValid()) {
      setState(() {
        _temporaryKey = provider.temporaryKey;
      });
    }
  }

  Future<void> _checkClipboard() async {
    final clipboardText = await SecurityUtils.getFromClipboard();
    if (clipboardText != null &&
        EncryptionService.isValidEncryptedMessage(clipboardText)) {
      setState(() {
        _resultController.text = clipboardText;
      });
      _showSnackBar('Encrypted message found in clipboard');
    }
  }

  Future<void> _encryptMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Veuillez saisir un message à chiffrer');
      return;
    }

    if (_temporaryKey == null) {
      _generateNewKey();
    }

    try {
      final encryptedText =
          EncryptionService.encryptMessage(text, _temporaryKey!);

      setState(() {
        _resultController.text = encryptedText;
      });
      await SecurityUtils.copyToClipboard(encryptedText);
      _showSnackBar('Message chiffré et copié dans le presse-papiers');
    } catch (e) {
      _showSnackBar('Échec du chiffrement: ${e.toString()}');
    }
  }

  Future<void> _decryptMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Veuillez saisir un message chiffré à déchiffrer');
      return;
    }

    if (_temporaryKey == null) {
      _showSnackBar('Veuillez d\'abord générer une clé');
      return;
    }

    try {
      final decryptedText =
          EncryptionService.decryptMessage(text, _temporaryKey!);
      setState(() {
        _resultController.text = decryptedText;
      });
      _showSnackBar('Message déchiffré avec succès');
    } catch (e) {
      _showSnackBar('Échec du déchiffrement: Message invalide ou mauvaise clé');
    }
  }

  void _clearMessage() {
    setState(() {
      _messageController.clear();
      _resultController.clear();
    });
  }

  void _generateNewKey() {
    final newKey = EncryptionService.generateRandomKey();
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    provider.setTemporaryKey(newKey);

    setState(() {
      _temporaryKey = newKey;
    });

    _showSnackBar('Nouvelle clé de chiffrement générée (expire dans 6 heures)');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9B59B6),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _copyResult() async {
    final text = _resultController.text;
    if (text.isEmpty) return;

    await SecurityUtils.copyToClipboard(text);
    _showSnackBar('Result copied to clipboard');
  }

  void _navigateToContacts() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ContactsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _animationController.reverse();
        }
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFF1C1C1E), // Dark background like calculator
        body: FadeTransition(
          opacity: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Custom modern header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Settings button (left)
                      GestureDetector(
                        onTap: _navigateToSettings,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Subscription timer (center)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF9B59B6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF9B59B6),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRemainingTime(),
                              style: const TextStyle(
                                color: Color(0xFF9B59B6),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Contacts button (right)
                      GestureDetector(
                        onTap: _navigateToContacts,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_alt_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Input message area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Entrée',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Text input
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                                        hintText:
                                            'Saisissez votre message ou texte chiffré...',
                                        hintStyle: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.4),
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Result area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with copy button
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Sortie',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
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
                                              color: const Color(0xFF2E86AB)
                                                  .withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.copy,
                                                  color: Color(0xFF2E86AB),
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Copy',
                                                  style: TextStyle(
                                                    color: Color(0xFF2E86AB),
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
                                ),

                                // Result text
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                                        hintText:
                                            'Le résultat apparaîtra ici...',
                                        hintStyle: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.4),
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action buttons row: Encrypt | Clear | Decrypt (moved to bottom)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              // Encrypt button
                              Expanded(
                                child: _buildActionButton(
                                  'Encrypt',
                                  Icons.lock_outline,
                                  const Color(0xFF9B59B6), // Purple
                                  () => _encryptMessage(),
                                ),
                              ),

                              // Clear button
                              Expanded(
                                child: _buildActionButton(
                                  'Clear',
                                  Icons.clear,
                                  Colors.red, // Red for contrast
                                  () => _clearMessage(),
                                ),
                              ),

                              // Decrypt button
                              Expanded(
                                child: _buildActionButton(
                                  'Decrypt',
                                  Icons.lock_open_outlined,
                                  const Color(0xFF2E86AB), // Blue
                                  () => _decryptMessage(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
