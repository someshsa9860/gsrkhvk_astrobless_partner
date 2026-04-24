import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

class SecurityInterceptor extends Interceptor {
  String? _attestationToken;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (AppConfig.enableRequestSigning && AppConfig.hmacSecret.isNotEmpty) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = options.uri.path;
      final sig = _hmac(AppConfig.hmacSecret, '${options.method.toUpperCase()}:$path:$ts');
      options.headers['X-Timestamp'] = ts.toString();
      options.headers['X-Signature'] = sig;
    }
    if (AppConfig.enableAppAttestation && _attestationToken != null) {
      options.headers['X-App-Attest'] = _attestationToken!;
    }
    handler.next(options);
  }

  String _hmac(String secret, String message) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(message)).toString();
  }

  void setAttestationToken(String token) => _attestationToken = token;
}
