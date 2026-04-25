import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../domain/earnings_models.dart';
import 'earnings_controller.dart';

class PayoutHistoryScreen extends ConsumerWidget {
  const PayoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payoutsProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Payout History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load payouts',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(payoutsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (payouts) {
          if (payouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_outlined,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payouts yet',
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Payouts are processed weekly by the platform',
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payouts.length,
            itemBuilder: (context, i) =>
                _PayoutCard(payout: payouts[i]).animate().fadeIn(
                      delay: Duration(milliseconds: i * 50),
                    ),
          );
        },
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});
  final Payout payout;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final (statusColor, statusLabel, statusIcon) = switch (payout.status) {
      'processed' => (AppColors.success, 'Paid', Icons.check_circle_outline),
      'processing' => (AppColors.warning, 'Processing', Icons.sync_outlined),
      'queued' => (AppColors.info, 'Queued', Icons.schedule_outlined),
      _ => (AppColors.error, 'Failed', Icons.error_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrencyExact(payout.amount),
                      style: tt.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: tt.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Period: ${formatDate(payout.periodStart)} – ${formatDate(payout.periodEnd)}',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                if (payout.processedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Paid on ${formatDate(payout.processedAt!)}',
                    style: tt.bodySmall?.copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
