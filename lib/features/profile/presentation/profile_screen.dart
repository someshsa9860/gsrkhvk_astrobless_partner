import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader().animate().fadeIn(),
          ),
          SliverToBoxAdapter(
            child: _StatsRow().animate().fadeIn(delay: 100.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: l10n.accountSection,
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  label: l10n.editProfileTitle,
                  onTap: () => context.push(AppRoutes.profileEdit),
                ),
                _MenuItem(
                  icon: Icons.star_outline,
                  label: l10n.reviewsRatings,
                  trailing: '4.8 ★',
                  trailingColor: AppColors.accent,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.verified_outlined,
                  label: l10n.kycStatus,
                  trailing: l10n.kycApproved,
                  trailingColor: AppColors.success,
                  onTap: () => context.push(AppRoutes.onboardingKyc),
                ),
                _MenuItem(
                  icon: Icons.account_balance_outlined,
                  label: l10n.bankPayoutDetails,
                  onTap: () {},
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),
          ),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: l10n.preferencesSection,
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: l10n.notificationSettings,
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _MenuItem(
                  icon: Icons.language_outlined,
                  label: l10n.languagesLabel,
                  trailing: 'Hindi, English',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.appearance,
                  trailing: l10n.darkTheme,
                  onTap: () {},
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
          SliverToBoxAdapter(
            child: _MenuSection(
              title: l10n.supportSection,
              items: [
                _MenuItem(
                  icon: Icons.confirmation_number_outlined,
                  label: l10n.myTickets,
                  onTap: () => context.push(AppRoutes.support),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: l10n.helpFaq,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.privacyPolicy,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: l10n.termsOfService,
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  label: l10n.appVersion,
                  trailing: '1.0.0',
                  trailingColor: AppColors.textDisabled,
                  onTap: null,
                ),
              ],
            ).animate().fadeIn(delay: 250.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(l10n.signOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.authPhone);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.inputDark, AppColors.bgDark],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  'P',
                  style: tt.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDark, width: 2),
                ),
                child: const Icon(Icons.circle, size: 10, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pandit Ramesh Ji',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Vedic Astrology · Numerology',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge.online(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '⭐ 4.8 · 256 reviews',
                  style: tt.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          _Stat(value: '4.8', label: l10n.rating),
          _StatDivider(),
          _Stat(value: '1.2K', label: l10n.consults),
          _StatDivider(),
          _Stat(value: '₹84K', label: l10n.earnings),
          _StatDivider(),
          _Stat(value: '8 yrs', label: 'Experience'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.borderDark);
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});
  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: tt.labelSmall?.copyWith(
                  color: AppColors.textDisabled,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Divider(indent: 52, endIndent: 0, height: 1, color: AppColors.borderDark),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: tt.bodySmall?.copyWith(
                  color: trailingColor ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textDisabled),
            ],
          ],
        ),
      ),
    );
  }
}
