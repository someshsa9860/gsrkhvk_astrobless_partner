import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';

class ConsultationDetailScreen extends StatelessWidget {
  const ConsultationDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consultationDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(id: id).animate().fadeIn(),
          const SizedBox(height: 16),
          _EarningCard().animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          _CustomerCard().animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💬', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.chatConsultation, style: tt.titleMedium),
                  const SizedBox(height: 2),
                  Text(id, style: tt.labelSmall?.copyWith(color: AppColors.textDisabled, fontFamily: 'monospace')),
                ],
              ),
              const Spacer(),
              StatusBadge.fromStatus('completed'),
            ],
          ),
          const Divider(color: AppColors.borderDark, height: 24),
          _row(context, l10n.startedLabel, formatDateTime(DateTime.now().subtract(const Duration(hours: 2)))),
          const SizedBox(height: 8),
          _row(context, l10n.durationLabel, formatDuration(1080)),
          const SizedBox(height: 8),
          _row(context, l10n.rateLabel, '₹30/min'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        Text(value, style: tt.bodySmall?.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _EarningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.yourEarnings, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              Text(
                '₹378.00',
                style: tt.headlineSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.customerPaid, style: tt.labelSmall?.copyWith(color: AppColors.textDisabled)),
              Text('₹540.00', style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              Text('${l10n.platformFeePrefix} ₹162.00', style: tt.labelSmall?.copyWith(color: AppColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Text('P', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Priya M.', style: tt.titleSmall),
              Text(l10n.customerLabel, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
