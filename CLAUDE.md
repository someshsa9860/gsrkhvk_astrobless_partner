# CLAUDE.md — Astrobless Partner App (Astrologer)

> Master context file for AI assistants working on this Flutter codebase.
> Keep this file authoritative. If reality drifts from this doc, update the doc.
> Read the root `/CLAUDE.md` first — this file extends it, not replaces it.

---

## 1. What this app is

**App name:** Astrobless Partner  
**Persona:** Astrologer (called "partner" in the product, "astrologer" in the DB/API)  
**Platform:** Flutter 3.x — iOS + Android  
**Backend:** Connects to the same Node.js/Fastify backend as the customer app, under `/v1/astrologer/*`

This is a **dedicated app for astrologers only**. It is never the same binary as the customer app. Astrologers use it to:

- Receive and accept incoming consultation requests (chat + voice calls)
- Conduct live consultations (chat messages, Agora voice/video)
- Track their earnings and view payout history
- Manage their profile, availability (online/offline toggle), and specialties
- Complete onboarding and KYC submission
- Receive FCM push notifications for incoming calls, messages, and platform updates

**Architectural principle:** The astrologer persona is fully separated from the customer persona at every layer — separate tables, separate JWT audience (`astrobless.astrologer`), separate route namespace (`/v1/astrologer/*`), separate app binary. See root `CLAUDE.md` §5 for the full rationale.

---

## 2. Tech stack (locked)

| Layer | Choice | Why |
|---|---|---|
| Framework | **Flutter 3.x** (Dart 3) | Single codebase iOS + Android |
| State management | **Riverpod 2.x** (`flutter_riverpod`, `riverpod_annotation`) | Compile-safe, testable, no context threading |
| Routing | **go_router 14.x** | Declarative, deep-link ready, auth redirect built-in |
| Networking | **dio 5.x** + **retrofit 4.x** + **freezed** models | Type-safe API clients, interceptors, code-gen |
| Real-time | **socket_io_client 3.x** | Connect to backend Socket.IO for chat + billing ticks |
| Local storage | **hive_flutter** (cache) + **flutter_secure_storage** (tokens) | Fast local cache; tokens never in insecure storage |
| Push notifications | **firebase_messaging** + **flutter_local_notifications** | FCM for incoming calls + messages |
| Voice/video calls | **agora_rtc_engine 6.x** | Agora.io — single call provider |
| Image / file uploads | **image_picker** + **dio** multipart → pre-signed S3 URL | Profile photo, KYC doc uploads |
| Code generation | **build_runner** + **freezed** + **json_serializable** + **retrofit_generator** + **riverpod_generator** | All models and API clients are generated |
| Linting | **flutter_lints** + custom `analysis_options.yaml` | Enforce Dart style |
| Testing | **flutter_test** (unit + widget) + **integration_test** (E2E) | Mirrors backend coverage goals |
| UI | Custom design system, Material 3 (Material You), dark mode first-class | |
| Animations | **flutter_animate** (subtle, not overused) | |
| Date/time | **intl** package for formatting | |
| Connectivity | **connectivity_plus** | Online/offline banner |

**No third-party chat SDK** (no Sendbird, Stream). Chat is in-house via Socket.IO.

---

## 3. Non-negotiable rules

Read these before every coding session:

1. **Follow root `CLAUDE.md` exactly.** When in doubt, quote the section and ask.
2. **`camelCase` everywhere in Dart code.** `snake_case` for file names (Dart convention). See root CLAUDE.md §3.
3. **No token in insecure storage.** Access token and refresh token live in `flutter_secure_storage` only. Never `SharedPreferences`, never `Hive`, never in-memory between restarts.
4. **Money is `int` (paise) everywhere.** Never `double` for money. Convert to `₹` only at the display layer using `formatPaise()`.
5. **JWT audience is `astrobless.astrologer`.** Never send requests to `/v1/customer/*` or `/v1/admin/*` routes.
6. **All API calls go through the `ApiClient` singleton** (Dio instance). Never use `http` package or raw `HttpClient`.
7. **Riverpod only for state.** No `setState` in non-trivial widgets. No `Provider` (legacy). No `GetX`.
8. **Feature-first folder structure.** Every new feature lives in `lib/features/<featureName>/`. Do not dump code in `lib/` root.
9. **Generated files are not edited manually.** `*.freezed.dart`, `*.g.dart`, `*.gr.dart` — regenerate via `build_runner` instead.
10. **Every catch block that swallows errors** calls the telemetry error reporter, not just `debugPrint`.
11. **No hardcoded strings** for API base URL, Agora App ID, or FCM config — use environment config (`lib/core/config/appConfig.dart`).
12. **Ask when ambiguous.** Two reasonable interpretations → stop and ask.

---

## 4. Auth system

### 4.1 Supported methods

| Method | Supported | Notes |
|---|---|---|
| Phone OTP (SMS) | ✅ primary | 6-digit code, 5-min TTL, sent via MSG91 |
| Email + password | ✅ | With email OTP verification on first signup |
| Google OAuth | ❌ | Not for astrologers (KYC identity gap) |
| Apple Sign-In | ❌ | Not for astrologers |
| TOTP 2FA | Optional | Astrologers may enroll; not mandatory |

### 4.2 MSG91 OTP integration (backend does this — app just calls backend)

The backend uses **MSG91** for all OTP delivery. The app never calls MSG91 directly.

