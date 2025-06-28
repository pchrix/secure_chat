import 'package:flutter/material.dart';
import '../theme.dart';

/// Tooltip glassmorphique avancé avec animations et styles personnalisés
class EnhancedTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final String? title;
  final EnhancedTooltipType type;
  final Duration showDuration;
  final Duration waitDuration;
  final EdgeInsetsGeometry? padding;

  const EnhancedTooltip({
    super.key,
    required this.child,
    required this.message,
    this.title,
    this.type = EnhancedTooltipType.info,
    this.showDuration = const Duration(seconds: 2),
    this.waitDuration = const Duration(milliseconds: 500),
    this.padding,
  });

  @override
  State<EnhancedTooltip> createState() => _EnhancedTooltipState();
}

enum EnhancedTooltipType { info, success, warning, error, help }

class _EnhancedTooltipState extends State<EnhancedTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    _animationController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        targetOffset: offset,
        targetSize: size,
        message: widget.message,
        title: widget.title,
        type: widget.type,
        padding: widget.padding,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();

    // Auto-hide après la durée spécifiée
    Future.delayed(widget.showDuration, _hideTooltip);
  }

  void _hideTooltip() {
    if (_overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showTooltip,
      onTap: () {
        if (_overlayEntry != null) {
          _hideTooltip();
        } else {
          Future.delayed(widget.waitDuration, _showTooltip);
        }
      },
      child: widget.child,
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  final Offset targetOffset;
  final Size targetSize;
  final String message;
  final String? title;
  final EnhancedTooltipType type;
  final EdgeInsetsGeometry? padding;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _TooltipOverlay({
    required this.targetOffset,
    required this.targetSize,
    required this.message,
    this.title,
    required this.type,
    this.padding,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  Color _getTypeColor() {
    switch (type) {
      case EnhancedTooltipType.success:
        return GlassColors.success;
      case EnhancedTooltipType.warning:
        return GlassColors.warning;
      case EnhancedTooltipType.error:
        return GlassColors.danger;
      case EnhancedTooltipType.help:
        return GlassColors.secondary;
      case EnhancedTooltipType.info:
        return GlassColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case EnhancedTooltipType.success:
        return Icons.check_circle_outline;
      case EnhancedTooltipType.warning:
        return Icons.warning_amber_outlined;
      case EnhancedTooltipType.error:
        return Icons.error_outline;
      case EnhancedTooltipType.help:
        return Icons.help_outline;
      case EnhancedTooltipType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final typeColor = _getTypeColor();

    // Calculer la position optimale
    const tooltipHeight = 120.0;
    const tooltipWidth = 280.0;
    const margin = 16.0;

    double left = targetOffset.dx + (targetSize.width - tooltipWidth) / 2;
    double top = targetOffset.dy - tooltipHeight - 8;

    // Ajustements pour éviter les débordements
    if (left < margin) left = margin;
    if (left + tooltipWidth > screenSize.width - margin) {
      left = screenSize.width - tooltipWidth - margin;
    }
    if (top < margin) {
      top = targetOffset.dy + targetSize.height + 8;
    }

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  width: tooltipWidth,
                  padding: padding ?? const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getTypeIcon(),
                              color: typeColor,
                              size: 18,
                            ),
                          ),
                          if (title != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title!,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (title != null) const SizedBox(height: 8),

                      // Message
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}