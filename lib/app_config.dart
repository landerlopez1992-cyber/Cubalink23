// lib/app_config.dart
class AppConfig {
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://cubalink23-system.onrender.com',
  );
  static const payBase = String.fromEnvironment(
    'PAY_BASE',
    defaultValue: 'https://cubalink23-payments.onrender.com',
  );
  static const gitSha = String.fromEnvironment('GIT_SHA', defaultValue: 'unknown');
  static const buildTime = String.fromEnvironment('BUILD_TIME', defaultValue: 'unknown');
}
