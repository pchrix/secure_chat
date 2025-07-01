import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_sizes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unified_auth_service.dart';
import '../core/providers/service_providers.dart';
import '../theme.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0; // 0: current password, 1: new password, 2: confirm

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrentPassword() async {
    final password = _currentPasswordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre mot de passe actuel';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(unifiedAuthServiceProvider);
      final result = await authService.verifyPassword(password);

      if (result.isSuccess) {
        setState(() {
          _currentStep = 1;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la vérification';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    final password = _newPasswordController.text.trim();

    final authService = ref.read(unifiedAuthServiceProvider);
    final validation = authService.validatePasswordStrength(password);
    if (!validation.isValid) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir entre 4 et 6 chiffres';
      });
      return;
    }

    setState(() {
      _currentStep = 2;
      _errorMessage = null;
    });
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(unifiedAuthServiceProvider);
      final result = await authService.setPassword(newPassword);
      final success = result.isSuccess;

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe modifié avec succès'),
              backgroundColor: Color(0xFF9B59B6),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la modification du mot de passe';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la modification';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
        if (_currentStep == 0) {
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else if (_currentStep == 1) {
          _confirmPasswordController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subtitle = '';
    TextEditingController controller = _currentPasswordController;
    VoidCallback onSubmit = _verifyCurrentPassword;

    switch (_currentStep) {
      case 0:
        title = 'Mot de passe actuel';
        subtitle = 'Saisissez votre mot de passe actuel';
        controller = _currentPasswordController;
        onSubmit = _verifyCurrentPassword;
        break;
      case 1:
        title = 'Nouveau mot de passe';
        subtitle = 'Choisissez un nouveau mot de passe (4-6 chiffres)';
        controller = _newPasswordController;
        onSubmit = _nextStep;
        break;
      case 2:
        title = 'Confirmer le mot de passe';
        subtitle = 'Saisissez à nouveau le nouveau mot de passe';
        controller = _confirmPasswordController;
        onSubmit = _changePassword;
        break;
    }

    return Dialog(
      backgroundColor: AppColors.authBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                if (_currentStep > 0)
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.glassWhite,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.fontSize2xl,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const AppSpacing.vGapLg,

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: AppTypography.fontSizeMd,
              ),
            ),

            const AppSpacing.vGapLg,

            // Password input
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: _errorMessage != null
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                ), // ✅ AJOUTÉ pour keyboard avoidance
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: AppTypography.fontSizeLg,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '••••',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: AppTypography.fontSizeLg,
                    letterSpacing: 4,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),

            const AppSpacing.vGapMd,

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.9),
                          fontSize: AppTypography.fontSizeSm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const AppSpacing.vGapLg,

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.setupPurple,
                  disabledBackgroundColor: AppColors.setupPurpleAlpha50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: AppSizes.iconXs,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Modifier' : 'Continuer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.fontSizeMd,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
