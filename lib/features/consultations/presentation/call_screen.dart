import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/app_config.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/consultations_repository.dart';
import '../domain/consultation_models.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  RtcEngine? _engine;
  bool _remoteJoined = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _isEnding = false;
  bool _customerLowBalance = false;
  int _secondsElapsed = 0;
  Timer? _elapsed;
  StreamSubscription? _callEndedSub;
  StreamSubscription? _billingTickSub;
  StreamSubscription? _lowBalanceSub;
  BillingTick? _lastTick;
  String? _channelName;
  String? _agoraToken;
  String _callType = 'voice';
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    // Request permissions
    final statuses = await [Permission.microphone, Permission.camera].request();
    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      setState(() => _error = 'Microphone permission is required for calls.');
      return;
    }

    // Fetch consultation to get channel info (set by server after accept)
    try {
      final consultation = await ref
          .read(consultationsRepositoryProvider)
          .fetchConsultation(widget.id);
      _channelName = consultation.id; // fallback; server may set agoraChannelName
      _callType = consultation.type;
    } catch (_) {}

    // Listen for call:incoming to get the actual token
    // (token was delivered via socket before routing here)
    // If not available, try to get it from the socket service directly
    // In a real app, the callIncoming event would have been stored before routing
    _callEndedSub = ref
        .read(socketServiceProvider)
        .onCallEnded
        .where((e) => e['consultationId'] == widget.id)
        .listen((_) => _endCall(reason: 'remoteEnded'));

    _billingTickSub = ref
        .read(socketServiceProvider)
        .onBillingTick
        .where((t) => t.consultationId == widget.id)
        .listen((tick) {
      if (mounted) setState(() => _lastTick = tick);
    });

    _lowBalanceSub = ref
        .read(socketServiceProvider)
        .onLowBalance
        .where((e) => e['consultationId'] == widget.id)
        .listen((_) {
      if (mounted) setState(() => _customerLowBalance = true);
    });

    _elapsed = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    await _startAgora();
  }

  Future<void> _startAgora() async {
    if (AppConfig.agoraAppId.isEmpty) {
      return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: AppConfig.agoraAppId));

      if (_callType == 'video') {
        await _engine!.enableVideo();
      } else {
        await _engine!.enableAudio();
      }

      _engine!.registerEventHandler(RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          if (mounted) setState(() => _remoteJoined = true);
        },
        onUserOffline: (connection, uid, reason) {
          if (mounted) setState(() => _remoteJoined = false);
          _endCall(reason: 'remoteLeft');
        },
        onError: (err, msg) {
          debugPrint('[Agora] error $err: $msg');
        },
      ));

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.joinChannel(
        token: _agoraToken ?? '',
        channelId: _channelName ?? widget.id,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (_speakerOn) {
        await _engine!.setEnableSpeakerphone(true);
      }
    } catch (e) {
      debugPrint('[Agora] init error: $e');
    }
  }

  Future<void> _endCall({String reason = 'astrologerEnded'}) async {
    if (_isEnding) return;
    setState(() => _isEnding = true);

    _elapsed?.cancel();
    try {
      await ref
          .read(consultationsRepositoryProvider)
          .endConsultation(widget.id, reason: reason);
    } catch (_) {}

    await _engine?.leaveChannel();
    await _engine?.release();

    if (mounted) context.pop();
  }

  void _toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
    setState(() {});
  }

  void _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine?.setEnableSpeakerphone(_speakerOn);
    setState(() {});
  }

  String _formatElapsed() {
    final m = _secondsElapsed ~/ 60;
    final s = _secondsElapsed % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _elapsed?.cancel();
    _callEndedSub?.cancel();
    _billingTickSub?.cancel();
    _lowBalanceSub?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_off, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                const SizedBox(height: 60),
                // Avatar / remote video
                Expanded(
                  child: _callType == 'video' && _remoteJoined
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine!,
                            canvas: const VideoCanvas(uid: 0),
                            connection: RtcConnection(channelId: _channelName ?? widget.id),
                          ),
                        )
                      : _buildVoiceView(l10n, tt),
                ),
                const SizedBox(height: 24),

                // Billing ticker
                if (_lastTick != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _customerLowBalance
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: _customerLowBalance
                          ? Border.all(color: AppColors.error.withValues(alpha: 0.5))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _customerLowBalance ? Icons.warning_amber_rounded : Icons.timer_outlined,
                          size: 14,
                          color: _customerLowBalance ? AppColors.error : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _customerLowBalance
                              ? 'Customer balance low — call may end soon'
                              : '${(_lastTick!.remainingSeconds ~/ 60)}m left · ₹${_lastTick!.balance.toStringAsFixed(2)} balance',
                          style: tt.labelMedium?.copyWith(
                            color: _customerLowBalance ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _muted ? l10n.unmute : l10n.mute,
                        onTap: _toggleMute,
                        active: !_muted,
                      ),
                      _EndCallButton(onTap: () => _endCall()),
                      _ControlButton(
                        icon: _speakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: l10n.speaker,
                        onTap: _toggleSpeaker,
                        active: _speakerOn,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Top info bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatElapsed(),
                          style: tt.labelMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceView(AppLocalizations l10n, TextTheme tt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            '?',
            style: tt.displaySmall?.copyWith(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _remoteJoined ? l10n.callConnected : l10n.callConnecting,
          style: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          _formatElapsed(),
          style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.primary : AppColors.borderDark,
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).endCall,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
