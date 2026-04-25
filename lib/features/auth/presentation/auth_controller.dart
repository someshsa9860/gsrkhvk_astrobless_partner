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

  Future<void> _onAuthSuccess(String accessToken) async {
    _ref.read(socketServiceProvider).connect(accessToken);
  }

  Future<void> sendPhoneOtp(String phone) => _repo.sendPhoneOtp(phone);

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    final result = await _repo.verifyPhoneOtp(phone, otp);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    await _onAuthSuccess(result.accessToken);
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
    await _onAuthSuccess(result.accessToken);
    state = true;
  }

  Future<void> emailLogin(String email, String password) async {
    final result = await _repo.emailLogin(email, password);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    await _onAuthSuccess(result.accessToken);
    state = true;
  }

  Future<void> forgotPassword(String email) => _repo.forgotPassword(email);

  Future<void> signOut() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh != null) await _repo.logout(refresh);
    _ref.read(socketServiceProvider).disconnect();
    await TokenStorage.clear();
    state = false;
  }
}
