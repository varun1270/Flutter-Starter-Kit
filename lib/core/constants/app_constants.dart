abstract final class AppConstants {
  static const appName = 'Northstar';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  static const requestTimeout = Duration(seconds: 20);
}