**How it works end-to-end:**
```
App                     Backend                     MSG91
 │                          │                          │
 │── POST send-otp ─────────►│                          │
 │   { phone: '+919876543210' }                         │
 │                          │── OTP API ───────────────►│
 │                          │   authKey, templateId,    │
 │                          │   mobile, otp (6-digit)   │
 │                          │◄── { type:'success' } ────│
 │                          │                           │
 │                          │  redis.set(                │
 │                          │   'otp:astrologer:phone:  │
 │                          │    +919876543210',        │
 │                          │   { otp, attempts:0 },    │
 │                          │   EX 300  // 5 min        │
 │                          │  )                        │
 │◄── { ok:true } ──────────│                           │
 │                           │                           │
 │  (user sees OTP in SMS)   │                           │
 │── POST verify-otp ───────►│                           │
 │   { phone, otp: '123456' }│                           │
 │                          │  redis.get → compare      │
 │                          │  max 3 attempts           │
 │◄── { accessToken, ... } ─│                           │
```

**Rate limits (enforced by backend, app should surface the errors gracefully):**
- 5 OTPs per hour per phone number
- 20 OTPs per hour per IP
- 3 wrong attempts → OTP invalidated; user must request a new one
- Lock after 10 wrong attempts in 1 hour → 15-min cooldown

**App-side behaviour:**
- Phone number must be formatted as `+91XXXXXXXXXX` (E.164). Prepend `+91` for Indian numbers; the backend stores in E.164 format.
- Show a 60-second resend countdown after sending. Disable "Resend" until countdown expires.
- On `RATE_LIMIT` error from backend → show: "Too many attempts. Try again in X minutes."
- On `OTP_INVALID` error → shake animation + "Incorrect code" text, clear input.
- On `OTP_EXPIRED` error → "Code expired. Request a new one." + auto-focus resend button.
- **Test mode** (dev/staging only): backend accepts `123456` as any OTP when `TEST_OTP=true` env is set. Never show this to users.

**MSG91 config on backend (`backend/.env`):**
```
MSG91_AUTH_KEY=<your_msg91_auth_key>
MSG91_SENDER_ID=ASTBLS
MSG91_OTP_TEMPLATE_ID=<approved_template_id_from_msg91_dashboard>
```

Templates must be pre-approved by DLT (India telecom regulation). The template looks like:
`Your Astrobless OTP is ##OTP##. Valid for 5 minutes. Do not share with anyone.`

### 4.3 Phone OTP flow (app screens)

```
Screen 1 — PhoneAuthScreen
  ┌─────────────────────────────┐
  │  Welcome to Astrobless     │
  │  Partner                   │
  │                            │
  │  [🇮🇳 +91] [__________]   │  ← Country code picker (default India)
  │                            │
  │  [Continue]                │
  └─────────────────────────────┘
  → Validate: non-empty, digits only, 10 digits for India
  → POST /v1/astrologer/auth/phone/send-otp { phone: '+91XXXXXXXXXX' }
  → Navigate to OtpScreen(phone: '+91XXXXXXXXXX')

Screen 2 — OtpScreen
  ┌─────────────────────────────┐
  │  Enter OTP                 │
  │  Sent to +91 98765 43210   │
  │                            │
  │  [_] [_] [_] [_] [_] [_]  │  ← 6 individual boxes, auto-advance
  │                            │
  │  Resend in 0:47            │  ← countdown, becomes tap when 0
  │                            │
  │  [Verify]                  │  ← auto-taps when 6th digit entered
  └─────────────────────────────┘
  → POST /v1/astrologer/auth/phone/verify-otp { phone, otp }
  → if isNewUser → /onboarding
  → else → /home
```

### 4.4 Email + password flow

```
Signup:
1. POST /v1/astrologer/auth/email/signup { email, password, displayName }
   → Backend sends email OTP (6-digit, 10-min TTL via MSG91 Email)
   → Navigate to email OTP verification screen

2. POST /v1/astrologer/auth/email/verify-otp { email, otp }
   → Backend returns { accessToken, refreshToken, astrologer }
   → Navigate to onboarding

Login:
1. POST /v1/astrologer/auth/email/login { email, password }
   → Returns { accessToken, refreshToken, astrologer }
   → If emailVerified=false → show re-verify screen

Password reset:
1. POST /v1/astrologer/auth/email/forgot-password { email }
   → Backend sends reset link via email (MSG91 Email or SES)
2. Deep-link opens reset screen
   → POST /v1/astrologer/auth/email/reset-password { token, newPassword }

Password rules (enforce client-side before submit):
- Min 8 characters
- At least one uppercase letter
- At least one digit
- Show strength indicator (weak / medium / strong)
```

### 4.3 Email + password flow

```
Signup:
1. POST /v1/astrologer/auth/email/signup { email, password, displayName }
   → Backend sends email OTP (6-digit, 10-min TTL)
   → Navigate to email OTP verification screen

2. POST /v1/astrologer/auth/email/verify-otp { email, otp }
   → Backend returns { accessToken, refreshToken, astrologer }
   → Navigate to onboarding

Login:
1. POST /v1/astrologer/auth/email/login { email, password }
   → Returns { accessToken, refreshToken, astrologer }
   → If emailVerified=false → show re-verify screen

Password reset:
1. POST /v1/astrologer/auth/email/forgot-password { email }
   → Backend sends reset link via email
2. Deep-link opens reset screen
   → POST /v1/astrologer/auth/email/reset-password { token, newPassword }
```

### 4.4 Token storage

```dart
// lib/core/auth/tokenStorage.dart
// Uses flutter_secure_storage
static const _accessKey  = 'astrologer_access_token';
static const _refreshKey = 'astrologer_refresh_token';
```

Both tokens stored with `IOSOptions(accessibility: KeychainAccessibility.first_unlock)` so they survive app restarts but are wiped on device wipe.

### 4.5 Token refresh (silent)

Dio interceptor in `lib/core/network/authInterceptor.dart`:

```
On 401 response:
1. Pause the queue (concurrent requests wait)
2. POST /v1/astrologer/auth/refresh { refreshToken }
3a. Success → store new tokens, retry original request, resume queue
3b. Failure (401/403) → clear tokens, pop to /auth/phone (sign-out)
```

### 4.6 JWT audience

