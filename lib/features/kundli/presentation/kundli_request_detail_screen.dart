import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';
import 'kundli_controller.dart';

class KundliRequestDetailScreen extends ConsumerWidget {
  const KundliRequestDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kundliRequestDetailProvider(id));
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Kundli Request'),
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
              Text('Failed to load', style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(kundliRequestDetailProvider(id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (request) => _DetailBody(request: request),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.request});
  final KundliRequest request;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  bool _accepting = false;
  bool _declining = false;
  int _selectedSla = 24;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await ref.read(kundliRepositoryProvider).acceptRequest(widget.request.id, _selectedSla);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/kundli-requests/${widget.request.id}/compose');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _decline() async {
    final reason = await _showDeclineDialog();
    if (reason == null) return;
    setState(() => _declining = true);
    try {
      await ref.read(kundliRepositoryProvider).declineRequest(widget.request.id, reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined'), backgroundColor: AppColors.error),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _declining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _showDeclineDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Decline Request', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Reason (optional)',
            hintStyle: TextStyle(color: AppColors.textDisabled),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim().isEmpty ? 'No reason given' : ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final tt = Theme.of(context).textTheme;
    final isPending = r.status == 'pending';
    final isInProgress = r.status == 'inProgress';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Customer',
          children: [
            _InfoRow(icon: Icons.person_outline, label: 'Name', value: r.customerName),
          ],
        ).animate().fadeIn(),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Birth Details',
          children: [
            _InfoRow(icon: Icons.cake_outlined, label: 'Date', value: formatDate(r.birthDate)),
            if (r.birthTime != null)
              _InfoRow(icon: Icons.access_time_outlined, label: 'Time', value: r.birthTime!),
            _InfoRow(icon: Icons.location_on_outlined, label: 'Place', value: r.birthPlace),
          ],
        ).animate().fadeIn(delay: 60.ms),
        if (r.question != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Question',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  r.question!,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
        ],
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Earnings',
          children: [
            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Your earning',
              value: formatPaiseExact((r.priceAtOrderPaise * 0.7).round()),
            ),
            _InfoRow(
              icon: Icons.receipt_outlined,
              label: 'Customer paid',
              value: formatPaiseExact(r.priceAtOrderPaise),
            ),
          ],
        ).animate().fadeIn(delay: 140.ms),
        if (isPending) ...[
          const SizedBox(height: 24),
          Text(
            'Select SLA',
            style: tt.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ).animate().fadeIn(delay: 180.ms),
          const SizedBox(height: 8),
          Row(
            children: [6, 12, 24].map((h) {
              final selected = _selectedSla == h;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSla = h),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.borderDark,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${h}h',
                          style: tt.titleSmall?.copyWith(
                            color: selected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$h hours',
                          style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 200 + h)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _declining ? null : _decline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _declining
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _accepting ? null : _accept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _accepting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Accept & Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 280.ms),
        ],
        if (isInProgress) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/kundli-requests/${r.id}/compose'),
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              label: const Text('Write Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(delay: 180.ms),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: AppColors.textDisabled,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
