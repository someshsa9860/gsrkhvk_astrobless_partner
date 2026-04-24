import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/consultation_models.dart';
import 'consultation_controller.dart';

class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  ConsumerState<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends ConsumerState<ConsultationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  static const _statusMap = ['', 'ended', 'requested,accepted'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() => _tabIndex = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(consultationsProvider(_statusMap[_tabIndex]));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consultationsTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: l10n.allTab),
            Tab(text: l10n.completedTab),
            Tab(text: l10n.pendingTab),
          ],
        ),
      ),
      body: data.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, __) => const ShimmerCard(height: 80),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 8),
              Text(e.toString(), style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(consultationsProvider),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => _ConsultationCard(
                  consultation: list[i],
                  onTap: () => ctx.push('/consultation/${list[i].id}'),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
              ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({required this.consultation, required this.onTap});
  final Consultation consultation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final typeColor = _typeColor(consultation.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_typeEmoji(consultation.type), style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(consultation.customerName, style: tt.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${consultation.type} · ${formatDate(consultation.requestedAt)}',
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  if (consultation.durationSeconds > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatDuration(consultation.durationSeconds),
                      style: tt.labelSmall?.copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (consultation.astrologerEarning > 0)
                  Text(
                    '+${formatPaise(consultation.astrologerEarning)}',
                    style: tt.titleSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                const SizedBox(height: 6),
                StatusBadge.fromStatus(consultation.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) => switch (type) {
        'chat' => AppColors.info,
        'voice' => AppColors.success,
        'video' => AppColors.accent,
        'kundli' => AppColors.primary,
        _ => AppColors.textSecondary,
      };

  String _typeEmoji(String type) => switch (type) {
        'chat' => '💬',
        'voice' => '📞',
        'video' => '📹',
        'kundli' => '🔮',
        _ => '⭐',
      };
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(l10n.noConsultationsYet, style: tt.titleMedium),
          const SizedBox(height: 6),
          Text(
            l10n.goOnlineHint,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

