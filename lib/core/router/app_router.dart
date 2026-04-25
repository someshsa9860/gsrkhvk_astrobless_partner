import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/email_auth_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/consultations/presentation/consultation_history_screen.dart';
import '../../features/consultations/presentation/consultation_detail_screen.dart';
import '../../features/consultations/presentation/chat_consultation_screen.dart';
import '../../features/consultations/presentation/call_screen.dart';
import '../../features/earnings/presentation/earnings_screen.dart';
import '../../features/earnings/presentation/payout_history_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/change_password_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/kyc_screen.dart';
import '../../features/kundli/presentation/kundli_request_list_screen.dart';
import '../../features/kundli/presentation/kundli_request_detail_screen.dart';
import '../../features/kundli/presentation/kundli_report_composer_screen.dart';
import '../auth/token_storage.dart';
import 'app_routes.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.authPhone,
    redirect: (context, state) async {
      final hasTokens = await TokenStorage.hasTokens();
      final path = state.matchedLocation;
      final isAuthPath = path.startsWith('/auth');

      if (!hasTokens && !isAuthPath) return AppRoutes.authPhone;
      if (hasTokens && isAuthPath) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.authPhone,
        builder: (_, __) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.authOtp,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(
            phone: extra['phone'] as String?,
            email: extra['email'] as String?,
            isEmailMode: extra['isEmailMode'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.authEmail,
        builder: (_, __) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.authForgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Onboarding ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingKyc,
        builder: (_, __) => const KycScreen(),
      ),

      // ── Notifications ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),

      // ── Settings ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsChangePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),

      // ── Profile edit ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (_, __) => const EditProfileScreen(),
      ),

      // ── Consultation detail ───────────────────────────────────────────
      GoRoute(
        path: '/consultation/:id',
        builder: (_, state) => ConsultationDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/chat/:id',
        builder: (_, state) => ChatConsultationScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/consultation/call/:id',
        builder: (_, state) => CallScreen(id: state.pathParameters['id']!),
      ),

      // ── Payout history ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.earningsPayouts,
        builder: (_, __) => const PayoutHistoryScreen(),
      ),

      // ── Kundli requests ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.kundliRequests,
        builder: (_, __) => const KundliRequestListScreen(),
      ),
      GoRoute(
        path: '/kundli-requests/:id',
        builder: (_, state) => KundliRequestDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/kundli-requests/:id/compose',
        builder: (_, state) => KundliReportComposerScreen(id: state.pathParameters['id']!),
      ),

      // ── Home shell (bottom nav) ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.consultations, builder: (_, __) => const ConsultationHistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.earnings, builder: (_, __) => const EarningsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
