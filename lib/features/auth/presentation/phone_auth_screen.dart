import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'widgets/auth_header.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final phone = '+91${_phoneController.text.trim()}';
    try {
      await ref.read(authControllerProvider.notifier).sendPhoneOtp(phone);
      if (mounted) context.push('/auth/otp', extra: {'phone': phone});
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const AuthHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                const SizedBox(height: 40),
                Text(
                  l10n.welcomeAstrologer,
                  style: tt.displayMedium?.copyWith(color: AppColors.textPrimary, height: 1.2),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  l10n.enterMobileNumber,
                  style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 36),
                _PhoneField(
                  controller: _phoneController,
                  onSubmitted: (_) => _sendOtp(),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.sendOtp,
                  onPressed: _sendOtp,
                  loading: _loading,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderDark)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.or,
                        style: tt.bodySmall?.copyWith(color: AppColors.textDisabled),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderDark)),
                  ],
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.signInWithEmail,
                  onPressed: () => context.push('/auth/email'),
                  variant: AppButtonVariant.outline,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    l10n.termsDisclaimer,
                    style: tt.bodySmall?.copyWith(color: AppColors.textDisabled, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mobileNumber,
          style: tt.labelMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: Validators.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onSubmitted,
          style: tt.bodyLarge?.copyWith(color: AppColors.textPrimary, letterSpacing: 1),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '+91',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            hintText: l10n.mobileNumberHint,
          ),
        ),
      ],
    );
  }
}
