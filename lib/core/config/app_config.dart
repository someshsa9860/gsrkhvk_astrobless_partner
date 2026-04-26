import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String _prodApiBase = 'https://api.astrology.qikbill.in';
  static const String _localApiBase = 'http://10.0.2.2:3000'; // Android emulator
  static const String _localApiBaseIos = 'http://localhost:3000'; // iOS simulator

  static String get _devBase =>
      Platform.isAndroid ? _localApiBase : _localApiBaseIos;

  static String get _base =>
      const String.fromEnvironment('API_HOST').isNotEmpty
          ? const String.fromEnvironment('API_HOST')
          : (kDebugMode ? _devBase : _prodApiBase);

  static String get apiBaseUrl => '$_base/v1/astrologer';
  static String get publicApiBaseUrl => '$_base/v1/public';
  static String get wsBaseUrl =>
      kDebugMode && const String.fromEnvironment('API_HOST').isEmpty
          ? (Platform.isAndroid ? 'ws://10.0.2.2:3000' : 'ws://localhost:3000')
          : const String.fromEnvironment('API_HOST').isNotEmpty
              ? const String.fromEnvironment('API_HOST')
                  .replaceFirst('http', 'ws')
              : 'wss://api.astrology.qikbill.in';

  static const agoraAppId =
      String.fromEnvironment('AGORA_APP_ID', defaultValue: '');
  static const sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const version =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static bool get isDev => kDebugMode;

  static const appName = 'Astrobless Partner';

  static const enableCertPinning =
      bool.fromEnvironment('ENABLE_CERT_PINNING', defaultValue: false);
  static const enableRequestSigning =
      bool.fromEnvironment('ENABLE_REQUEST_SIGNING', defaultValue: false);
  static const enableAppAttestation =
      bool.fromEnvironment('ENABLE_APP_ATTESTATION', defaultValue: false);
  static const certSha256Fingerprint =
      String.fromEnvironment('CERT_SHA256_FINGERPRINT', defaultValue: '');
  static const hmacSecret =
      String.fromEnvironment('HMAC_SECRET', defaultValue: '');
}
