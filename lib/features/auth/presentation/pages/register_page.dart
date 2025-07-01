/// 📝 RegisterPage - Page d'inscription avec design glassmorphism
/// 
/// Interface utilisateur moderne pour l'inscription avec validation en temps réel
/// et gestion d'état via Riverpod.

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_state_provider.dart';
import '../providers/auth_usecases_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_loading_overlay.dart';

/// Page d'inscription avec design glassmorphism
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec gradient
          _buildBackground(),
          
          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildRegisterForm(),
              ),
            ),
          ),
          
          // Overlay de chargement
          if (isLoading) const AuthLoadingOverlay(),
        ],
      ),
    );
  }

  /// Construit l'arrière-plan avec gradient
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.8),
            AppTheme.primaryColor.withValues(alpha: 0.6),
            AppTheme.secondaryColor.withValues(alpha: 0.4),
          ],
        ),
      ),
    );
  }

  /// Construit le formulaire d'inscription
  Widget _buildRegisterForm() {
    return GlassmorphismContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            _buildHeader(),
            
            const AppSpacing.vGapXl,
            
            // Champ email
            AuthTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Entrez votre email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
              textInputAction: TextInputAction.next,
            ),
            
            const AppSpacing.vGapMd,
            
            // Champ nom d'utilisateur
            AuthTextField(
              controller: _usernameController,
              labelText: 'Nom d\'utilisateur',
              hintText: 'Choisissez un nom d\'utilisateur',
              prefixIcon: Icons.person_outlined,
              validator: Validators.validateUsername,
              textInputAction: TextInputAction.next,
            ),
            
            const AppSpacing.vGapMd,
            
            // Champ nom d'affichage (optionnel)
            AuthTextField(
              controller: _displayNameController,
              labelText: 'Nom d\'affichage (optionnel)',
              hintText: 'Votre nom complet',
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
            ),
            
            const AppSpacing.vGapMd,
            
            // Champ mot de passe
            AuthTextField(
              controller: _passwordController,
              labelText: 'Mot de passe',
              hintText: 'Créez un mot de passe sécurisé',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: Validators.validatePassword,
              textInputAction: TextInputAction.next,
            ),
            
            const AppSpacing.vGapMd,
            
            // Champ confirmation mot de passe
            AuthTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirmer le mot de passe',
              hintText: 'Confirmez votre mot de passe',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegister(),
            ),
            
            const AppSpacing.vGapMd,
            
            // Acceptation des conditions
            _buildTermsAcceptance(),
            
            const AppSpacing.vGapLg,
            
            // Bouton d'inscription
            AuthButton(
              text: 'S\'inscrire',
              onPressed: _acceptTerms ? _handleRegister : null,
              isLoading: ref.watch(authStateProvider).isLoading,
            ),
            
            const AppSpacing.vGapMd,
            
            // Lien vers la connexion
            _buildSignInLink(),
            
            const AppSpacing.vGapMd,
            
            // Message d'erreur
            _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader() {
    return Column(
      children: [
        // Icône
        Container(
          width: 80,
          height: AppSizes.buttonHeightXl + AppSizes.buttonHeightSm,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor,
                AppTheme.primaryColor,
              ],
            ),
          ),
          child: const Icon(
            Icons.person_add,
            size: 40,
            color: Colors.white,
          ),
        ),
        
        const AppSpacing.vGapMd,
        
        // Titre
        Text(
          'Créer un compte',
          style: AppTheme.headlineLarge.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const AppSpacing.vGapSm,
        
        // Sous-titre
        Text(
          'Rejoignez SecureChat',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Construit l'acceptation des conditions
  Widget _buildTermsAcceptance() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                children: [
                  const TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' et la '),
                  TextSpan(
                    text: 'politique de confidentialité',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construit le lien vers la connexion
  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ? ',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        TextButton(
          onPressed: _handleGoToSignIn,
          child: Text(
            'Se connecter',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit le message d'erreur
  Widget _buildErrorMessage() {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getErrorMessage(error),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gère l'inscription
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
        ),
      );
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
      );

      // Navigation gérée par le router selon l'état d'authentification
    } catch (e) {
      // L'erreur est gérée par le provider
    }
  }

  /// Navigue vers la page de connexion
  void _handleGoToSignIn() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Obtient le message d'erreur approprié
  String _getErrorMessage(dynamic error) {
    // Mapping d'erreurs basique pour le MVP
    return 'Erreur lors de l\'inscription. Veuillez réessayer.';
  }
}
