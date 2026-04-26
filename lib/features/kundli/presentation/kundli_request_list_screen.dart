import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/kundli_models.dart';
import 'kundli_controller.dart';

class KundliRequestListScreen extends ConsumerStatefulWidget {
  const KundliRequestListScreen({super.key});

  @override
  ConsumerState<KundliRequestListScreen> createState() =>
      _KundliRequestListScreenState();
}

class _KundliRequestListScreenState extends ConsumerState<KundliRequestListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Labels resolved in build() via l10n
  static const _tabStatuses = ['pending', 'inProgress', 'completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabStatuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabLabels = [l10n.pendingTab, l10n.inProgressTab, l10n.completedTab];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.kundliRequestsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabStatuses
            .map((s) => _RequestList(status: s).animate().fadeIn())
            .toList(),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(kundliRequestsProvider(status));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.errorGeneric, style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(kundliRequestsProvider(status)),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories_outlined,
                    size: 56, color: AppColors.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No ${status == 'inProgress' ? 'in-progress' : status} requests',
                  style: tt.titleSmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(kundliRequestsProvider(status)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, i) => _RequestCard(request: requests[i])
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 50)),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final KundliRequest request;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final (statusColor, statusLabel) = switch (request.status) {
      'pending' => (AppColors.warning, 'Pending'),
      'inProgress' => (AppColors.info, 'In Progress'),
      'completed' => (AppColors.success, 'Completed'),
      'declined' => (AppColors.error, 'Declined'),
      _ => (AppColors.textSecondary, 'Expired'),
    };

    return GestureDetector(
      onTap: () => context.push(AppRoutes.kundliRequestDetail(request.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories_outlined,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.customerName,
                    style: tt.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.cake_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Born ${formatDate(request.birthDate)}',
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.birthPlace,
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (request.question != null) ...[
              const SizedBox(height: 6),
              Text(
                '"${request.question}"',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrencyExact(request.priceAtOrder),
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (request.slaDueAt != null &&
                    request.status == 'inProgress') ...[
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Due ${formatDateTime(request.slaDueAt!)}',
                        style: tt.labelSmall?.copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    formatDateTime(request.createdAt),
                    style: tt.bodySmall?.copyWith(color: AppColors.textDisabled),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
