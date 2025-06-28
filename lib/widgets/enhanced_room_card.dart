import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/room.dart';
import '../widgets/glass_components.dart';
import '../animations/enhanced_micro_interactions.dart';
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
    return Dismissible(
      key: Key(room.id),
      direction: showDeleteButton
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: _buildEnhancedDeleteBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: EnhancedGlassButton(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: _getStatusColor(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              Row(
                children: [
                  // Enhanced Status Icon
                  BreathingPulseAnimation(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(),
                            _getStatusColor().withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor().withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Enhanced Room Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.8),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Salon #${room.id}',
                            style: AppTextStyles.roomTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getStatusColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              room.statusDisplay,
                              style: AppTextStyles.statusText.copyWith(
                                color: _getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Status Badge
                  _buildEnhancedStatusBadge(),
                ],
              ),

              const SizedBox(height: 20),

              // Enhanced Info Chips
              Row(
                children: [
                  _buildEnhancedInfoChip(
                    icon: Icons.people_outline,
                    label: '2 participants max',
                    color: GlassColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  _buildEnhancedInfoChip(
                    icon: Icons.schedule_outlined,
                    label: _getTimeRemainingText(),
                    color: _getTimeColor(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Enhanced Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getDescriptionText(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 32),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GlassColors.danger.withValues(alpha: 0.3),
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: GlassColors.danger,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: GlassColors.danger.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supprimer',
            style: TextStyle(
              color: GlassColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatusBadge() {
    Color badgeColor;
    String badgeText;

    switch (room.status) {
      case RoomStatus.waiting:
        badgeColor = GlassColors.warning;
        badgeText = 'EN ATTENTE';
        break;
      case RoomStatus.active:
        badgeColor = GlassColors.secondary;
        badgeText = 'ACTIF';
        break;
      case RoomStatus.expired:
        badgeColor = GlassColors.danger;
        badgeText = 'EXPIRÉ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: 0.3),
            badgeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.badgeText.copyWith(
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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

  Color _getTimeColor() {
    if (room.isExpired) return GlassColors.danger;

    final remaining = room.timeRemaining;
    if (remaining.inHours < 1) return GlassColors.warning;
    return GlassColors.onSurfaceVariant;
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
}
