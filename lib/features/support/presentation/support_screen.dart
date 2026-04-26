import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../data/support_repository.dart';
import '../domain/support_models.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ticketsAsync = ref.watch(ticketsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.supportTicketsTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<bool>(AppRoutes.supportNewTicket);
          if (created == true) {
            ref.read(ticketsNotifierProvider.notifier).refresh();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: ticketsAsync.when(
        loading: () => _TicketListSkeleton(),
        error: (_, __) => _ErrorState(onRetry: () => ref.read(ticketsNotifierProvider.notifier).refresh()),
        data: (tickets) => tickets.isEmpty
            ? _EmptyState(l10n: l10n)
            : _TicketList(tickets: tickets),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(l10n.errorGeneric, style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.support_agent_outlined, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(l10n.noTicketsYet, style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(l10n.noTicketsHint, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList({required this.tickets});
  final List<SupportTicket> tickets;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TicketCard(ticket: tickets[i])
          .animate()
          .fadeIn(delay: Duration(milliseconds: i * 40)),
    );
  }
}

class _TicketListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(color: AppColors.borderDark),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => context.push(AppRoutes.supportTicketDetail(ticket.id)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: ticket.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '#${ticket.ticketNumber} · ${ticket.category}',
              style: tt.labelSmall?.copyWith(color: AppColors.textDisabled),
            ),
            if (ticket.messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ticket.messages.last.body,
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});
  final String status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'open' => (l10n.statusOpen, AppColors.primary),
      'inProgress' => (l10n.statusInProgress, const Color(0xFF2196F3)),
      'waitingOnUser' => (l10n.statusWaitingOnUser, const Color(0xFFFF9800)),
      'resolved' => (l10n.statusResolved, AppColors.success),
      'closed' => (l10n.statusClosed, AppColors.textDisabled),
      _ => (status, AppColors.textDisabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
