import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiClientProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  AuthController(this._repo) : super(false);

  final AuthRepository _repo;

  Future<void> sendPhoneOtp(String phone) => _repo.sendPhoneOtp(phone);

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    final result = await _repo.verifyPhoneOtp(phone, otp);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    state = true;
  }

  Future<void> emailSignup({
    required String email,
    required String password,
    required String displayName,
  }) => _repo.emailSignup(email: email, password: password, displayName: displayName);

  Future<void> resendEmailOtp(String email) => _repo.emailSignup(
        email: email,
        password: '',
        displayName: '',
      );

  Future<void> verifyEmailOtp(String email, String otp) async {
    final result = await _repo.verifyEmailOtp(email, otp);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    state = true;
  }

  Future<void> emailLogin(String email, String password) async {
    final result = await _repo.emailLogin(email, password);
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      astrologerId: result.astrologer.id,
    );
    state = true;
  }

  Future<void> forgotPassword(String email) => _repo.forgotPassword(email);

  Future<void> signOut() async {
    final refresh = await TokenStorage.getRefreshToken();
    if (refresh != null) await _repo.logout(refresh);
    await TokenStorage.clear();
    state = false;
  }
}
