import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/consultation_models.dart';

class IncomingRequestSheet extends ConsumerStatefulWidget {
  const IncomingRequestSheet({super.key, required this.request});
  final IncomingRequest request;

  static Future<void> show(BuildContext context, IncomingRequest request) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => IncomingRequestSheet(request: request),
    );
  }

  @override
  ConsumerState<IncomingRequestSheet> createState() =>
      _IncomingRequestSheetState();
}

class _IncomingRequestSheetState extends ConsumerState<IncomingRequestSheet> {
  static const _totalSeconds = 30;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _autoReject();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _autoReject() {
    if (!mounted) return;
    ref
        .read(socketServiceProvider)
        .rejectConsultation(widget.request.consultationId, reason: 'timeout');
    if (mounted) Navigator.of(context).pop();
  }

  void _accept() {
    _timer?.cancel();
    final socket = ref.read(socketServiceProvider);
    socket.acceptConsultation(widget.request.consultationId);
    Navigator.of(context).pop();

    final type = widget.request.type;
    final id = widget.request.consultationId;
    if (type == 'chat') {
      context.push('/consultation/chat/$id');
    } else {
      context.push('/consultation/call/$id');
    }
  }

  void _reject() {
    _timer?.cancel();
    ref
        .read(socketServiceProvider)
        .rejectConsultation(widget.request.consultationId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final req = widget.request;
    final progress = _secondsLeft / _totalSeconds;
    final isChat = req.type == 'chat';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Countdown ring + avatar
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: AppColors.borderDark,
                    color: _secondsLeft <= 10
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                ),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    req.customerName.isNotEmpty
                        ? req.customerName[0].toUpperCase()
                        : '?',
                    style: tt.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 300.ms),
            const SizedBox(height: 16),

            Text(
              req.customerName,
              style: tt.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isChat ? Icons.chat_bubble_outline : Icons.phone_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isChat
                      ? l10n.incomingChatRequest
                      : l10n.incomingCallRequest,
                  style: tt.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Text(
              '₹${req.pricePerMin.toStringAsFixed(2)}/min',
              style: tt.bodyLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '$_secondsLeft ${l10n.secondsLeft}',
              style: tt.labelMedium?.copyWith(
                color: _secondsLeft <= 10
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.decline),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