Every request includes `Authorization: Bearer <accessToken>`. The backend middleware validates `jwt.aud === 'astrobless.astrologer'` and rejects anything else. This is enforced server-side; the app just sends the token.

### 4.7 Sign-out

```dart
// 1. DELETE /v1/astrologer/auth/logout { refreshToken } (best-effort, fire-and-forget)
// 2. Clear flutter_secure_storage tokens
// 3. Clear Hive caches
// 4. Disconnect Socket.IO
// 5. Unsubscribe FCM topic
// 6. Navigate to /auth/phone (replace stack)
```

---

## 5. Feature scope

### MVP (build first)

- [x] Phone OTP auth (MSG91 SMS) + email+password auth
- [ ] **Astrologer registration** — full self-serve signup via phone OTP or email+password
- [ ] Astrologer onboarding: profile setup, specialty selection, pricing setup
- [ ] KYC submission (Aadhaar/PAN upload via pre-signed S3 URL)
- [ ] Profile editor: photo, bio, languages, specialties, rates
- [ ] Online/offline toggle (real-time presence via Socket.IO)
- [ ] **Incoming chat consultation request** — accept/reject with 30s countdown
- [ ] **Live chat consultation** — real-time messaging via Socket.IO + per-minute billing ticker
- [ ] **Incoming voice call request** — full-screen ringing UI (like native call)
- [ ] **Live voice call** — Agora voice + per-minute billing ticker + mute/speaker controls
- [ ] **Incoming Kundli report request** — customer submits birth details, astrologer receives notification to prepare the report
- [ ] **Kundli report fulfilment** — astrologer generates/types the interpretation and submits via the app; customer receives the report
- [ ] Earnings dashboard: today, this week, all-time
- [ ] Consultation history (chat, voice, kundli)
- [ ] FCM push notifications: incoming call, incoming chat, incoming kundli request, earnings updates, KYC status
- [ ] Reviews & ratings view
- [ ] Support contact (mailto or in-app)

### v1.1

- [ ] Video call consultations (Agora)
- [ ] Live streaming (Agora Live)
- [ ] Puja service listings (astrologer offers pujas, admin approves)
- [ ] Bank account / UPI linkage for payouts
- [ ] Advanced analytics (hourly demand, peak hours chart)
- [ ] TOTP 2FA enrollment (optional for astrologers)

### v2

- [ ] Multi-language UI (Hindi, Tamil, Telugu, Bengali, Marathi)
- [ ] Astrologer blog / content publishing
- [ ] AstroMall seller mode
- [ ] Subscription / retainer packages

---

## 6. Project structure (feature-first)

```
partner_app/
├── lib/
│   ├── main.dart                        # Entry point — initialises Firebase, Riverpod, app
│   ├── app.dart                         # MaterialApp.router, theme, go_router instance
│   │
│   ├── core/                            # Shared infrastructure (no business logic)
│   │   ├── config/
│   │   │   └── app_config.dart          # Env-specific config (base URL, Agora ID, etc.)
│   │   ├── network/
│   │   │   ├── api_client.dart          # Dio singleton + interceptors
│   │   │   ├── auth_interceptor.dart    # Token inject + silent refresh
│   │   │   └── error_interceptor.dart  # DioException → AppException mapping
│   │   ├── auth/
│   │   │   ├── token_storage.dart       # flutter_secure_storage wrapper
│   │   │   └── auth_state.dart         # AuthState enum + Riverpod provider
│   │   ├── router/
│   │   │   └── app_router.dart          # go_router config + auth redirect guards
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # MaterialTheme light + dark
│   │   │   └── app_colors.dart          # Color constants
│   │   ├── utils/
│   │   │   ├── format_paise.dart        # formatPaise(int paise) → '₹500.00'
│   │   │   ├── format_date.dart         # intl-based date helpers
│   │   │   └── validators.dart          # Phone / email / password validators
│   │   ├── error/
│   │   │   ├── app_exception.dart       # AppException sealed class hierarchy
│   │   │   └── error_reporter.dart      # Telemetry / Sentry error reporter
│   │   └── widgets/                     # Truly generic widgets (LoadingOverlay, AppButton, etc.)
│   │
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   ├── auth_api.dart        # Retrofit API interface
│       │   │   └── auth_repository.dart
│       │   ├── domain/
│       │   │   └── auth_models.dart     # Freezed: LoginResult, AstrologerSummary
│       │   └── presentation/
│       │       ├── phone_auth_screen.dart
│       │       ├── otp_screen.dart
│       │       ├── email_auth_screen.dart
│       │       └── auth_controller.dart  # Riverpod AsyncNotifier
│       │
│       ├── onboarding/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── onboarding_screen.dart
│       │       ├── profile_setup_screen.dart
│       │       ├── specialty_screen.dart
│       │       ├── pricing_screen.dart
│       │       ├── kyc_screen.dart
│       │       └── onboarding_controller.dart
│       │
│       ├── home/
│       │   └── presentation/
│       │       └── home_screen.dart     # Bottom nav shell
│       │
│       ├── dashboard/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── dashboard_screen.dart   # Earnings summary, online toggle, recent activity
│       │       └── dashboard_controller.dart
│       │
│       ├── consultations/
│       │   ├── data/
│       │   │   ├── consultations_api.dart
│       │   │   └── consultations_repository.dart
│       │   ├── domain/
│       │   │   └── consultation_models.dart
│       │   └── presentation/
│       │       ├── incoming_request_sheet.dart  # Bottom sheet for accept/reject
│       │       ├── chat_consultation_screen.dart
│       │       ├── call_screen.dart             # Agora voice/video
│       │       ├── consultation_history_screen.dart
│       │       ├── consultation_detail_screen.dart
│       │       └── consultation_controller.dart
│       │
│       ├── earnings/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── earnings_screen.dart
│       │       └── payout_history_screen.dart
│       │
│       ├── profile/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       ├── profile_screen.dart
│       │       ├── edit_profile_screen.dart
│       │       ├── availability_screen.dart
│       │       └── profile_controller.dart
│       │
│       ├── notifications/
│       │   ├── data/
│       │   │   └── notifications_repository.dart
│       │   └── presentation/
│       │       └── notifications_screen.dart
│       │
│       └── settings/
│           └── presentation/
│               ├── settings_screen.dart
│               └── change_password_screen.dart
│
├── test/
│   ├── unit/                            # Pure Dart unit tests
│   └── widget/                          # Flutter widget tests
│
├── integration_test/                    # E2E tests
├── android/
├── ios/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 7. Routing (go_router)

```dart
// lib/core/router/app_router.dart

