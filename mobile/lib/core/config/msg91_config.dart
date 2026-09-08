class Msg91Config {
  Msg91Config._();

  static const String widgetId = String.fromEnvironment(
    'MSG91_WIDGET_ID',
  );

  static const String tokenAuth = String.fromEnvironment(
    'MSG91_TOKEN_AUTH',
  );

  static bool get isConfigured =>
      widgetId.isNotEmpty && tokenAuth.isNotEmpty;
}