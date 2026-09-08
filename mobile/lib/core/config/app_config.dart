class AppConfig {
  /// Base URL for the Node.js backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sih26090-artisan-platform.onrender.com',
  );

  /// MSG91 Widget ID (public widget identifier)
  static const String msg91WidgetId = String.fromEnvironment(
    'MSG91_WIDGET_ID',
    defaultValue: '366964703749373230343732',
  );

  /// MSG91 Widget Auth Token (Client token configured in local environment)
  /// Checks MSG91_TOKEN_AUTH first, then MSG91_AUTH_TOKEN, then local environment default.
  static const String msg91AuthToken = String.fromEnvironment(
    'MSG91_TOKEN_AUTH',
    defaultValue: String.fromEnvironment(
      'MSG91_AUTH_TOKEN',
      defaultValue: '567739TdKjDYyki6a9afdbaP1',
    ),
  );

  /// Enable Development / Demo Guest Mode
  static const bool enableGuestMode = bool.fromEnvironment(
    'ENABLE_GUEST_MODE',
    defaultValue: true,
  );
}
