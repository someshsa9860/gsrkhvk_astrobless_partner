import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../l10n/app_localizations.dart';
import '../data/consultations_repository.dart';
import '../domain/consultation_models.dart';
import 'consultation_controller.dart';

class ChatConsultationScreen extends ConsumerStatefulWidget {
  const ChatConsultationScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ChatConsultationScreen> createState() =>
      _ChatConsultationScreenState();
}

class _ChatConsultationScreenState
    extends ConsumerState<ChatConsultationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  bool _customerLowBalance = false;
  Timer? _typingTimer;
  int _secondsLeft = 1800; // updated by billing ticks
  Timer? _localTimer;
  StreamSubscription? _endedSub;
  StreamSubscription? _lowBalanceSub;

  @override
  void initState() {
    super.initState();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _secondsLeft > 0) {
        setState(() => _secondsLeft--);
      }
    });

    // Listen for consultation ended event
    _endedSub = ref
        .read(socketServiceProvider)
        .onConsultationEnded
        .where((e) => e['consultationId'] == widget.id)
        .listen((_) {
      if (mounted) context.pop();
    });

    _lowBalanceSub = ref
        .read(socketServiceProvider)
        .onLowBalance
        .where((e) => e['consultationId'] == widget.id)
        .listen((_) {
      if (mounted) setState(() => _customerLowBalance = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _localTimer?.cancel();
    _endedSub?.cancel();
    _lowBalanceSub?.cancel();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final clientMsgId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimistic = ChatMessage(
      id: clientMsgId,
      consultationId: widget.id,
      senderType: 'astrologer',
      body: text,
      createdAt: DateTime.now(),
      clientMsgId: clientMsgId,
    );

    ref.read(chatMessagesProvider(widget.id).notifier).addOptimistic(optimistic);
    ref.read(socketServiceProvider).sendMessage(
          consultationId: widget.id,
          body: text,
          clientMsgId: clientMsgId,
        );
    _controller.clear();
    _stopTyping();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged(String _) {
    if (!_isTyping) {
      _isTyping = true;
      ref.read(socketServiceProvider).sendTypingStart(widget.id);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      ref.read(socketServiceProvider).sendTypingStop(widget.id);
    }
  }

  Future<void> _confirmEnd() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.endConsultationTitle),
        content: Text(l10n.endConsultationBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.endButton),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(consultationsRepositoryProvider)
          .endConsultation(widget.id, reason: 'astrologerEnded');
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final messagesState = ref.watch(chatMessagesProvider(widget.id));

    // Update seconds left from billing tick
    ref.listen(billingTickProvider(widget.id), (_, next) {
      next.whenData((tick) {
        if (mounted) setState(() => _secondsLeft = tick.remainingSeconds);
      });
    });

    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    final isLow = _secondsLeft < 300;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text('P', style: tt.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.customerLabel, style: tt.titleSmall?.copyWith(fontSize: 15)),
                Text(
                  l10n.activeConsultation,
                  style: tt.labelSmall?.copyWith(color: AppColors.online),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isLow ? AppColors.error.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLow ? AppColors.error.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: isLow ? AppColors.error : AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '$mins:${secs.toString().padLeft(2, '0')}',
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLow ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_end_rounded, color: AppColors.error),
            onPressed: _confirmEnd,
          ),
        ],
      ),
      body: Column(
        children: [
          // Billing bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: _customerLowBalance
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.surfaceDark,
            child: Row(
              children: [
                Icon(
                  _customerLowBalance
                      ? Icons.warning_amber_rounded
                      : Icons.account_balance_wallet_outlined,
                  size: 14,
                  color: _customerLowBalance ? AppColors.error : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _customerLowBalance
                      ? l10n.customerBalanceLowSession
                      : l10n.chatBillingBar,
                  style: tt.labelSmall?.copyWith(
                    color: _customerLowBalance ? AppColors.error : AppColors.textSecondary,
                    fontWeight: _customerLowBalance ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: messagesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: AppColors.error))),
              data: (messages) => messages.isEmpty
                  ? Center(
                      child: Text(
                        l10n.typeMessage,
                        style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) => _ChatBubble(message: messages[i])
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: 0.1),
                    ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(top: BorderSide(color: AppColors.borderDark)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
                      onChanged: _onTextChanged,
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        filled: true,
                        fillColor: AppColors.inputDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.borderDark),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.borderDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.brandGradient),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Align(
      alignment: message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: message.isFromMe ? 60 : 0,
          right: message.isFromMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isFromMe ? AppColors.bubbleSent : AppColors.bubbleReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isFromMe ? 16 : 4),
            bottomRight: Radius.circular(message.isFromMe ? 4 : 16),
          ),
          border: Border.all(
            color: message.isFromMe ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime(message.createdAt),
              style: tt.labelSmall?.copyWith(fontSize: 10, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
