import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/room.dart';
import '../widgets/glass_components.dart';
import '../utils/responsive_builder.dart';
import '../theme.dart';

class EnhancedRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const EnhancedRoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return _buildCard(responsive);
      },
    );
  }

  Widget _buildCard(ResponsiveInfo responsive) {
    return Dismissible(
      key: Key(room.id),
      direction: showDeleteButton
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: _buildDeleteBackground(responsive),
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0, 
          vertical: responsive.verticalSpacing * 0.5,
        ),
        child: EnhancedGlassButton(
          width: double.infinity,
          padding: responsive.adaptivePadding,
          color: _getStatusColor(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: _buildCompactCard(responsive),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(ResponsiveInfo responsive) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: responsive.horizontalSpacing * 2),
      margin: EdgeInsets.symmetric(
        horizontal: 0, 
        vertical: responsive.verticalSpacing * 0.5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            GlassColors.danger.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: GlassColors.danger.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _getAdaptiveSize(responsive, 32),
            height: _getAdaptiveSize(responsive, 32),
            decoration: BoxDecoration(
              color: GlassColors.danger,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: responsive.getAdaptiveFontSize(16),
            ),
          ),
          SizedBox(height: responsive.verticalSpacing * 0.25),
          Text(
            'Supprimer',
            style: TextStyle(
              color: GlassColors.danger,
              fontSize: responsive.getAdaptiveFontSize(10),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Version compacte pour tous les écrans
  Widget _buildCompactCard(ResponsiveInfo responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header simplifié
        Row(
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
              height: MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: responsive.horizontalSpacing * 0.5),
            Expanded(
              child: Text(
                'Salon #${room.id}',
                style: AppTextStyles.roomTitle.copyWith(
                  fontSize: responsive.getAdaptiveFontSize(16),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.verticalSpacing * 0.5),
        // Status simplifié
        Text(
          room.statusDisplay,
          style: AppTextStyles.statusText.copyWith(
            color: _getStatusColor(),
            fontSize: responsive.getAdaptiveFontSize(12),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (room.status) {
      case RoomStatus.waiting:
        return Icons.hourglass_empty;
      case RoomStatus.active:
        return Icons.lock;
      case RoomStatus.expired:
        return Icons.timer_off;
    }
  }

  Color _getStatusColor() {
    switch (room.status) {
      case RoomStatus.waiting:
        return GlassColors.warning;
      case RoomStatus.active:
        return GlassColors.secondary;
      case RoomStatus.expired:
        return GlassColors.danger;
    }
  }

  String _getTimeRemainingText() {
    if (room.isExpired) return 'Expiré';

    final remaining = room.timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}j ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}min';
    } else {
      return '${remaining.inMinutes}min';
    }
  }

  String _getDescriptionText() {
    switch (room.status) {
      case RoomStatus.waiting:
        return 'En attente d\'un participant. Partagez l\'ID du salon pour inviter quelqu\'un.';
      case RoomStatus.active:
        return 'Salon actif avec 1 participant. Vous pouvez commencer à échanger des messages chiffrés.';
      case RoomStatus.expired:
        return 'Ce salon a expiré et n\'est plus accessible. Créez un nouveau salon pour continuer.';
    }
  }

  /// Helper pour calculer les tailles adaptatives
  double _getAdaptiveSize(ResponsiveInfo responsive, double baseSize) {
    if (responsive.isIPhoneSE1) return baseSize * 0.75;
    if (responsive.isIPhoneSE2) return baseSize * 0.85;
    if (responsive.isVeryCompact) return baseSize * 0.9;
    if (responsive.isCompact) return baseSize * 0.95;
    return baseSize;
  }
}
