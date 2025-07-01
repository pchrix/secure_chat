import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../models/contact.dart';
import '../utils/security_utils.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAddingContact = false;
  bool _isGeneratingCode = false;
  String? _myContactCode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    setState(() {
      _isAddingContact = true;
      _codeController.clear();
    });
  }

  void _showGenerateCodeDialog() async {
    setState(() {
      _isGeneratingCode = true;
      _nameController.clear();
      _myContactCode = null;
    });
  }

  Future<void> _addContact() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final contact = Contact.fromShareCode(code);
    if (contact != null) {
      ref.read(appStateProvider.notifier).addContact(contact);
      setState(() => _isAddingContact = false);
      _showSnackBar('Contact ajouté avec succès');
    } else {
      _showSnackBar('Code de contact invalide');
    }
  }

  Future<void> _generateContactCode() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    try {
      // Generate a dummy public key for demonstration
      final publicKey = 'demo_key_${DateTime.now().millisecondsSinceEpoch}';
      final contact = Contact.create(name, publicKey);
      final code = contact.generateShareCode();

      setState(() {
        _myContactCode = code;
      });
    } catch (e) {
      _showSnackBar('Erreur lors de la génération du code');
    }
  }

  Future<void> _copyContactCode() async {
    if (_myContactCode == null) return;

    await SecurityUtils.copyToClipboard(_myContactCode!);
    _showSnackBar('Code copié dans le presse-papiers');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9B59B6),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
    );
  }

  void _removeContact(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Supprimer le contact',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce contact ?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).removeContact(id);
              Navigator.of(context).pop();
              _showSnackBar('Contact supprimé');
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(appStateProvider).contacts;

    return Scaffold(
      backgroundColor:
          const Color(0xFF1C1C1E), // Same dark background as encryption page
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Custom modern header (same style as encryption page)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Back button (left)
                    GestureDetector(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      'Contacts',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: AppTypography.fontSize2xl,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Generate code button (right)
                    GestureDetector(
                      onTap: _showGenerateCodeDialog,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: const Icon(
                          Icons.qr_code,
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
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vos Contacts Sécurisés',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: AppTypography.fontSizeXl,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const AppSpacing.vGapMd,

                      // Contact list or empty state
                      Expanded(
                        child: contacts.isEmpty
                            ? _buildEmptyState()
                            : _buildContactList(contacts),
                      ),
                    ],
                  ),
                ),
              ),

              // Add contact button
              if (!_isAddingContact && !_isGeneratingCode)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showAddContactDialog,
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        'Ajouter un Contact',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.fontSizeLg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        ),
                      ),
                    ),
                  ),
                ),

              // Overlays
              if (_isAddingContact) _buildAddContactOverlay(),
              if (_isGeneratingCode) _buildGenerateCodeOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const AppSpacing.vGapLg,
          Text(
            'Aucun contact',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: AppTypography.fontSize2xl,
              fontWeight: FontWeight.w600,
            ),
          ),
          const AppSpacing.vGapSm,
          Text(
            'Ajoutez des contacts pour partager\ndes messages chiffrés en toute sécurité',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: AppTypography.fontSizeLg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList(List<Contact> contacts) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: AppSizes.iconXxl,
              height: AppSizes.buttonHeightMd,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                Icons.person,
                color: const Color(0xFF9B59B6),
                size: 24,
              ),
            ),
            title: Text(
              contact.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: AppTypography.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Ajouté le ${_formatDate(contact.createdAt)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: AppTypography.fontSizeMd,
              ),
            ),
            trailing: IconButton(
              onPressed: () => _removeContact(contact.id),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAddContactOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ajouter un Contact',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: AppTypography.fontSize2xl,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const AppSpacing.vGapLg,
                TextField(
                  controller: _codeController,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  decoration: InputDecoration(
                    hintText: 'Collez le code de contact ici...',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
                const AppSpacing.vGapLg,
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _isAddingContact = false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.iconXs),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B59B6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                        child: const Text(
                          'Ajouter',
                          style: TextStyle(color: Colors.white),
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

  Widget _buildGenerateCodeOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Générer un Code de Contact',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: AppTypography.fontSize2xl,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const AppSpacing.vGapLg,
                if (_myContactCode == null) ...[
                  TextField(
                    controller: _nameController,
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    decoration: InputDecoration(
                      hintText: 'Votre nom...',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const AppSpacing.vGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _isGeneratingCode = false),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.iconXs),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _generateContactCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B59B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: const Text(
                            'Générer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: SelectableText(
                      _myContactCode!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: AppTypography.fontSizeMd,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const AppSpacing.vGapLg,
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => _isGeneratingCode = false),
                          child: Text(
                            'Fermer',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.iconXs),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _copyContactCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E86AB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: const Text(
                            'Copier',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