final appRouter = GoRouter(
  initialLocation: '/auth/phone',
  redirect: (context, state) {
    final isAuth = ref.read(authStateProvider) == AuthState.authenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isAuth && !isAuthRoute) return '/auth/phone';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/auth/phone',          builder: (_, __) => const PhoneAuthScreen()),
    GoRoute(path: '/auth/otp',            builder: (_, s) => OtpScreen(phone: s.extra as String)),
    GoRoute(path: '/auth/email',          builder: (_, __) => const EmailAuthScreen()),
    GoRoute(path: '/auth/email/verify',   builder: (_, s) => EmailOtpScreen(email: s.extra as String)),
    GoRoute(path: '/auth/forgot-password',builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/onboarding',          builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (_, __, child) => HomeScreen(child: child),
      routes: [
        GoRoute(path: '/home',            builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/consultations',   builder: (_, __) => const ConsultationHistoryScreen()),
        GoRoute(path: '/earnings',        builder: (_, __) => const EarningsScreen()),
        GoRoute(path: '/profile',         builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/consultation/chat/:id', builder: (_, s) => ChatConsultationScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/consultation/call/:id', builder: (_, s) => CallScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/consultation/:id',      builder: (_, s) => ConsultationDetailScreen(id: s.pathParameters['id']!)),
    GoRoute(path: '/notifications',       builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/settings',            builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/profile/edit',        builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: '/onboarding/kyc',      builder: (_, __) => const KycScreen()),
  ],
);
```

---

## 8. Network layer

### 8.1 Dio client setup

```dart
// lib/core/network/api_client.dart

Dio createDio(Ref ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,  // 'http://localhost:3000/v1/astrologer'
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'X-App-Version': AppConfig.version,
      'X-Platform': Platform.isIOS ? 'ios' : 'android',
    },
  ));
  dio.interceptors.addAll([
    AuthInterceptor(ref),       // Inject Bearer token + silent refresh
    ErrorInterceptor(),         // Map DioException → AppException
    LogInterceptor(requestBody: kDebugMode, responseBody: kDebugMode),
  ]);
  return dio;
}
```

### 8.2 Response envelope

The backend always returns:
```json
{ "ok": true, "data": {...}, "traceId": "..." }
{ "ok": false, "error": { "code": "...", "message": "..." }, "traceId": "..." }
```

The `ErrorInterceptor` unwraps this: successful responses pass through `data`; error responses throw `AppException` with `code` + `message`.

### 8.3 AppException hierarchy

```dart
// lib/core/error/app_exception.dart
sealed class AppException implements Exception {
  final String code;
  final String message;
}

class UnauthorizedException extends AppException { ... }   // 401
class ForbiddenException extends AppException { ... }      // 403
class NotFoundException extends AppException { ... }       // 404
class ValidationException extends AppException { ... }     // 400
class RateLimitException extends AppException { ... }      // 429
class ServerException extends AppException { ... }         // 5xx
class NetworkException extends AppException { ... }        // no connectivity
```

### 8.4 Retrofit API interfaces

```dart
// lib/features/auth/data/auth_api.dart
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/phone/send-otp')
  Future<SendOtpResponse> sendPhoneOtp(@Body() SendOtpRequest body);

  @POST('/phone/verify-otp')
  Future<LoginResult> verifyPhoneOtp(@Body() VerifyOtpRequest body);

  @POST('/email/signup')
  Future<void> emailSignup(@Body() EmailSignupRequest body);

  @POST('/email/verify-otp')
  Future<LoginResult> verifyEmailOtp(@Body() VerifyEmailOtpRequest body);

  @POST('/email/login')
  Future<LoginResult> emailLogin(@Body() EmailLoginRequest body);

  @POST('/email/forgot-password')
  Future<void> forgotPassword(@Body() ForgotPasswordRequest body);

  @POST('/email/reset-password')
  Future<void> resetPassword(@Body() ResetPasswordRequest body);

  @POST('/refresh')
  Future<LoginResult> refresh(@Body() RefreshRequest body);

  @DELETE('/logout')
  Future<void> logout(@Body() LogoutRequest body);
}
```

---

## 9. State management (Riverpod)

### 9.1 Conventions

- **`@riverpod` annotation** for code-gen. Run `build_runner` after any provider changes.
- Controllers are `AsyncNotifier<T>` or `Notifier<T>` — never `ChangeNotifier`.
- Repositories are `Provider` singletons (no state, just methods).
- One controller per screen (or shared across a closely related screen group).
- Never call Riverpod's `ref.read()` inside `build()` — use `ref.watch()`.
- Use `AsyncValue` for all async state: handle `loading`, `error`, `data` in every widget.

### 9.2 Auth state

```dart
// lib/core/auth/auth_state.dart

enum AuthState { unknown, unauthenticated, authenticated }

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => AuthState.unknown;

  Future<void> init() async { /* check secure storage for tokens */ }
  Future<void> setTokens(String access, String refresh) async { ... }
  Future<void> signOut() async { ... }
}
```

### 9.3 Example feature controller

```dart
// lib/features/dashboard/presentation/dashboard_controller.dart

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<DashboardData> build() => _load();

  Future<DashboardData> _load() async {
    final repo = ref.read(dashboardRepositoryProvider);
    return repo.getDashboardOverview();
  }

  Future<void> setOnline(bool online) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(presenceRepositoryProvider).setPresence(online);
      return _load();
    });
  }
}
```

---

## 10. Real-time (Socket.IO)

### 10.1 Connection

```dart
// lib/core/realtime/socket_service.dart

