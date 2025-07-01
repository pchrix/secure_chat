/// 🔐 PIN Entry Widget - Widget réutilisable pour saisie PIN
///
/// Widget moderne et responsive pour la saisie de PIN avec glassmorphism
/// Conforme aux meilleures pratiques Context7 et Flutter

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive_builder.dart';
import '../../../../widgets/enhanced_numeric_keypad.dart';
import '../providers/pin_state_provider.dart';

/// Widget d'entrée PIN réutilisable
class PinEntryWidget extends ConsumerWidget {
  final int pinLength;
  final Function(String)? onPinComplete;
  final Function(String)? onPinChanged;
  final bool enableBiometric;
  final String? title;
  final String? subtitle;
  final bool showTitle;

  const PinEntryWidget({
    super.key,
    this.pinLength = 4,
    this.onPinComplete,
    this.onPinChanged,
    this.enableBiometric = false,
    this.title,
    this.subtitle,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinStateProvider);

    return ResponsiveBuilder(
      builder: (context, responsive) {
        // Calculs responsive
        final isVeryCompact =
            responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE1;
        final isCompact =
            responsive.screenSize.width < ResponsiveBreakpoints.iphoneSE2;

        // Espacements adaptatifs
        final titleSpacing = isVeryCompact ? 12.0 : (isCompact ? 16.0 : 20.0);
        final sectionSpacing = isVeryCompact ? 20.0 : (isCompact ? 24.0 : 32.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre et sous-titre (optionnels)
            if (showTitle) ...[
              _buildHeader(
                responsive: responsive,
                isVeryCompact: isVeryCompact,
                isCompact: isCompact,
                pinState: pinState,
              ),
              SizedBox(height: titleSpacing),
            ],

            // Indicateur PIN
            PinIndicator(
              length: pinLength,
              filledCount: pinState.currentPin.length,
              showError: pinState.errorMessage != null,
              dotSize: isVeryCompact ? 12.0 : 16.0,
              spacing: isVeryCompact ? 10.0 : 16.0,
            ),

            SizedBox(height: sectionSpacing),

            // Message d'erreur
            if (pinState.errorMessage != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isVeryCompact ? 12.0 : 16.0,
                  vertical: isVeryCompact ? 8.0 : 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  pinState.errorMessage!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.red.shade300,
                    fontSize: isVeryCompact ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: sectionSpacing * 0.75),
            ],

            // Indicateur de chargement
            if (pinState.isLoading) ...[
              SizedBox(
                height: isVeryCompact ? 20.0 : 24.0,
                width: isVeryCompact ? 20.0 : 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: sectionSpacing),
            ],

            // Clavier numérique
            EnhancedNumericKeypad(
              onNumberPressed: (number) {
                if (pinState.currentPin.length < pinLength) {
                  final newPin = pinState.currentPin + number;
                  ref.read(pinStateProvider.notifier).updateCurrentPin(newPin);
                  onPinChanged?.call(newPin);

                  if (newPin.length == pinLength) {
                    onPinComplete?.call(newPin);
                  }
                }
              },
              onBackspacePressed: () {
                if (pinState.currentPin.isNotEmpty) {
                  final newPin = pinState.currentPin.substring(
                    0,
                    pinState.currentPin.length - 1,
                  );
                  ref.read(pinStateProvider.notifier).updateCurrentPin(newPin);
                  onPinChanged?.call(newPin);
                }
              },
              onBackspaceLongPress: () {
                ref.read(pinStateProvider.notifier).clearCurrentPin();
                onPinChanged?.call('');
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader({
    required ResponsiveInfo responsive,
    required bool isVeryCompact,
    required bool isCompact,
    required PinState pinState,
  }) {
    // Titre par défaut selon le mode
    String defaultTitle;
    String defaultSubtitle;

    switch (pinState.mode) {
      case PinMode.authentication:
        defaultTitle = 'Saisir le code PIN';
        defaultSubtitle = 'Entrez votre code à 4 chiffres';
        break;
      case PinMode.setup:
        if (pinState.currentStep == 0) {
          defaultTitle = 'Créer un mot de passe';
          defaultSubtitle = 'Choisissez un mot de passe de 4 chiffres';
        } else {
          defaultTitle = 'Confirmer le mot de passe';
          defaultSubtitle = 'Saisissez à nouveau votre mot de passe';
        }
        break;
      case PinMode.change:
        defaultTitle = 'Nouveau code PIN';
        defaultSubtitle = 'Entrez votre nouveau code à 4 chiffres';
        break;
    }

    return Column(
      children: [
        // Titre
        Text(
          title ?? defaultTitle,
          style: AppTheme.headlineLarge.copyWith(
            fontSize: isVeryCompact ? 18 : (isCompact ? 20 : 24),
          ),
        ),

        SizedBox(height: isVeryCompact ? 8.0 : 12.0),

        // Sous-titre
        Text(
          subtitle ?? defaultSubtitle,
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: isVeryCompact ? 13 : (isCompact ? 14 : 16),
          ),
        ),
      ],
    );
  }
}

/// Indicateur visuel du PIN
class PinIndicator extends StatelessWidget {
  final int length;
  final int filledCount;
  final bool showError;
  final double dotSize;
  final double spacing;

  const PinIndicator({
    super.key,
    required this.length,
    required this.filledCount,
    this.showError = false,
    this.dotSize = 16.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filledCount;
        final color = showError
            ? Colors.red.shade300
            : isFilled
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.3);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
