import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../auth/token_storage.dart';
import '../error/app_exception.dart';
import 'endpoints.dart';

/// Riverpod provider for the singleton [ApiClient].
///
/// The underlying [Dio] instance is configured with [_AuthInterceptor] for
/// transparent token refresh and [_ErrorInterceptor] for typed error mapping.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(_buildDio());
});

/// Internal factory — creates and configures the [Dio] instance.
///
/// Not exported; consumers should use [apiClientProvider].
Dio _buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-App-Version': AppConfig.version,
        'X-Platform': defaultTargetPlatform.name.toLowerCase(),
      },
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(dio),
    if (kDebugMode)
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    _ErrorInterceptor(),
  ]);

  return dio;
}

/// Central HTTP gateway for all Astrologer (Partner) API interactions.
///
/// Wraps [Dio] with typed convenience methods. All path strings come from
/// [Endpoints] — never hard-code paths in feature repositories.
///
/// Obtain an instance via `ref.read(apiClientProvider)`.
class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  /// The underlying [Dio] instance.
  ///
  /// Exposed for [dioProvider] compatibility. Prefer [apiClientProvider] in
  /// feature repositories over accessing this directly.
  Dio get rawDio => _dio;

  // ─── Core HTTP helpers ────────────────────────────────────────────────────

  /// Authenticated `GET` request. Throws [AppException] on HTTP error.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get<dynamic>(path, queryParameters: queryParameters);

  /// Authenticated `POST` request.
  Future<Response<dynamic>> post(String path, {dynamic data}) =>
      _dio.post<dynamic>(path, data: data);

  /// Authenticated `PATCH` request.
  Future<Response<dynamic>> patch(String path, {dynamic data}) =>
      _dio.patch<dynamic>(path, data: data);

  /// Authenticated `DELETE` request.
  Future<Response<dynamic>> delete(String path, {dynamic data}) =>
      _dio.delete<dynamic>(path, data: data);

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Sends a phone OTP (MSG91 SMS). Rate-limited 5/hr per phone.
  Future<void> sendPhoneOtp(String phone) async {
    await post(Endpoints.auth.sendPhoneOtp, data: {'phone': phone});
  }

  /// Verifies the phone OTP and returns a raw data map with tokens.
  Future<Map<String, dynamic>> verifyPhoneOtp(String phone, String otp) async {
    final res = await post(
      Endpoints.auth.verifyPhoneOtp,
      data: {'phone': phone, 'otp': otp},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Begins email sign-up; the backend sends an email OTP.
  Future<void> emailSignup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await post(Endpoints.auth.emailSignup, data: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
  }

  /// Resends the email verification OTP (rate-limited: 3/hr/email).
  Future<void> resendEmailOtp(String email) async {
    await post(Endpoints.auth.resendEmailOtp, data: {'email': email});
  }

  /// Verifies the email OTP and returns a raw data map with tokens.
  Future<Map<String, dynamic>> verifyEmailOtp(
      String email, String otp) async {
    final res = await post(
      Endpoints.auth.verifyEmailOtp,
      data: {'email': email, 'otp': otp},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Authenticates with email + password.
  Future<Map<String, dynamic>> emailLogin(
      String email, String password) async {
    final res = await post(
      Endpoints.auth.emailLogin,
      data: {'email': email, 'password': password},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Sends a password reset link to [email].
  Future<void> forgotPassword(String email) async {
    await post(Endpoints.auth.forgotPassword, data: {'email': email});
  }

  /// Revokes the current session (best-effort; errors are swallowed).
  Future<void> logout(String refreshToken) async {
    try {
      await delete(Endpoints.auth.logout, data: {'refreshToken': refreshToken});
    } catch (_) {}
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  /// Fetches the authenticated astrologer's full profile.
  Future<Map<String, dynamic>> fetchProfile() async {
    final res = await get(Endpoints.profile.me);
    return (res.data['data'] as Map<String, dynamic>)['astrologer']
        as Map<String, dynamic>;
  }

  /// Updates profile fields. Only provided fields are changed.
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? bio,
    List<String>? languages,
    List<String>? specialties,
    String? profileImageUrl,
    int? experienceYears,
  }) async {
    final res = await patch(Endpoints.profile.update, data: {
      if (displayName != null) 'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (languages != null) 'languages': languages,
      if (specialties != null) 'specialties': specialties,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (experienceYears != null) 'experienceYears': experienceYears,
    });
    return (res.data['data'] as Map<String, dynamic>)['astrologer']
        as Map<String, dynamic>;
  }

  /// Toggles the astrologer's online/offline status.
  Future<void> setPresence(bool isOnline) async {
    await patch(Endpoints.profile.presence, data: {'isOnline': isOnline});
  }

  /// Updates per-minute chat and call pricing.
  Future<void> updatePricing({
    required int pricePerMinChat,
    required int pricePerMinCall,
  }) async {
    await patch(Endpoints.profile.pricing, data: {
      'pricePerMinChat': pricePerMinChat,
      'pricePerMinCall': pricePerMinCall,
    });
  }

  // ─── Consultations ─────────────────────────────────────────────────────────

  /// Fetches consultations with an optional [status] filter.
  Future<Map<String, dynamic>> fetchConsultations({
    String? status,
    int limit = 50,
  }) async {
    final res = await get(Endpoints.consultations.list, queryParameters: {
      if (status != null) 'status': status,
      'limit': limit,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches a single consultation by [id].
  Future<Map<String, dynamic>> fetchConsultation(String id) async {
    final res = await get(Endpoints.consultations.detail(id));
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches chat messages for consultation [id], optionally after [afterId].
  Future<Map<String, dynamic>> fetchMessages(
      String id, {String? afterId, int limit = 50}) async {
    final res = await get(
      Endpoints.consultations.messages(id),
      queryParameters: {
        if (afterId != null) 'afterId': afterId,
        'limit': limit,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Accepts an incoming consultation request.
  Future<void> acceptConsultation(String id) async {
    await post(Endpoints.consultations.accept(id));
  }

  /// Rejects an incoming consultation request with an optional [reason].
  Future<void> rejectConsultation(String id,
      {String reason = 'busy'}) async {
    await post(Endpoints.consultations.reject(id), data: {'reason': reason});
  }

  /// Ends an active consultation.
  Future<void> endConsultation(String id,
      {String reason = 'astrologerEnded'}) async {
    await post(Endpoints.consultations.end(id), data: {'reason': reason});
  }

  // ─── Earnings ──────────────────────────────────────────────────────────────

  /// Fetches the earnings summary (today, week, all-time).
  Future<Map<String, dynamic>> fetchEarningsSummary() async {
    final res = await get(Endpoints.earnings.summary);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches a paginated list of earning transactions.
  Future<Map<String, dynamic>> fetchEarnings({
    int page = 1,
    int limit = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await get(Endpoints.earnings.list, queryParameters: {
      'page': page,
      'limit': limit,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Fetches payout history.
  Future<Map<String, dynamic>> fetchPayouts() async {
    final res = await get(Endpoints.earnings.payouts);
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─── Kundli Requests ───────────────────────────────────────────────────────

  /// Fetches kundli requests with an optional [status] filter.
  Future<List<dynamic>> fetchKundliRequests({String? status, int limit = 50}) async {
    final res = await get(Endpoints.kundli.list, queryParameters: {
      if (status != null) 'status': status,
      'limit': limit,
    });
    return res.data['data'] as List<dynamic>;
  }

  /// Fetches a single kundli request by [id].
  Future<Map<String, dynamic>> fetchKundliRequest(String id) async {
    final res = await get(Endpoints.kundli.detail(id));
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Accepts a kundli request with the given SLA duration.
  Future<void> acceptKundliRequest(String id, int slaDurationHours) async {
    await post(Endpoints.kundli.accept(id),
        data: {'slaDurationHours': slaDurationHours});
  }

  /// Declines a kundli request with a [reason].
  Future<void> declineKundliRequest(String id, String reason) async {
    await post(Endpoints.kundli.decline(id), data: {'reason': reason});
  }

  /// Submits the completed kundli report text.
  Future<void> submitKundliReport(String id, String reportText) async {
    await post(Endpoints.kundli.submit(id), data: {'reportText': reportText});
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  /// Fetches in-app notifications.
  Future<Map<String, dynamic>> fetchNotifications({int page = 1}) async {
    final res = await get(Endpoints.notifications.list,
        queryParameters: {'page': page, 'limit': 30});
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(String id) async {
    await patch(Endpoints.notifications.markRead(id));
  }

  /// Marks all notifications as read.
  Future<void> markAllNotificationsRead() async {
    await post(Endpoints.notifications.markAllRead);
  }

  /// Registers or refreshes an FCM device token.
  Future<void> registerFcmToken(String token, String platform) async {
    await post(Endpoints.notifications.registerFcmToken,
        data: {'token': token, 'platform': platform});
  }
}

// ─── Auth interceptor ──────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);
  final Dio _dio;

  bool _isRefreshing = false;
  final List<Function> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        _pendingRequests.add(() => _retry(err.requestOptions));
        return;
      }
      _isRefreshing = true;
      try {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken == null) {
          await TokenStorage.clear();
          handler.reject(err);
          return;
        }
        final response = await _dio.post(
          Endpoints.auth.refresh,
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );
        final data = response.data['data'] as Map<String, dynamic>;
        final newAccess = data['accessToken'] as String;
        final newRefresh = data['refreshToken'] as String;
        final id = await TokenStorage.getAstrologerId() ?? '';
        await TokenStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
          astrologerId: id,
        );
        for (final fn in _pendingRequests) {
          fn();
        }
        _pendingRequests.clear();
        handler.resolve(await _retry(err.requestOptions, newAccess));
      } catch (_) {
        await TokenStorage.clear();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
      }
      return;
    }
    handler.next(err);
  }

  Future<Response<dynamic>> _retry(RequestOptions opts, [String? token]) async {
    final t = token ?? await TokenStorage.getAccessToken();
    return _dio.request<dynamic>(
      opts.path,
      data: opts.data,
      queryParameters: opts.queryParameters,
      options: Options(
        method: opts.method,
        headers: {...opts.headers, if (t != null) 'Authorization': 'Bearer $t'},
      ),
    );
  }
}

// ─── Error interceptor ─────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.reject(err.copyWith(error: const NetworkException()));
      return;
    }

    final response = err.response;
    if (response == null) {
      handler.next(err);
      return;
    }

    final body = response.data;
    if (body is Map<String, dynamic>) {
      final error = body['error'] as Map<String, dynamic>?;
      final code = error?['code'] as String? ?? 'INTERNAL';
      final message =
          error?['message'] as String? ?? 'Something went wrong';

      final ex = switch (code) {
        'OTP_INVALID' => const OtpInvalidException(),
        'OTP_EXPIRED' => const OtpExpiredException(),
        'OTP_ATTEMPTS_EXCEEDED' => const OtpAttemptsExceededException(),
        'RATE_LIMIT' => RateLimitException(
            message: message,
            retryAfterSeconds:
                error?['details']?['retryAfterSeconds'] as int?,
          ),
        'AUTH_REQUIRED' => UnauthorizedException(message: message),
        'FORBIDDEN' => ForbiddenException(message: message),
        'NOT_FOUND' => NotFoundException(message: message),
        'VALIDATION' => ValidationException(message: message),
        _ => ApiException(code: code, message: message),
      };
      handler.reject(err.copyWith(error: ex));
      return;
    }
    handler.next(err);
  }
}

// ─── Helper ────────────────────────────────────────────────────────────────

/// Extracts a typed [AppException] from a raw [DioException] or rethrows.
///
/// Use in repository catch blocks:
/// ```dart
/// } on DioException catch (e) {
///   throw extractException(e);
/// }
/// ```
AppException extractException(Object err) {
  if (err is DioException && err.error is AppException) {
    return err.error as AppException;
  }
  if (err is AppException) return err;
  return const ServerException();
}