class SocketService {
  late final IO.Socket _socket;

  void connect(String accessToken) {
    _socket = IO.io(AppConfig.wsBaseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setNamespace('/consultation')
      .setAuth({'token': accessToken})
      .enableAutoConnect()
      .setReconnectionAttempts(10)
      .build());

    _socket.onConnect((_) => debugPrint('Socket connected'));
    _socket.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket.onConnectError((e) => ErrorReporter.report(e));
  }

  void disconnect() => _socket.disconnect();
  void emit(String event, dynamic data) => _socket.emit(event, data);
  void on(String event, Function(dynamic) handler) => _socket.on(event, handler);
}
```

### 10.2 Events the astrologer app handles

**Receives (server → client):**

| Event | Payload | Action |
|---|---|---|
| `consultation:requested` | `{ consultationId, customerId, type, customerName, pricePerMinPaise }` | Show `IncomingRequestSheet` (30s countdown) |
| `message:new` | `{ message }` | Append to chat list |
| `message:ack` | `{ clientMsgId, serverId, createdAt }` | Update local message status |
| `message:read` | `{ consultationId, upToMessageId }` | Show double-tick |
| `typing:update` | `{ consultationId, senderType, isTyping }` | Show/hide typing indicator |
| `billing:tick` | `{ consultationId, remainingSeconds, balancePaise }` | Update billing ticker UI |
| `billing:lowBalance` | `{ consultationId, secondsLeft }` | Show warning banner |
| `consultation:ended` | `{ consultationId, reason, summary }` | Navigate to post-call summary |
| `presence:ack` | `{ isOnline }` | Confirm online toggle |
| `call:incoming` | `{ consultationId, agoraToken, channelName }` | Start Agora call |
| `call:ended` | `{ consultationId, reason }` | End Agora call |

**Sends (client → server):**

| Event | Payload | When |
|---|---|---|
| `consultation:accept` | `{ consultationId }` | Astrologer taps Accept |
| `consultation:reject` | `{ consultationId, reason }` | Astrologer taps Reject |
| `message:send` | `{ consultationId, type, body, mediaUrl?, clientMsgId }` | User sends chat message |
| `message:read` | `{ consultationId, upToMessageId }` | Screen becomes visible |
| `typing:start` | `{ consultationId }` | Text field focused + typing |
| `typing:stop` | `{ consultationId }` | Text field blur or 3s idle |
| `call:signal` | `{ consultationId, payload }` | Agora signalling |

All events carry a `traceId` field for debugging.

---

## 11. Push notifications (FCM)

### 11.1 Setup

```dart
// lib/main.dart — before runApp
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

### 11.2 Token registration

On every login, register the FCM token:

```dart
final token = await FirebaseMessaging.instance.getToken();
await notificationsApi.registerFcmToken(FcmTokenRequest(
  token: token!,
  platform: Platform.isIOS ? 'ios' : 'android',
));
```

Listen for token refresh: `FirebaseMessaging.instance.onTokenRefresh`.

### 11.3 Notification types and actions

| `type` in data payload | Action |
|---|---|
| `consultationRequest` | Show full-screen incoming request UI (like a phone call) |
| `chatMessage` | Show in-app notification if app in foreground; OS notification if background |
| `earningsUpdate` | Show toast / update earnings badge |
| `kycStatusUpdate` | Navigate to KYC status screen |
| `payoutProcessed` | Show earnings screen with toast |
| `platformAnnouncement` | Navigate to notifications list |

### 11.4 Foreground handling

```dart
FirebaseMessaging.onMessage.listen((message) {
  // App is in foreground: show flutter_local_notifications banner
  // Also dispatch to the relevant Riverpod provider to update in-memory state
});
```

### 11.5 Background / terminated handling

`firebaseMessagingBackgroundHandler` is a top-level function that stores the notification in Hive for display when the app opens.

On app launch, check `FirebaseMessaging.instance.getInitialMessage()` for a tap-to-open notification.

---

## 12. Agora voice/video calls

### 12.1 Flow

```
1. FCM push 'call:incoming' wakes the app (even if killed)
   → Show full-screen IncomingCallScreen with accept/reject

2. Astrologer taps Accept
   → POST /v1/astrologer/consultations/:id/accept
   → Backend returns { agoraToken, channelName }
   → Join Agora channel with provided token

3. Both parties in call
   → Billing ticker runs server-side
   → Socket emits 'billing:tick' every 60s

4. Either party ends
   → POST /v1/astrologer/consultations/:id/end { reason }
   → Leave Agora channel, navigate to summary screen

5. Agora webhook (channel closed) as safety net in backend
```

### 12.2 Agora token rules

- Tokens are short-lived: `durationSeconds = (remainingMinutes × 60) + 60`
- If the server emits `call:tokenRefresh { newToken }`, call `rtcEngine.renewToken(newToken)` immediately
- Never hardcode the Agora App Certificate — it lives on the server only
- The app only receives the short-lived channel token

### 12.3 Permissions

Request microphone (voice) and camera (video) permissions before joining any call using `permission_handler`.

```dart
// Request before call join
final statuses = await [Permission.microphone, Permission.camera].request();
if (statuses[Permission.microphone] != PermissionStatus.granted) {
  // Show dialog: microphone required
  return;
}
```

### 12.4 Agora engine lifecycle

