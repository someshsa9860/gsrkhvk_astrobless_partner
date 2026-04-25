import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/earnings_models.dart';
import 'earnings_controller.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _periods = ['week', 'month', 'all'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.earningsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Payout History',
            onPressed: () => context.push('/earnings/payouts'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: l10n.thisWeek),
            Tab(text: l10n.thisMonth),
            Tab(text: l10n.allTime),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _periods.map((p) =>
          _EarningsTabContent(period: p).animate().fadeIn(),
        ).toList(),
      ),
    );
  }
}

class _EarningsTabContent extends ConsumerWidget {
  const _EarningsTabContent({required this.period});
  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final summaryState = ref.watch(earningsSummaryProvider);
    final txState = ref.watch(earningsTransactionsProvider(period));

    return summaryState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.errorGeneric,
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(earningsSummaryProvider);
                ref.invalidate(earningsTransactionsProvider(period));
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (summary) {
        final (gross, net, consultations) = switch (period) {
          'week' => (summary.week, summary.week, 0),
          'month' => (summary.month, summary.month, 0),
          _ => (summary.allTime, summary.allTime, 0),
        };

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.yourEarnings,
                    value: formatCurrencyExact(net),
                    icon: Icons.account_balance_wallet,
                    color: AppColors.accent,
                  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.consults,
                    value: '$consultations',
                    icon: Icons.headset_mic_outlined,
                    color: AppColors.primary,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.grossRevenue,
                    value: formatCurrencyExact(gross),
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.platformFee,
                    value: formatCurrencyExact(gross * 0.3),
                    icon: Icons.business_center_outlined,
                    color: AppColors.textSecondary,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _PayoutSection().animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.transactionHistory,
                  style: tt.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                txState.maybeWhen(
                  data: (txs) => Text(
                    l10n.entriesCount(txs.length),
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            txState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(l10n.errorGeneric,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              data: (txs) => Column(
                children: txs.asMap().entries.map(
                  (e) => _TransactionRow(tx: e.value)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + e.key * 50)),
                ).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color == AppColors.textSecondary ? AppColors.textPrimary : color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PayoutSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(payoutsProvider);

    return state.maybeWhen(
      data: (payouts) {
        final last = payouts.where((p) => p.status == 'processed').firstOrNull;
        if (last == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lastPayoutProcessed,
                      style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${formatCurrencyExact(last.amount)} on ${formatDate(last.processedAt ?? last.periodEnd)}',
                      style: tt.titleSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});
  final EarningTransaction tx;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final type = tx.type ?? 'chat';

    final typeColor = switch (type) {
      'chat' => AppColors.info,
      'voice' => AppColors.success,
      'video' => AppColors.accent,
      'kundli' => AppColors.primary,
      _ => AppColors.textSecondary,
    };

    final typeEmoji = switch (type) {
      'chat' => '💬',
      'voice' => '📞',
      'video' => '📹',
      'kundli' => '🔮',
      _ => '⭐',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(typeEmoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.customerName ?? 'Customer', style: tt.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  formatDateTime(tx.createdAt),
                  style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '+${formatCurrency(tx.net)}',
            style: tt.titleSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
