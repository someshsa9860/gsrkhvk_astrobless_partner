import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_models.dart';
import '../../../core/network/api_client.dart';

/// Repository for all astrologer authentication operations.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in [Endpoints.auth].
/// All methods throw typed [AppException] subclasses on failure.
class AuthRepository {
  AuthRepository(this._client);
  final ApiClient _client;

  /// Sends a 6-digit SMS OTP to [phone] (MSG91).
  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _client.sendPhoneOtp(phone);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Verifies [otp] for [phone] and returns access + refresh tokens.
  Future<LoginResult> verifyPhoneOtp(String phone, String otp) async {
    try {
      final data = await _client.verifyPhoneOtp(phone, otp);
      return LoginResult.fromJson(data);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Creates a new astrologer account with email + password and triggers
  /// an email OTP for verification.
  Future<void> emailSignup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _client.emailSignup(
          email: email, password: password, displayName: displayName);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Verifies the email OTP sent during sign-up and returns tokens.
  Future<LoginResult> verifyEmailOtp(String email, String otp) async {
    try {
      final data = await _client.verifyEmailOtp(email, otp);
      return LoginResult.fromJson(data);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Resends the email verification OTP (rate-limited: 3/hr/email).
  Future<void> resendEmailOtp(String email) async {
    try {
      await _client.resendEmailOtp(email);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Authenticates with email + password.
  Future<LoginResult> emailLogin(String email, String password) async {
    try {
      final data = await _client.emailLogin(email, password);
      return LoginResult.fromJson(data);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Requests a password reset link for [email].
  Future<void> forgotPassword(String email) async {
    try {
      await _client.forgotPassword(email);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Revokes the session identified by [refreshToken] (best-effort logout).
  Future<void> logout(String refreshToken) async {
    await _client.logout(refreshToken);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