```dart
// lib/features/consultations/presentation/call_screen.dart
// — init in initState, dispose in dispose
await AgoraRtcEngine.create(AppConfig.agoraAppId);
await engine.enableVideo(); // or just audio for voice
await engine.joinChannel(token: agoraToken, channelId: channelName, uid: 0, options: ...);
// on leave:
await engine.leaveChannel();
await engine.release();
```

---

## 13. Kundli report requests

Kundli reports are an **asynchronous consultation type** — the customer submits birth details and the astrologer prepares a written interpretation within a defined timeframe (e.g. 24 hours).

### 13.1 Flow overview

```
Customer app                  Backend                    Partner app
     │                           │                           │
     │── POST /customer/          │                           │
     │   kundli-requests {        │                           │
     │   astrologerId,            │                           │
     │   birthDate, birthTime,    │                           │
     │   birthPlace, birthLat,    │                           │
     │   birthLng, question? }    │                           │
     │                           │── Store in DB:             │
     │                           │   status='pending'        │
     │                           │── FCM push ───────────────►│
     │                           │   type: 'kundliRequest'   │
     │                           │── Socket emit ────────────►│
     │                           │   'kundli:request' event  │
     │                           │                           │
     │                           │              Astrologer sees │
     │                           │              incoming request │
     │                           │              notification     │
     │                           │                           │
     │                           │◄── POST /astrologer/      │
     │                           │    kundli-requests/:id/   │
     │                           │    accept                 │
     │                           │   status='inProgress'     │
     │                           │                           │
     │                           │◄── POST /astrologer/      │
     │                           │    kundli-requests/:id/   │
     │                           │    submit {               │
     │                           │     reportText,           │
     │                           │     pdfS3Key?             │
     │                           │    }                      │
     │                           │   status='completed'      │
     │                           │── FCM push ───────────────►│ (customer)
     │◄── notification ──────────│                           │
```

### 13.2 App screens for kundli requests

**Incoming request notification:**
- High-priority FCM push (`type: 'kundliRequest'`)
- Tapping opens `KundliRequestDetailScreen`

**KundliRequestDetailScreen:**
- Shows: customer's name, birth date, time, place (lat/lng + reverse geocoded name), their question (if any)
- Buttons: Accept (with 6h / 12h / 24h SLA selector) | Decline (with reason)
- Shows mini kundli chart preview (basic planetary positions computed from birth data)

**KundliRequestListScreen (tab in home):**
- Pending requests (oldest first)
- In-progress requests (deadline countdown)
- Completed requests (last 30 days)

**KundliReportComposerScreen:**
- Rich text input for the interpretation (markdown-enabled)
- Optional PDF upload (if astrologer prefers to generate externally)
- Preview before submit
- Submit → backend stores, notifies customer

### 13.3 DB tables involved (backend reference)

```sql
create table "kundliRequests" (
  "id"               uuid primary key default gen_random_uuid(),
  "customerId"       uuid not null references "customers"("id"),
  "astrologerId"     uuid not null references "astrologers"("id"),
  "status"           text not null default 'pending',  -- pending|accepted|inProgress|completed|declined|expired
  "birthDate"        date not null,
  "birthTime"        time,
  "birthPlace"       text not null,
  "birthLat"         numeric(9,6),
  "birthLng"         numeric(9,6),
  "question"         text,
  "priceAtOrderPaise" bigint not null,
  "commissionPct"    numeric(5,2) not null,
  "slaDueAt"         timestamptz,       -- set when accepted
  "reportText"       text,
  "reportPdfUrl"     text,
  "declineReason"    text,
  "astrologerNotes"  text,             -- private notes visible only to astrologer
  "traceId"          text,
  "createdAt"        timestamptz not null default now(),
  "updatedAt"        timestamptz not null default now()
);
```

### 13.4 Backend endpoints (astrologer side)

```
GET  /v1/astrologer/kundli-requests          ?status&page&limit
GET  /v1/astrologer/kundli-requests/:id
POST /v1/astrologer/kundli-requests/:id/accept  { slaDurationHours: 6|12|24 }
POST /v1/astrologer/kundli-requests/:id/decline { reason }
POST /v1/astrologer/kundli-requests/:id/submit  { reportText, reportPdfS3Key? }
GET  /v1/astrologer/kundli-requests/:id/chart   → { planets, houses, aspects } (computed from birth data)
```

### 13.5 Socket.IO event for kundli

| Event | Direction | Payload |
|---|---|---|
| `kundli:request` | server → astrologer | `{ requestId, customerId, customerName, birthDate, birthTime, birthPlace, priceAtOrderPaise }` |
| `kundli:accepted` | server → customer | `{ requestId, slaDueAt }` |
| `kundli:completed` | server → customer | `{ requestId, reportPreview }` |

---

## 15. KYC & onboarding

### 13.1 Steps (ordered)

1. **Basic profile** — displayName, bio, gender, DOB
2. **Specialties** — multi-select from predefined list (Vedic, Tarot, Numerology, Vastu, etc.)
3. **Languages** — multi-select
4. **Pricing** — pricePerMinChatPaise, pricePerMinCallPaise (int, min configurable via backend settings)
5. **KYC documents** — upload Aadhaar front/back + PAN (or passport for non-Indian) via S3 pre-signed URL
6. **Bank account / UPI** — for payouts; stored server-side encrypted

All steps are:
- Saved incrementally (PATCH profile as user progresses)
- Resumable (go_router guards skip completed steps on re-open)
- Tracked server-side via `astrologers.kycStatus`: `pending → submitted → approved | rejected`

### 13.2 KYC document upload

```dart
// 1. Pick image from gallery / camera
final file = await ImagePicker().pickImage(source: ImageSource.gallery);

// 2. Get pre-signed S3 URL from backend
final presigned = await kycApi.getUploadUrl(KycUploadUrlRequest(
  docType: 'aadhaarFront',
  mimeType: 'image/jpeg',
));

// 3. Upload directly to S3 (bypass backend, no token needed)
await Dio().put(presigned.uploadUrl, data: file.readAsBytesSync(),
  options: Options(headers: {'Content-Type': 'image/jpeg'}));

// 4. Confirm upload to backend
await kycApi.confirmUpload(KycConfirmRequest(docType: 'aadhaarFront', s3Key: presigned.s3Key));
```

