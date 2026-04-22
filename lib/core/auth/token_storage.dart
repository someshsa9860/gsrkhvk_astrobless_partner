import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessKey = 'astrologer_access_token';
  static const _refreshKey = 'astrologer_refresh_token';
  static const _astrologerIdKey = 'astrologer_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String astrologerId,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _astrologerIdKey, value: astrologerId),
    ]);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<String?> getAstrologerId() => _storage.read(key: _astrologerIdKey);

  static Future<void> updateAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  static Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _astrologerIdKey),
    ]);
  }

  static Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessKey);
    return token != null && token.isNotEmpty;
  }
}
