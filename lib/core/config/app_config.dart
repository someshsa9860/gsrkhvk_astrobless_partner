class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/v1/astrologer',
  );

  static const publicApiBaseUrl = String.fromEnvironment(
    'PUBLIC_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/v1/public',
  );

  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://10.0.2.2:3000',
  );

  static const agoraAppId = String.fromEnvironment('AGORA_APP_ID', defaultValue: '');

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static const version = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static const isDev = bool.fromEnvironment('IS_DEV', defaultValue: true);

  static const appName = 'Astrobless Partner';
}
