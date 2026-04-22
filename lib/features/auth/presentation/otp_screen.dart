import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone, this.email, this.isEmailMode = false});

  final String? phone;
  final String? email;
  final bool isEmailMode;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = 60;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    try {
      final notifier = ref.read(authControllerProvider.notifier);
      if (widget.isEmailMode) {
        await notifier.verifyEmailOtp(widget.email!, otp);
      } else {
        await notifier.verifyPhoneOtp(widget.phone!, otp);
      }
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _errorText = _friendlyError(e);
        _otpController.clear();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final l10n = AppLocalizations.of(context);
    final msg = e.toString();
    if (msg.contains('OTP_INVALID')) return l10n.otpInvalidError;
    if (msg.contains('OTP_EXPIRED')) return l10n.otpExpiredError;
    if (msg.contains('OTP_ATTEMPTS_EXCEEDED')) return l10n.otpAttemptsError;
    return msg.replaceAll('Exception:', '').trim();
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    try {
      final notifier = ref.read(authControllerProvider.notifier);
      if (widget.isEmailMode) {
        await notifier.resendEmailOtp(widget.email!);
      } else {
        await notifier.sendPhoneOtp(widget.phone!);
      }
      _startTimer();
      setState(() => _errorText = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    final target = widget.isEmailMode ? widget.email! : widget.phone!;
    final maskedTarget = widget.isEmailMode
        ? _maskEmail(target)
        : target.replaceRange(5, 8, '***');

    final defaultTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: tt.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(l10n.enterOtp, style: tt.headlineLarge)
                  .animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: l10n.otpSentTo),
                    TextSpan(
                      text: maskedTarget,
                      style: tt.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.error, width: 2),
                    ),
                  ),
                  onCompleted: _verify,
                ),
              ).animate().fadeIn(delay: 150.ms),
              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: tt.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ).animate().shakeX(hz: 4, amount: 4),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: l10n.verify,
                onPressed: () => _verify(_otpController.text),
                loading: _loading,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 28),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        l10n.resendCountdown(_secondsLeft.toString().padLeft(2, '0')),
                        style: tt.bodyMedium?.copyWith(color: AppColors.textDisabled),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: Text(
                          l10n.resendCode,
                          style: tt.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ).animate().fadeIn(delay: 250.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name.substring(0, 2)}***@$domain';
  }
}
