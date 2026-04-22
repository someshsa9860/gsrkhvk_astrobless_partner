import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../connectivity/connectivity_service.dart';
import '../theme/app_colors.dart';

/// Wraps [child] with a top banner that appears when the device is offline.
/// Place this near the root of authenticated screens.
class OfflineBannerWrapper extends ConsumerWidget {
  const OfflineBannerWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline = connectivityAsync.when(
      data: (online) => !online,
      loading: () => false,
      error: (_, __) => false,
    );

    return Column(
      children: [
        AnimatedSlide(
          offset: isOffline ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: isOffline ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _OfflineBanner(visible: isOffline),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: AppColors.warning.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'No internet connection — showing cached data',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
