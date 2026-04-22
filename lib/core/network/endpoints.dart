/// Central registry of all API endpoint paths for the Partner (Astrologer) app.
///
/// All paths are **relative** to [AppConfig.apiBaseUrl]
/// (e.g. `http://10.0.2.2:3000/v1/astrologer`).
///
/// Usage:
/// ```dart
/// final res = await ref.read(apiClientProvider).get(Endpoints.profile.me);
/// ```
library;

/// Namespaced endpoint paths for the Astrologer API.
abstract final class Endpoints {
  Endpoints._();

  /// Authentication routes (`/auth/*`).
  static const auth = _AuthEndpoints._();

  /// Astrologer profile routes (`/profile/*`).
  static const profile = _ProfileEndpoints._();

  /// Consultation routes (`/consultations/*`).
  static const consultations = _ConsultationEndpoints._();

  /// Earnings and payout routes (`/earnings/*`, `/payouts`).
  static const earnings = _EarningsEndpoints._();

  /// Kundli report request routes (`/kundli-requests/*`).
  static const kundli = _KundliEndpoints._();

  /// In-app notification routes (`/notifications/*`).
  static const notifications = _NotificationEndpoints._();

  /// Image upload route (`/upload/*`).
  static const uploads = _UploadEndpoints._();
}

// ─── Auth ──────────────────────────────────────────────────────────────────

final class _AuthEndpoints {
  const _AuthEndpoints._();

  /// `POST` – Send a 6-digit OTP to [phone] via SMS (MSG91).
  /// Rate-limited: 5 per hour per phone, 20 per hour per IP.
  String get sendPhoneOtp => '/auth/phone/send-otp';

  /// `POST` – Verify phone OTP and issue [accessToken] + [refreshToken].
  String get verifyPhoneOtp => '/auth/phone/verify-otp';

  /// `POST` – Begin email sign-up. Triggers an email OTP for verification.
  String get emailSignup => '/auth/email/signup';

  /// `POST` – Verify the email OTP sent during sign-up.
  String get verifyEmailOtp => '/auth/email/verify-otp';

  /// `POST` – Resend the email verification OTP (rate-limited: 3/hr/email).
  String get resendEmailOtp => '/auth/email/resend-otp';

  /// `POST` – Log in with email + password after email verification.
  String get emailLogin => '/auth/email/login';

  /// `POST` – Initiate a password reset; sends a link to the registered email.
  String get forgotPassword => '/auth/email/forgot-password';

  /// `POST` – Rotate the refresh token and receive a fresh access token.
  String get refresh => '/auth/refresh';

  /// `DELETE` – Revoke the current session (server-side logout).
  String get logout => '/auth/logout';
}

// ─── Profile ───────────────────────────────────────────────────────────────

final class _ProfileEndpoints {
  const _ProfileEndpoints._();

  /// `GET` – Fetch the authenticated astrologer's full profile.
  String get me => '/profile';

  /// `PATCH` – Update profile fields (name, bio, languages, specialties, etc.).
  String get update => '/profile';

  /// `PATCH` – Toggle online/offline presence status.
  String get presence => '/profile/presence';

  /// `PATCH` – Update per-minute chat and call pricing.
  String get pricing => '/profile/pricing';
}

// ─── Consultations ─────────────────────────────────────────────────────────

final class _ConsultationEndpoints {
  const _ConsultationEndpoints._();

  /// `GET` – Paginated list of the astrologer's consultations.
  /// Query params: `status`, `type`, `limit`, `page`.
  String get list => '/consultations';

  /// `GET` – Detail of a single consultation.
  String detail(String id) => '/consultations/$id';

  /// `GET` – Paginated chat messages for a consultation.
  /// Query params: `afterId`, `limit`.
  String messages(String id) => '/consultations/$id/messages';

  /// `POST` – Accept an incoming consultation request.
  String accept(String id) => '/consultations/$id/accept';

  /// `POST` – Reject an incoming consultation request.
  String reject(String id) => '/consultations/$id/reject';

  /// `POST` – End an active consultation.
  String end(String id) => '/consultations/$id/end';
}

// ─── Earnings ──────────────────────────────────────────────────────────────

final class _EarningsEndpoints {
  const _EarningsEndpoints._();

  /// `GET` – Aggregated earnings summary (today, this week, all-time).
  String get summary => '/earnings/summary';

  /// `GET` – Paginated earning transaction list.
  /// Query params: `page`, `limit`, `from`, `to`.
  String get list => '/earnings';

  /// `GET` – Paginated payout history.
  String get payouts => '/payouts';
}

// ─── Kundli Requests ───────────────────────────────────────────────────────

final class _KundliEndpoints {
  const _KundliEndpoints._();

  /// `GET` – Paginated list of kundli report requests assigned to this astrologer.
  /// Query params: `status`, `limit`, `page`.
  String get list => '/kundli-requests';

  /// `GET` – Detail of a single kundli request.
  String detail(String id) => '/kundli-requests/$id';

  /// `POST` – Accept a kundli request and commit to an SLA.
  /// Body: `{ slaDurationHours: 6 | 12 | 24 }`.
  String accept(String id) => '/kundli-requests/$id/accept';

  /// `POST` – Decline a kundli request with a reason.
  /// Body: `{ reason }`.
  String decline(String id) => '/kundli-requests/$id/decline';

  /// `POST` – Submit the completed kundli report.
  /// Body: `{ reportText, reportPdfS3Key? }`.
  String submit(String id) => '/kundli-requests/$id/submit';
}

// ─── Notifications ─────────────────────────────────────────────────────────

final class _NotificationEndpoints {
  const _NotificationEndpoints._();

  /// `GET` – Paginated list of in-app notifications.
  /// Query params: `page`, `limit`.
  String get list => '/notifications';

  /// `PATCH` – Mark a single notification as read.
  String markRead(String id) => '/notifications/$id/read';

  /// `POST` – Mark all notifications as read.
  String get markAllRead => '/notifications/read-all';

  /// `POST` – Register or refresh an FCM device token.
  String get registerFcmToken => '/notifications/fcm-token';
}

// ─── Uploads ───────────────────────────────────────────────────────────────

final class _UploadEndpoints {
  const _UploadEndpoints._();

  /// `GET` – Request a pre-signed PUT URL for direct S3 upload.
  /// Query params: `category` (profiles | kyc), `contentType` (MIME type).
  /// Returns `{ uploadUrl, tempKey, expiresIn }`.
  String get presign => '/upload/presign';

  /// `POST` – Upload an image (multipart/form-data). Legacy — kept for compat.
  String get image => '/upload/image';
}
