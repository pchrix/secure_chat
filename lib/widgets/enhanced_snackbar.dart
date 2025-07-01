import 'package:flutter/material.dart';
import '../theme.dart';

/// SnackBar glassmorphique avancé avec animations et styles améliorés
class EnhancedSnackBar extends SnackBar {
  EnhancedSnackBar({
    super.key,
    required String message,
    EnhancedSnackBarType type = EnhancedSnackBarType.info,
    super.duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
          content: _EnhancedSnackBarContent(
            message: message,
            type: type,
            onAction: onAction,
            actionLabel: actionLabel,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );

  /// Helper method pour afficher facilement un snackbar
  static void show(
    BuildContext context, {
    required String message,
    EnhancedSnackBarType type = EnhancedSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedSnackBar(
        message: message,
        type: type,
        duration: duration,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }
}

enum EnhancedSnackBarType { success, error, warning, info }

class _EnhancedSnackBarContent extends StatefulWidget {
  final String message;
  final EnhancedSnackBarType type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _EnhancedSnackBarContent({
    required this.message,
    required this.type,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<_EnhancedSnackBarContent> createState() =>
      _EnhancedSnackBarContentState();
}

class _EnhancedSnackBarContentState extends State<_EnhancedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.sharpCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.standardCurve,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case EnhancedSnackBarType.success:
        return GlassColors.success;
      case EnhancedSnackBarType.error:
        return GlassColors.danger;
      case EnhancedSnackBarType.warning:
        return GlassColors.warning;
      case EnhancedSnackBarType.info:
        return GlassColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case EnhancedSnackBarType.success:
        return Icons.check_circle_outline;
      case EnhancedSnackBarType.error:
        return Icons.error_outline;
      case EnhancedSnackBarType.warning:
        return Icons.warning_amber_outlined;
      case EnhancedSnackBarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor.withValues(alpha: 0.15),
                    typeColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: typeColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: MediaQuery.sizeOf(context).width < 600 ? 36 : 40,
                    height: MediaQuery.sizeOf(context).width < 600 ? 36 : 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(MediaQuery.sizeOf(context).width < 600 ? 8 : 10),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: typeColor,
                      size: MediaQuery.sizeOf(context).width < 600 ? 18 : 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Message
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.3,
                      ),
                    ),
                  ),

                  // Action Button
                  if (widget.onAction != null &&
                      widget.actionLabel != null) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppLayout.spacingM,
                          vertical: AppLayout.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
