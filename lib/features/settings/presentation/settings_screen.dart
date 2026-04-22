import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _chatNotifs = true;
  bool _callNotifs = true;
  bool _kundliNotifs = true;
  bool _earningsNotifs = true;
  bool _platformNotifs = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.notificationPreferences),
          _ToggleTile(
            icon: Icons.chat_bubble_outline,
            iconColor: AppColors.info,
            label: l10n.chatRequests,
            subtitle: l10n.chatRequestsDesc,
            value: _chatNotifs,
            onChanged: (v) => setState(() => _chatNotifs = v),
          ).animate().fadeIn(delay: 50.ms),
          _ToggleTile(
            icon: Icons.phone_outlined,
            iconColor: AppColors.success,
            label: l10n.callRequests,
            subtitle: l10n.callRequestsDesc,
            value: _callNotifs,
            onChanged: (v) => setState(() => _callNotifs = v),
          ).animate().fadeIn(delay: 80.ms),
          _ToggleTile(
            icon: Icons.auto_stories_outlined,
            iconColor: AppColors.primary,
            label: l10n.kundliRequests,
            subtitle: l10n.kundliRequestsDesc,
            value: _kundliNotifs,
            onChanged: (v) => setState(() => _kundliNotifs = v),
          ).animate().fadeIn(delay: 110.ms),
          _ToggleTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.accent,
            label: l10n.earningsUpdates,
            subtitle: l10n.earningsUpdatesDesc,
            value: _earningsNotifs,
            onChanged: (v) => setState(() => _earningsNotifs = v),
          ).animate().fadeIn(delay: 140.ms),
          _ToggleTile(
            icon: Icons.campaign_outlined,
            iconColor: AppColors.textSecondary,
            label: l10n.platformUpdates,
            subtitle: l10n.platformUpdatesDesc,
            value: _platformNotifs,
            onChanged: (v) => setState(() => _platformNotifs = v),
          ).animate().fadeIn(delay: 170.ms),

          _SectionHeader(title: l10n.alertStyle),
          _ToggleTile(
            icon: Icons.volume_up_outlined,
            iconColor: AppColors.primary,
            label: l10n.sound,
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ).animate().fadeIn(delay: 200.ms),
          _ToggleTile(
            icon: Icons.vibration_outlined,
            iconColor: AppColors.primary,
            label: l10n.vibration,
            value: _vibrationEnabled,
            onChanged: (v) => setState(() => _vibrationEnabled = v),
          ).animate().fadeIn(delay: 230.ms),

          _SectionHeader(title: l10n.securitySection),
          _NavTile(
            icon: Icons.lock_outline,
            iconColor: AppColors.error,
            label: l10n.changePassword,
            onTap: () => context.push('/settings/change-password'),
          ).animate().fadeIn(delay: 260.ms),
          _NavTile(
            icon: Icons.devices_outlined,
            iconColor: AppColors.textSecondary,
            label: l10n.activeSessions,
            onTap: () {},
          ).animate().fadeIn(delay: 290.ms),

          _SectionHeader(title: l10n.aboutSection),
          _NavTile(
            icon: Icons.star_outline,
            iconColor: AppColors.accent,
            label: l10n.rateApp,
            onTap: () {},
          ).animate().fadeIn(delay: 320.ms),
          _InfoTile(
            icon: Icons.info_outline,
            label: l10n.appVersion,
            value: '1.0.0 (build 1)',
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: tt.labelSmall?.copyWith(
              color: AppColors.textDisabled,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary)),
              ),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.textDisabled.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.textDisabled, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary)),
          ),
          Text(value, style: tt.bodySmall?.copyWith(color: AppColors.textDisabled)),
        ],
      ),
    );
  }
}
