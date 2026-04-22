import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  static StatusBadge online() => const StatusBadge(label: 'Online', color: AppColors.online);
  static StatusBadge offline() => const StatusBadge(label: 'Offline', color: AppColors.offline);
  static StatusBadge busy() => const StatusBadge(label: 'Busy', color: AppColors.busy);

  static StatusBadge fromStatus(String status) => switch (status.toLowerCase()) {
        'active' || 'online' || 'approved' || 'completed' || 'paid' => const StatusBadge(label: 'Active', color: AppColors.success),
        'pending' || 'requested' => StatusBadge(label: status, color: AppColors.warning),
        'rejected' || 'blocked' || 'failed' || 'expired' => StatusBadge(label: status, color: AppColors.error),
        _ => StatusBadge(label: status, color: AppColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
