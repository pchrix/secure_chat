/// 📝 AuthTextField - Champ de texte personnalisé pour l'authentification
/// 
/// Widget de champ de texte avec design glassmorphism et validation intégrée.
/// Optimisé pour les formulaires d'authentification.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import 'glassmorphism_container.dart';

/// Champ de texte personnalisé pour l'authentification
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Contrôleur du champ de texte
  final TextEditingController controller;

  /// Texte du label
  final String? labelText;

  /// Texte d'indication
  final String? hintText;

  /// Icône de préfixe
  final IconData? prefixIcon;

  /// Widget de suffixe
  final Widget? suffixIcon;

  /// Masquer le texte (pour les mots de passe)
  final bool obscureText;

  /// Type de clavier
  final TextInputType keyboardType;

  /// Action du bouton d'entrée
  final TextInputAction textInputAction;

  /// Fonction de validation
  final String? Function(String?)? validator;

  /// Callback lors du changement de texte
  final void Function(String)? onChanged;

  /// Callback lors de la soumission
  final void Function(String)? onFieldSubmitted;

  /// Champ activé
  final bool enabled;

  /// Champ en lecture seule
  final bool readOnly;

  /// Nombre maximum de lignes
  final int maxLines;

  /// Longueur maximale
  final int? maxLength;

  /// Formateurs d'entrée
  final List<TextInputFormatter>? inputFormatters;

  /// Focus automatique
  final bool autofocus;

  /// Correction automatique
  final bool autocorrect;

  /// Suggestions activées
  final bool enableSuggestions;

  /// Capitalisation du texte
  final TextCapitalization textCapitalization;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Champ de texte avec glassmorphism
        GlassmorphismVariants.textField(
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            autofocus: widget.autofocus,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            textCapitalization: widget.textCapitalization,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 8 : 16,
                vertical: 16,
              ),
              counterText: '', // Masque le compteur de caractères
            ),
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                _errorText = error;
              });
              return null; // On gère l'affichage de l'erreur manuellement
            },
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
          ),
        ),

        // Message d'erreur
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: AppTheme.errorColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Variantes spécialisées d'AuthTextField
class AuthTextFieldVariants {
  /// Champ email
  static Widget email({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return AuthTextField(
      controller: controller,
      labelText: labelText ?? 'Email',
      hintText: hintText ?? 'Entrez votre email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  /// Champ mot de passe
  static Widget password({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    bool showToggle = true,
  }) {
    return _PasswordTextField(
      controller: controller,
      labelText: labelText ?? 'Mot de passe',
      hintText: hintText ?? 'Entrez votre mot de passe',
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      showToggle: showToggle,
    );
  }

  /// Champ nom d'utilisateur
  static Widget username({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return AuthTextField(
      controller: controller,
      labelText: labelText ?? 'Nom d\'utilisateur',
      hintText: hintText ?? 'Choisissez un nom d\'utilisateur',
      prefixIcon: Icons.person_outlined,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  /// Champ code PIN
  static Widget pin({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return AuthTextField(
      controller: controller,
      labelText: labelText ?? 'Code PIN',
      hintText: hintText ?? 'Entrez votre code PIN',
      prefixIcon: Icons.pin_outlined,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      obscureText: true,
      maxLength: 6,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      autocorrect: false,
      enableSuggestions: false,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

/// Widget interne pour les champs mot de passe avec toggle
class _PasswordTextField extends StatefulWidget {
  const _PasswordTextField({
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.showToggle = true,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool showToggle;

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      hintText: widget.hintText,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: widget.showToggle
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondaryColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : null,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}