---

## 16. Earnings & payouts

- `GET /v1/astrologer/earnings` — list of `astrologerEarnings` rows
- `GET /v1/astrologer/earnings/summary` — today / this week / all-time totals
- `GET /v1/astrologer/payouts` — payout history
- Payouts are initiated by admin (weekly batch). Astrologers view status only.
- Money displayed: always format via `formatPaise(int paise)` → `₹500.00`

---

## 17. Presence (online/offline)

The astrologer's availability is surfaced to customers browsing the platform.

```dart
// Toggle via PATCH /v1/astrologer/profile/presence { isOnline: true|false }
// Also emitted via Socket.IO 'presence:set' { isOnline } for real-time propagation
// The server broadcasts 'presence:update' to customer sockets watching this astrologer
```

The online toggle is prominently on the dashboard (large switch / FAB-style toggle). When the app is killed or socket disconnects for > 60s, the backend auto-sets `isOnline=false`.

---

## 18. UI design language

### 16.1 Visual style

- **Theme:** Warm, trustworthy, celestial. Dark navy + gold accents. Professional yet spiritual.
- **Not loud:** Avoid rainbow gradients. Use depth via shadows and subtle gradients.
- **Dark mode first:** Default to dark. Light mode supported via ThemeMode.system.

### 16.2 Color palette

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary — deep indigo
  static const primary = Color(0xFF5C6BC0);
  static const primaryDark = Color(0xFF3949AB);

  // Accent — warm gold
  static const accent = Color(0xFFFFB300);
  static const accentLight = Color(0xFFFFE082);

  // Backgrounds (dark mode)
  static const bgDark = Color(0xFF0D0B1E);
  static const surfaceDark = Color(0xFF1A1740);
  static const cardDark = Color(0xFF231F54);

  // Backgrounds (light mode)
  static const bgLight = Color(0xFFF5F5FF);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Status
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Text
  static const textPrimary = Color(0xFFECEFF1);
  static const textSecondary = Color(0xFFB0BEC5);
  static const textDisabled = Color(0xFF546E7A);
}
```

### 16.3 Typography

- **Font:** Inter (via `google_fonts` or bundled)
- Headings: `fontWeight: FontWeight.w700`
- Body: `fontWeight: FontWeight.w400`, size `14–16sp`
- Captions: size `12sp`, `textSecondary`
- Monetary amounts: `fontWeight: FontWeight.w600`, `accent` color

### 16.4 Component patterns

**Loading states:**
- Full-screen initial loads: shimmer skeleton (same layout as loaded state)
- Mutations (button tap): disable button + show `CircularProgressIndicator` inside it
- Pagination: append spinner at list bottom

**Error states:**
- Inline: red text below the field (forms)
- Full-screen: centered error widget + retry button
- Toast: `ScaffoldMessenger.showSnackBar()` or a lightweight overlay

**Empty states:**
- Centered SVG illustration + title + subtitle
- CTA if relevant ("Start your first consultation")

**Bottom sheets** for incoming requests, confirmation dialogs, minor forms.

**Optimistic UI** for message sends and presence toggle (revert on error with toast).

---

## 19. Backend endpoints reference (astrologer app uses)

All under `AppConfig.apiBaseUrl` = `https://api.astrobless.app/v1/astrologer` (or `http://localhost:3000/v1/astrologer` locally).

```
# Auth (no token required)
POST /auth/phone/send-otp           { phone }
POST /auth/phone/verify-otp         { phone, otp } → { accessToken, refreshToken, astrologer }
POST /auth/email/signup             { email, password, displayName }
POST /auth/email/verify-otp         { email, otp } → { accessToken, refreshToken, astrologer }
POST /auth/email/login              { email, password } → { accessToken, refreshToken, astrologer }
POST /auth/email/forgot-password    { email }
POST /auth/email/reset-password     { token, newPassword }
POST /auth/refresh                  { refreshToken } → { accessToken, refreshToken }
DELETE /auth/logout                 { refreshToken }

# Profile (token required)
GET  /profile                       → { astrologer }
PATCH /profile                      { displayName?, bio?, languages?, specialties?, profileImageUrl? }
PATCH /profile/presence             { isOnline }
PATCH /profile/pricing              { pricePerMinChatPaise, pricePerMinCallPaise }

# KYC
GET  /kyc/upload-url                ?docType=aadhaarFront → { uploadUrl, s3Key }
POST /kyc/confirm                   { docType, s3Key }
GET  /kyc/status                    → { kycStatus, rejectionReason? }

# Consultations
GET  /consultations                 ?status&type&from&to&page&limit
GET  /consultations/:id
POST /consultations/:id/accept
POST /consultations/:id/reject      { reason }
POST /consultations/:id/end         { reason }
GET  /consultations/:id/messages    ?afterId&limit

# Earnings
GET  /earnings                      ?from&to&page&limit
GET  /earnings/summary              → { todayPaise, weekPaise, allTimePaise }

# Payouts
GET  /payouts                       ?status&from&to&page&limit

# Notifications
GET  /notifications                 ?page&limit
POST /notifications/fcm-token       { token, platform }
DELETE /notifications/fcm-token     { token }
PATCH /notifications/:id/read
POST /notifications/read-all

# Kundli requests
GET  /kundli-requests               ?status&page&limit
GET  /kundli-requests/:id
POST /kundli-requests/:id/accept    { slaDurationHours: 6|12|24 }
POST /kundli-requests/:id/decline   { reason }
POST /kundli-requests/:id/submit    { reportText, reportPdfS3Key? }
GET  /kundli-requests/:id/chart     → { planets, houses, aspects }
GET  /kundli-requests/upload-url    ?docType=kundliReport → { uploadUrl, s3Key }
```

