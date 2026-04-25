import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).forgotPassword(_emailCtrl.text.trim());
      if (mounted) setState(() { _loading = false; _sent = true; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      Get.showSnackbar(GetSnackBar(
        message: e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: AppColors.error,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context).forgotPassword),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent
              ? _SuccessView(email: _emailCtrl.text)
              : _FormView(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  loading: _loading,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 28),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 20),
          Text(
            l10n.forgotPassword,
            style: tt.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            "Enter the email address linked to your account. We'll send a reset code.",
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: Validators.email,
            onFieldSubmitted: (_) => onSubmit(),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Send Reset Code',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
            ),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 40),
          ).animate().scale().fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Check your inbox',
            style: tt.headlineSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a password reset link to\n$email',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to sign in', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
