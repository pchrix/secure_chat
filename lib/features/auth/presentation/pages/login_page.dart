/// 🔐 LoginPage - Page de connexion avec design glassmorphism
///
/// Interface utilisateur moderne pour la connexion avec validation en temps réel
/// et gestion d'état via Riverpod.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_state_provider.dart';
import '../providers/auth_usecases_provider.dart';
import '../providers/remember_me_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_loading_overlay.dart';

/// Page de connexion avec design glassmorphism
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  // _rememberMe supprimé - maintenant géré par rememberMeProvider

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                padding: const EdgeInsets.all(24.0),
                child: _buildLoginForm(),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.secondaryColor.withOpacity(0.6),
            AppTheme.accentColor.withOpacity(0.4),
          ],
        ),
      ),
    );
  }

  /// Construit le formulaire de connexion
  Widget _buildLoginForm() {
    return GlassmorphismContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo et titre
            _buildHeader(),

            const SizedBox(height: 32),

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

            const SizedBox(height: 16),

            // Champ mot de passe
            AuthTextField(
              controller: _passwordController,
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
            ),

            const SizedBox(height: 16),

            // Options (Se souvenir de moi, Mot de passe oublié)
            _buildOptions(),

            const SizedBox(height: 24),

            // Bouton de connexion
            AuthButton(
              text: 'Se connecter',
              onPressed: _handleLogin,
              isLoading: ref.watch(authStateProvider).isLoading,
            ),

            const SizedBox(height: 16),

            // Lien vers l'inscription
            _buildSignUpLink(),

            const SizedBox(height: 16),

            // Message d'erreur
            _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête avec logo et titre
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.accentColor,
              ],
            ),
          ),
          child: const Icon(
            Icons.security,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Titre
        Text(
          'SecureChat',
          style: AppTheme.headlineLarge.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        Text(
          'Connexion sécurisée',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  /// Construit les options (Se souvenir de moi, Mot de passe oublié)
  Widget _buildOptions() {
    return Row(
      children: [
        // Se souvenir de moi
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: ref.watch(rememberMeProvider),
                onChanged: (value) {
                  ref.read(rememberMeProvider.notifier).state = value ?? false;
                  // Sauvegarder automatiquement l'état
                  saveRememberMeState(value ?? false);
                },
                activeColor: AppTheme.primaryColor,
              ),
              Expanded(
                child: Text(
                  'Se souvenir de moi',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Mot de passe oublié
        TextButton(
          onPressed: _handleForgotPassword,
          child: Text(
            'Mot de passe oublié ?',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Construit le lien vers l'inscription
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        TextButton(
          onPressed: _handleGoToSignUp,
          child: Text(
            'S\'inscrire',
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.errorColor.withOpacity(0.3),
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

  /// Gère la connexion
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStateProvider.notifier).signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Navigation gérée par le router selon l'état d'authentification
    } catch (e) {
      // L'erreur est gérée par le provider
    }
  }

  /// Gère le mot de passe oublié
  void _handleForgotPassword() {
    // TODO: Implémenter la récupération de mot de passe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
      ),
    );
  }

  /// Navigue vers la page d'inscription
  void _handleGoToSignUp() {
    Navigator.of(context).pushReplacementNamed('/register');
  }

  /// Obtient le message d'erreur approprié
  String _getErrorMessage(dynamic error) {
    // TODO: Mapper les erreurs spécifiques
    return 'Erreur de connexion. Vérifiez vos identifiants.';
  }
}