---

## 20. Code conventions (Dart / Flutter)

1. **File names:** `snake_case.dart` — always.
2. **Class names:** `PascalCase` — always.
3. **Variable / method names:** `camelCase` — always.
4. **Constants:** `lowerCamelCase` for local, `UPPER_SNAKE` only for true compile-time constants.
5. **Widgets:** `const` constructor wherever possible. Build methods < 50 lines — extract sub-widgets.
6. **Freezed models:** use `@freezed` for all API response/request models and domain models. Never mutable domain objects.
7. **No `print()` in production paths** — use `debugPrint()` in debug mode or `ErrorReporter.log()` for structured logs.
8. **No `BuildContext` in repositories or controllers** — only in widgets/screens.
9. **Separate concerns:** `data/` = raw API/local calls; `domain/` = models + interfaces; `presentation/` = widgets + controllers.
10. **Test file co-location:** `foo.dart` → `foo_test.dart` in the `test/` mirror directory.
11. **`async`/`await` everywhere** — no raw `.then()` chains except in streams.
12. **Dispose resources:** cancel subscriptions, dispose controllers, leave Agora channel in `dispose()`.
13. **`analysis_options.yaml`:** strict lints enabled. Zero lint warnings in CI.

---

## 21. Testing

| Layer | Tool | Target |
|---|---|---|
| Unit (repository, controller) | `flutter_test` + `mocktail` | 70% coverage on business logic |
| Widget | `flutter_test` | Critical screens: auth, chat, call |
| Golden | `golden_toolkit` | IncomingRequestSheet, ChatBubble |
| Integration (E2E) | `integration_test` | Auth flow, incoming call accept, chat send |

**Test naming:** `group('FeatureName', () { test('does X when Y', ...) })`.

**Mocking:** use `mocktail` for Dio, repositories, and Riverpod overrides in widget tests.

---

## 22. Environment config

```dart
// lib/core/config/app_config.dart

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL', defaultValue: 'http://localhost:3000/v1/astrologer',
  );
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL', defaultValue: 'ws://localhost:3000',
  );
  static const agoraAppId = String.fromEnvironment('AGORA_APP_ID');
  static const sentryDsn   = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const version     = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static const isDev       = bool.fromEnvironment('IS_DEV', defaultValue: true);
}
```

Pass via `--dart-define` in `flutter run` / CI:
```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1/astrologer \
  --dart-define=WS_BASE_URL=ws://10.0.2.2:3000 \
  --dart-define=AGORA_APP_ID=your_agora_id \
  --dart-define=IS_DEV=true
```

Use `10.0.2.2` on Android emulator (maps to host machine), `localhost` on iOS simulator.

---

## 23. Build & run

```bash
# Install deps
flutter pub get

# Code generation (run after any model/provider changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Run on device
flutter run --dart-define=API_BASE_URL=http://localhost:3000/v1/astrologer \
             --dart-define=WS_BASE_URL=ws://localhost:3000

# Tests
flutter test
flutter test integration_test/  # requires connected device/emulator

# Lint
flutter analyze

# Build release APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.astrobless.app/v1/astrologer ...
```

---

## 24. Build order (recommended for a new feature)

When starting a new feature, follow this order — each step is independently testable:

1. **API contract** — check the backend endpoint exists; if not, coordinate with backend team first
2. **Domain models** — add `@freezed` models in `features/<name>/domain/`
3. **API interface** — add Retrofit methods in `features/<name>/data/<name>_api.dart`; regenerate
4. **Repository** — thin wrapper around API; handles error mapping
5. **Riverpod provider** — controller with loading/error/data states
6. **Unit tests** — controller + repository tests with mocks
7. **Widget/screen** — consume the provider; handle all three AsyncValue states
8. **Widget tests** — at minimum: loading state, success state, error state
9. **Integration test** — golden path if the feature is user-facing

---

## 25. When starting a new feature (for Claude Code)

Before writing any code:

1. **Read root CLAUDE.md §5, §6, §9, §13** (persona boundaries, auth, chat, calls).
2. **Read the relevant backend endpoint** in the admin panel or backend CLAUDE.md to understand the request/response shape.
3. **State the plan** — feature goals, API endpoints used, new models needed, screens, edge cases.
4. **Wait for approval** before writing code.

When writing code:
- Match the style of the nearest existing feature in this codebase.
- Prefer extending existing models over creating new ones.
- If you need a backend endpoint that doesn't exist yet, flag it explicitly.

---

## 26. Open questions / pending decisions

- [ ] Which astrologer onboarding steps are mandatory for MVP vs. can be skipped?
- [ ] Incoming call UI: full-screen overlay (like native call) or in-app bottom sheet?
- [ ] Should the app support background call (PIP mode) on Android?
- [ ] Call recording: off by default; needs both-party consent UI — design needed
- [ ] Bank account / UPI: collect in onboarding or allow post-onboarding?
- [ ] Minimum pricing floor: configured in backend `settings` table — which admin role controls it?
- [ ] Deep links: which scheme? `astroblesspartner://` (custom) or `https://partner.astrobless.app/` (Universal Links)?

---

## 27. Glossary

See root `CLAUDE.md` §25 for full glossary. Partner-app-specific terms:

- **Partner** — product-facing term for astrologer (the app is "Astrobless Partner")
- **Consultation request** — a customer's intent to talk; astrologer has 30s to accept/reject
- **Billing tick** — server-side event every 60s that debits the customer's wallet
- **Earnings** — astrologer's net cut after platform commission (default 70% of gross)
- **KYC** — Know Your Customer; government ID + photo verification required before going live
- **Presence** — online/offline status; broadcast to customers via Socket.IO

---

_Last updated: 2026-04-21. Keep this file alive — update it when decisions are made._
