import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/realtime/socket_service.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiClientProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref);
});

class AuthController extends StateNotifier<bool> {
  AuthController(this._repo, this._ref) : super(false);

  final AuthRepository _repo;
  final Ref _ref;

  Future<void> _onAuthSuccess(String accessToken, String astrologerId) async {
    _ref.read(socketServiceProvider).connect(accessToken);
    await _registerFcmTopic(astrologerId);
  }

  /// Registers the FCM token with the backend and subscribes to the
  /// astrologer's personal topic (topic = astrologerId). Called on every login
  /// so token rotations are handled automatically.
  Future<void> _registerFcmTopic(String astrologerId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null) return;

      final platform = defaultTargetPlatform.name.toLowerCase();
      final client = _ref.read(apiClientProvider);
      await client.registerFcmToken(token, platform);

      // Client-side topic subscription as a belt-and-suspenders approach.
      // The backend also subscribes the token server-side on registerFcmToken.
      await messaging.subscribeToTopic(astrologerId);
      debugPrint('[FCM] subscribed to topic: $astrologerId');

      // Re-subscribe on token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        await client.registerFcmToken(newToken, platform);
        await messaging.subscribeToTopic(astrologerId);
      });
    } catch (e) {
      debugPrint('[FCM] topic registration failed: $e');
    }
  }

  Future<void> sendPhoneOtp(String phone) => _repo.sendPhoneOtp(phone);

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    final result = await _repo.verifyPhoneOtp(phone, otp);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    await _onAuthSuccess(result.accessToken, result.astrologer.id);
    state = true;
  }

  Future<void> emailSignup({
    required String email,
    required String password,
    required String displayName,
  }) => _repo.emailSignup(email: email, password: password, displayName: displayName);

  Future<void> resendEmailOtp(String email) => _repo.resendEmailOtp(email);

  Future<void> verifyEmailOtp(String email, String otp) async {
    final result = await _repo.verifyEmailOtp(email, otp);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    await _onAuthSuccess(result.accessToken, result.astrologer.id);
    state = true;
  }

  Future<void> emailLogin(String email, String password) async {
    final result = await _repo.emailLogin(email, password);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    await _onAuthSuccess(result.accessToken, result.astrologer.id);
    state = true;
  }

  Future<void> forgotPassword(String email) => _repo.forgotPassword(email);

  Future<void> signOut() async {
    // Unsubscribe from FCM topic before clearing tokens
    final astrologerId = await TokenStorage.getAstrologerId();
    if (astrologerId != null) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(astrologerId);
        debugPrint('[FCM] unsubscribed from topic: $astrologerId');
      } catch (e) {
        debugPrint('[FCM] topic unsubscribe failed: $e');
      }
    }
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh != null) await _repo.logout(refresh);
    _ref.read(socketServiceProvider).disconnect();
    await TokenStorage.clear();
    state = false;
  }
}
