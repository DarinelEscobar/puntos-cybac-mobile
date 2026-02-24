class AppConstants {
  static const String appName = 'CYBAC Puntos';
  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String _apiBaseUrlFromEnvironment = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static String get apiBaseUrl {
    final envValue = _apiBaseUrlFromEnvironment.trim();
    final base = envValue.isEmpty ? _defaultApiBaseUrl : envValue;
    return _normalizeApiBaseUrl(base);
  }

  static String _normalizeApiBaseUrl(String baseUrl) {
    var normalized = baseUrl.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    // Keep callers flexible: if they pass only host/port, force API v1 path.
    final lower = normalized.toLowerCase();
    if (lower.endsWith('/api/v1')) {
      return normalized;
    }
    if (lower.endsWith('/api')) {
      return '$normalized/v1';
    }
    return '$normalized/api/v1';
  }

  static const String defaultDeviceName = String.fromEnvironment(
    'DEVICE_NAME',
    defaultValue: 'flutter-android',
  );
  static const String magicLinkScheme = 'cybacpuntos';
  static const String magicLinkHost = 'magic-link';
}
