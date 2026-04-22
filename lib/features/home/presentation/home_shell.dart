import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../consultations/presentation/consultation_controller.dart';
import '../../consultations/presentation/incoming_request_sheet.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      ref.read(socketServiceProvider).connect(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Listen for incoming consultation requests → show bottom sheet
    ref.listen(incomingRequestProvider, (_, next) {
      next.whenData((request) {
        if (mounted) {
          IncomingRequestSheet.show(context, request);
        }
      });
    });

    // Listen for incoming calls → navigate to call screen
    ref.listen(callIncomingProvider, (_, next) {
      next.whenData((call) {
        if (mounted) {
          context.push('/consultation/call/${call.consultationId}');
        }
      });
    });

    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: l10n.navHome),
      _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: l10n.navConsults),
      _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: l10n.navEarnings),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: l10n.navProfile),
    ];

    return Scaffold(
      body: OfflineBannerWrapper(child: widget.shell),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderDark, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.shell.currentIndex,
          onTap: (i) => widget.shell.goBranch(i, initialLocation: i == widget.shell.currentIndex),
          items: items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
