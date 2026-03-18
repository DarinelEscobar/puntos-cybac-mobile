class AppConstants {
  static const String appName = 'CYBAC Puntos';
  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String _apiBaseUrlFromEnvironment = String.fromEnvironment(
    'API_BASE_URL',
  );
  static String get apiBaseUrl {
    final envValue = _apiBaseUrlFromEnvironment.trim();
    final selected = envValue.isEmpty ? _defaultApiBaseUrl : envValue;
    return _normalizeApiBaseUrl(selected);
  }

  static String _normalizeApiBaseUrl(String baseUrl) {
    final cleaned = _sanitizeBaseUrlInput(baseUrl);
    final parsed = _parseBaseUri(cleaned);
    if (parsed == null || parsed.host.trim().isEmpty) {
      return _defaultApiBaseUrl;
    }

    final origin = StringBuffer()
      ..write(parsed.scheme.isEmpty ? 'http' : parsed.scheme)
      ..write('://')
      ..write(parsed.host);

    if (parsed.hasPort) {
      origin
        ..write(':')
        ..write(parsed.port);
    }

    final normalizedPath = _normalizeApiPath(parsed.path);
    return '${origin.toString()}$normalizedPath';
  }

  static String _sanitizeBaseUrlInput(String rawValue) {
    var value = rawValue.trim();

    while ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1).trim();
    }

    return value.replaceAll('\\', '/');
  }

  static Uri? _parseBaseUri(String rawValue) {
    final direct = Uri.tryParse(rawValue);
    if (direct != null && direct.host.trim().isNotEmpty) {
      return direct;
    }

    final withHttp = Uri.tryParse('http://$rawValue');
    if (withHttp != null && withHttp.host.trim().isNotEmpty) {
      return withHttp;
    }

    return null;
  }

  static String _normalizeApiPath(String rawPath) {
    var path = rawPath.trim();
    if (path.isEmpty) {
      return '/api/v1';
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    path = path.replaceAll(RegExp('/+'), '/');

    final lower = path.toLowerCase();
    final apiV1Index = lower.indexOf('/api/v1');
    if (apiV1Index >= 0) {
      final prefix = path
          .substring(0, apiV1Index)
          .replaceAll(RegExp(r'/+$'), '');
      return '${prefix.isEmpty ? '' : prefix}/api/v1';
    }

    final apiVTypoIndex = lower.indexOf('/api/vl');
    if (apiVTypoIndex >= 0) {
      final prefix = path
          .substring(0, apiVTypoIndex)
          .replaceAll(RegExp(r'/+$'), '');
      return '${prefix.isEmpty ? '' : prefix}/api/v1';
    }

    final apiSegmentIndex = lower.indexOf('/api/');
    if (apiSegmentIndex >= 0) {
      final prefix = path
          .substring(0, apiSegmentIndex)
          .replaceAll(RegExp(r'/+$'), '');
      return '${prefix.isEmpty ? '' : prefix}/api/v1';
    }

    if (lower.endsWith('/api')) {
      return '$path/v1';
    }

    path = path.replaceAll(RegExp(r'/+$'), '');
    return '$path/api/v1';
  }

  static const String defaultDeviceName = String.fromEnvironment(
    'DEVICE_NAME',
    defaultValue: 'flutter-android',
  );
  static const String magicLinkScheme = 'cybacpuntos';
  static const String magicLinkHost = 'magic-link';
}
