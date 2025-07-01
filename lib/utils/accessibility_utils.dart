import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Utilitaires pour l'accessibilité
class AccessibilityUtils {
  /// Initialiser l'accessibilité de l'application
  static void initializeAccessibility() {
    // S'assurer que l'arbre sémantique est construit
    SemanticsBinding.instance.ensureSemantics();
  }

  /// Créer un widget avec sémantique personnalisée
  static Widget withSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? link,
    bool? header,
    bool? textField,
    bool? focusable,
    bool? focused,
    bool? selected,
    bool? enabled,
    bool? checked,
    bool? expanded,
    bool? hidden,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onScrollLeft,
    VoidCallback? onScrollRight,
    VoidCallback? onScrollUp,
    VoidCallback? onScrollDown,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
    VoidCallback? onCopy,
    VoidCallback? onCut,
    VoidCallback? onPaste,
    VoidCallback? onDismiss,
    MoveCursorHandler? onMoveCursorForwardByCharacter,
    MoveCursorHandler? onMoveCursorBackwardByCharacter,
    SetSelectionHandler? onSetSelection,
    VoidCallback? onDidGainAccessibilityFocus,
    VoidCallback? onDidLoseAccessibilityFocus,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      link: link,
      header: header,
      textField: textField,
      focusable: focusable,
      focused: focused,
      selected: selected,
      enabled: enabled,
      checked: checked,
      expanded: expanded,
      hidden: hidden,
      onTap: onTap,
      onLongPress: onLongPress,
      onScrollLeft: onScrollLeft,
      onScrollRight: onScrollRight,
      onScrollUp: onScrollUp,
      onScrollDown: onScrollDown,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      onCopy: onCopy,
      onCut: onCut,
      onPaste: onPaste,
      onDismiss: onDismiss,
      onMoveCursorForwardByCharacter: onMoveCursorForwardByCharacter,
      onMoveCursorBackwardByCharacter: onMoveCursorBackwardByCharacter,
      onSetSelection: onSetSelection,
      onDidGainAccessibilityFocus: onDidGainAccessibilityFocus,
      onDidLoseAccessibilityFocus: onDidLoseAccessibilityFocus,
      child: child,
    );
  }

  /// Créer un bouton accessible
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? tooltip,
    bool enabled = true,
  }) {
    return withSemantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: enabled,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }

  /// Créer un champ de texte accessible
  static Widget accessibleTextField({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Créer un en-tête accessible
  static Widget accessibleHeader({
    required Widget child,
    String? label,
    int level = 1,
  }) {
    return withSemantics(
      label: label,
      header: true,
      child: child,
    );
  }

  /// Créer une liste accessible
  static Widget accessibleList({
    required Widget child,
    String? label,
    int? itemCount,
  }) {
    return withSemantics(
      label: label,
      child: child,
    );
  }

  /// Créer un élément de liste accessible
  static Widget accessibleListItem({
    required Widget child,
    String? label,
    int? index,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return withSemantics(
      label: label,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }

  /// Créer un switch accessible
  static Widget accessibleSwitch({
    required Widget child,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? label,
    bool enabled = true,
  }) {
    return withSemantics(
      label: label,
      checked: value,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Créer un slider accessible
  static Widget accessibleSlider({
    required Widget child,
    required double value,
    required double min,
    required double max,
    String? label,
    bool enabled = true,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return withSemantics(
      label: label,
      value: value.toString(),
      enabled: enabled,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  /// Créer un dialog accessible
  static Widget accessibleDialog({
    required Widget child,
    String? label,
    bool dismissible = true,
    VoidCallback? onDismiss,
  }) {
    return withSemantics(
      label: label,
      focusable: true,
      onDismiss: dismissible ? onDismiss : null,
      child: child,
    );
  }

  /// Annoncer un message aux lecteurs d'écran
  static void announceMessage(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Annoncer un message d'erreur
  static void announceError(String error) {
    SemanticsService.announce('Erreur: $error', TextDirection.ltr);
  }

  /// Annoncer un message de succès
  static void announceSuccess(String message) {
    SemanticsService.announce('Succès: $message', TextDirection.ltr);
  }

  /// Annoncer un changement d'état
  static void announceStateChange(String state) {
    SemanticsService.announce('État changé: $state', TextDirection.ltr);
  }

  /// Vérifier si les services d'accessibilité sont activés
  static bool get isAccessibilityEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  /// Vérifier si le lecteur d'écran est activé
  static bool get isScreenReaderEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;
  }

  /// Vérifier si le contraste élevé est activé
  static bool get isHighContrastEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.highContrast;
  }

  /// Vérifier si les animations sont réduites
  static bool get isReduceMotionEnabled {
    return SemanticsBinding.instance.accessibilityFeatures.disableAnimations;
  }

  /// Obtenir la couleur de contraste appropriée
  static Color getContrastColor(Color backgroundColor) {
    // Calculer la luminance relative
    final luminance = backgroundColor.computeLuminance();
    
    // Retourner blanc ou noir selon la luminance
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Vérifier si le contraste est suffisant
  static bool hasGoodContrast(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    
    // Calculer le ratio de contraste
    final lighter = foregroundLuminance > backgroundLuminance 
        ? foregroundLuminance 
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance 
        ? backgroundLuminance 
        : foregroundLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA recommande un ratio de 4.5:1 pour le texte normal
    return contrastRatio >= 4.5;
  }

  /// Créer un focus traversal policy personnalisé
  static FocusTraversalPolicy createAccessibleTraversalPolicy() {
    return OrderedTraversalPolicy();
  }

  /// Créer un widget avec focus personnalisé
  static Widget withFocus({
    required Widget child,
    FocusNode? focusNode,
    bool autofocus = false,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: (hasFocus) {
        if (onFocusChange != null) {
          onFocusChange();
        }
        
        // Annoncer le changement de focus si nécessaire
        if (hasFocus && isScreenReaderEnabled) {
          HapticFeedback.selectionClick();
        }
      },
      child: child,
    );
  }

  /// Créer un tooltip accessible
  static Widget accessibleTooltip({
    required Widget child,
    required String message,
    Duration? showDuration,
    Duration? waitDuration,
  }) {
    return Tooltip(
      message: message,
      showDuration: showDuration,
      waitDuration: waitDuration,
      child: withSemantics(
        hint: message,
        child: child,
      ),
    );
  }

  /// Créer un indicateur de chargement accessible
  static Widget accessibleLoadingIndicator({
    String? label,
    double? value,
  }) {
    return withSemantics(
      label: label ?? 'Chargement en cours',
      value: value?.toString(),
      child: const CircularProgressIndicator.adaptive(),
    );
  }

  /// Créer un message d'erreur accessible
  static Widget accessibleErrorMessage({
    required String message,
    VoidCallback? onRetry,
  }) {
    return withSemantics(
      label: 'Erreur: $message',
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            semanticsLabel: 'Erreur: $message',
          ),
          if (onRetry != null)
            accessibleButton(
              onPressed: onRetry,
              semanticLabel: 'Réessayer',
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }
}
