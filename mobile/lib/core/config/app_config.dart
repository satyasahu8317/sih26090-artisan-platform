class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sih26090-artisan-platform.onrender.com',
  );

  // The widget ID is public configuration. MSG91 auth credentials stay on Node.
  static const msg91WidgetId = String.fromEnvironment(
    'MSG91_WIDGET_ID',
    defaultValue: '366964703749373230343732',
  );
}