/// Single source of truth for all named route paths in the Partner app.
///
/// Rules (enforced by CLAUDE.md):
/// - Never hardcode a route string outside this file.
/// - Use [AppRoutes.consultationChat] etc. for parameterised paths.
/// - All paths are **relative** to the router's root (leading `/` included).
abstract final class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authEmail = '/auth/email';
  static const authForgotPassword = '/auth/forgot-password';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const onboarding = '/onboarding';
  static const onboardingKyc = '/onboarding/kyc';

  // ── Bottom nav shell ──────────────────────────────────────────────────────

  static const home = '/home';
  static const consultations = '/consultations';
  static const earnings = '/earnings';
  static const profile = '/profile';

  // ── Consultations ─────────────────────────────────────────────────────────

  static String consultationDetail(String id) => '/consultation/$id';
  static String consultationChat(String id) => '/consultation/chat/$id';
  static String consultationCall(String id) => '/consultation/call/$id';

  // ── Earnings ──────────────────────────────────────────────────────────────

  static const earningsPayouts = '/earnings/payouts';

  // ── Kundli requests ───────────────────────────────────────────────────────

  static const kundliRequests = '/kundli-requests';
  static String kundliRequestDetail(String id) => '/kundli-requests/$id';
  static String kundliRequestCompose(String id) => '/kundli-requests/$id/compose';

  // ── Profile ───────────────────────────────────────────────────────────────

  static const profileEdit = '/profile/edit';

  // ── Notifications ─────────────────────────────────────────────────────────

  static const notifications = '/notifications';

  // ── Settings ─────────────────────────────────────────────────────────────

  static const settings = '/settings';
  static const settingsChangePassword = '/settings/change-password';
}
