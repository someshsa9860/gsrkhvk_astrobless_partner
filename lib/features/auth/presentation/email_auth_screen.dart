import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loginLoading = false;
  bool _signupLoading = false;
  bool _obscureLogin = true;
  bool _obscureSignup = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).emailLogin(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _signupLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).emailSignup(
            email: _signupEmailController.text.trim(),
            password: _signupPasswordController.text,
            displayName: _nameController.text.trim(),
          );
      if (mounted) {
        context.push(
          '/auth/otp',
          extra: {'email': _signupEmailController.text.trim(), 'isEmailMode': true},
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _signupLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception:', '').trim()),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.emailSignInTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: l10n.signInTab),
            Tab(text: l10n.registerTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginTab(
            formKey: _loginFormKey,
            emailController: _emailController,
            passwordController: _passwordController,
            obscure: _obscureLogin,
            onToggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
            loading: _loginLoading,
            onSubmit: _login,
          ),
          _SignupTab(
            formKey: _signupFormKey,
            emailController: _signupEmailController,
            passwordController: _signupPasswordController,
            nameController: _nameController,
            obscure: _obscureSignup,
            onToggleObscure: () => setState(() => _obscureSignup = !_obscureSignup),
            loading: _signupLoading,
            onSubmit: _signup,
          ),
        ],
      ),
    );
  }
}

class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(l10n.signInToAccount, style: tt.headlineSmall),
            const SizedBox(height: 4),
            Text(
              l10n.enterCredentials,
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Text(l10n.emailAddress, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.emailHint,
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.password, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              obscureText: obscure,
              validator: (v) => v == null || v.isEmpty ? l10n.passwordRequired : null,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/auth/forgot-password'),
                child: Text(l10n.forgotPassword),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(label: l10n.signInTab, onPressed: onSubmit, loading: loading),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _SignupTab extends StatelessWidget {
  const _SignupTab({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.obscure,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(l10n.createYourAccount, style: tt.headlineSmall),
            const SizedBox(height: 4),
            Text(l10n.joinAsPro, style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            Text(l10n.fullName, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              validator: (v) => Validators.required(v, l10n.fullName),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.fullNameHint,
                prefixIcon: const Icon(Icons.person_outline, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.emailAddress, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.emailHint,
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.password, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              obscureText: obscure,
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.passwordHint,
              style: tt.labelSmall?.copyWith(color: AppColors.textDisabled),
            ),
            const SizedBox(height: 24),
            AppButton(label: l10n.createAccountButton, onPressed: onSubmit, loading: loading),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.emailVerificationNotice,
                style: tt.bodySmall?.copyWith(color: AppColors.textDisabled),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
