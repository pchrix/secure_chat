import 'package:flutter/material.dart';
import '../models/room.dart';
import '../widgets/glass_container.dart';
import '../theme.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const RoomCard({
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
      direction: showDeleteButton ? DismissDirection.endToStart : DismissDirection.none,
      background: _buildDeleteBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GlassCard(
          onTap: onTap,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec statut et ID
              Row(
                children: [
                  // Icône de statut
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // ID du salon
                  Text(
                    '${room.statusIcon} Salon #${room.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Badge de statut
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations du salon
              Row(
                children: [
                  // Participants
                  _buildInfoChip(
                    icon: Icons.people_outline,
                    label: room.statusDisplay,
                    color: _getStatusColor(),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Temps d'expiration
                  _buildInfoChip(
                    icon: Icons.schedule_outlined,
                    label: _getTimeRemainingText(),
                    color: _getTimeColor(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description ou dernier message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getDescriptionText(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 32),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GlassColors.danger.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: GlassColors.danger,
        size: 28,
      ),
    );
  }

  Widget _buildStatusBadge() {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
