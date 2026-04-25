import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, l10n, dashState),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                dashState.when(
                  loading: () => const _OnlineToggleSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (d) => _OnlineToggle(isOnline: d.isOnline, ref: ref),
                ),
                const SizedBox(height: 20),
                dashState.when(
                  loading: () => const _StatsShimmer(),
                  error: (e, _) => _ErrorRetry(
                    message: e.toString(),
                    onRetry: () => ref.read(dashboardProvider.notifier).load(),
                  ),
                  data: (d) => _StatsSection(data: d),
                ),
                const SizedBox(height: 20),
                const _QuickActions(),
                const SizedBox(height: 20),
                const _RecentActivity(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue dashState,
  ) {
    final tt = Theme.of(context).textTheme;

    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: AppColors.bgDark,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.brandGradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'A',
                style: tt.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.goodMorning,
                style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                l10n.appName,
                style: tt.titleSmall?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: () => context.push('/settings'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Online toggle ─────────────────────────────────────────────────────────────

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.isOnline, required this.ref});
  final bool isOnline;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.online.withValues(alpha: 0.1) : AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? AppColors.online.withValues(alpha: 0.4) : AppColors.borderDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online.withValues(alpha: 0.15) : AppColors.borderDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: isOnline ? AppColors.online : AppColors.textDisabled,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? l10n.youAreOnline : l10n.youAreOffline,
                  style: tt.titleSmall?.copyWith(
                    color: isOnline ? AppColors.online : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isOnline ? l10n.customersCanSeeYou : l10n.toggleToReceive,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: (_) => ref.read(dashboardProvider.notifier).togglePresence(),
            activeThumbColor: AppColors.online,
            trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? AppColors.online.withValues(alpha: 0.3)
                  : AppColors.borderDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

class _OnlineToggleSkeleton extends StatelessWidget {
  const _OnlineToggleSkeleton();

  @override
  Widget build(BuildContext context) => ShimmerCard(height: 74);
}

// ── Stats section ─────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.data});
  final dynamic data; // DashboardSummary

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todaysOverview,
          style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.todaysEarnings,
                value: formatCurrency(data.todayEarnings),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.accent,
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: l10n.thisWeek,
                value: formatCurrency(data.weekEarnings),
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
                delay: 250,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: l10n.totalConsults,
                value: '${data.totalConsultations}',
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.info,
                delay: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: l10n.rating,
                value: '${(data.ratingAvg as double).toStringAsFixed(1)} ★',
                icon: Icons.star_outline_rounded,
                color: AppColors.warning,
                delay: 350,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delay = 0,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.05);
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionChip(label: l10n.myProfile, icon: Icons.person_outline, onTap: () => context.go('/profile')),
            const SizedBox(width: 8),
            _ActionChip(label: l10n.earnings, icon: Icons.bar_chart_rounded, onTap: () => context.go('/earnings')),
            const SizedBox(width: 8),
            _ActionChip(label: l10n.consults, icon: Icons.chat_bubble_outline, onTap: () => context.go('/consultations')),
            const SizedBox(width: 8),
            _ActionChip(label: 'Kundli', icon: Icons.auto_stories_outlined, onTap: () => context.push('/kundli-requests')),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 4),
              Text(label, style: tt.labelSmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent activity (mock, dashboard shows last 3) ───────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const _mock = [
    (name: 'Priya M.', type: 'Chat', duration: '18 min', amount: 540.0, status: 'completed'),
    (name: 'Arjun S.', type: 'Voice', duration: '32 min', amount: 1280.0, status: 'completed'),
    (name: 'Sunita K.', type: 'Kundli', duration: '', amount: 500.0, status: 'pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentConsultations, style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
            TextButton(
              onPressed: () => context.go('/consultations'),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._mock.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ConsultationTile(
                  name: e.value.name,
                  type: e.value.type,
                  duration: e.value.duration,
                  amount: e.value.amount,
                  status: e.value.status,
                ).animate().fadeIn(delay: Duration(milliseconds: 500 + e.key * 80)),
              ),
            ),
      ],
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  const _ConsultationTile({
    required this.name,
    required this.type,
    required this.duration,
    required this.amount,
    required this.status,
  });

  final String name;
  final String type;
  final String duration;
  final double amount;
  final String status;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final typeColor = switch (type) {
      'Chat' => AppColors.info,
      'Voice' => AppColors.success,
      'Video' => AppColors.accent,
      'Kundli' => AppColors.primary,
      _ => AppColors.textSecondary,
    };

    return Container(
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
              color: typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(_emoji(type), style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: tt.titleSmall),
                Text(
                  '$type${duration.isNotEmpty ? ' · $duration' : ''}',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(amount),
                style: tt.titleSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              StatusBadge.fromStatus(status),
            ],
          ),
        ],
      ),
    );
  }

  String _emoji(String t) => switch (t) {
        'Chat' => '💬',
        'Voice' => '📞',
        'Video' => '📹',
        'Kundli' => '🔮',
        _ => '⭐',
      };
}

// ── Shimmer / error ───────────────────────────────────────────────────────────

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: ShimmerCard(height: 100)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerCard(height: 100)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ShimmerCard(height: 100)),
            const SizedBox(width: 12),
            Expanded(child: ShimmerCard(height: 100)),
          ],
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 8),
          Text(message, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
