class AppConstants {
  static const String appName = 'CYBAC Puntos';
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String defaultDeviceName = String.fromEnvironment(
    'DEVICE_NAME',
    defaultValue: 'flutter-android',
  );
  static const String magicLinkScheme = 'cybacpuntos';
  static const String magicLinkHost = 'magic-link';
}
