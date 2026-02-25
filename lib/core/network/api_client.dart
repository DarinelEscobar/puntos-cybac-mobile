import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? bearerToken,
  }) async {
    return _send(method: 'GET', path: path, bearerToken: bearerToken);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      bearerToken: bearerToken,
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    Uri uri;
    try {
      uri = _uri(path);
    } catch (error) {
      throw ApiClientException(message: 'Invalid API URL: $error');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken.trim().isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };

    late final http.Response response;
    try {
      if (method == 'GET') {
        response = await _httpClient.get(uri, headers: headers);
      } else if (method == 'POST') {
        response = await _httpClient.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      } else {
        throw ApiClientException(message: 'Unsupported HTTP method: $method');
      }
    } catch (error) {
      throw ApiClientException(message: 'Network error: $error');
    }

    final dynamic payload = _decodePayload(response.bodyBytes);
    final mapPayload = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload is! Map<String, dynamic>) {
        throw ApiClientException(
          statusCode: response.statusCode,
          message: 'Invalid server payload format.',
          body: payload,
        );
      }

      return payload;
    }

    throw ApiClientException(
      statusCode: response.statusCode,
      message: _resolveErrorMessage(mapPayload, response.statusCode),
      errorCode: _resolveErrorCode(mapPayload),
      body: payload,
    );
  }

  dynamic _decodePayload(List<int> bytes) {
    final content = utf8.decode(bytes);
    if (content.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(content);
    } catch (_) {
      return <String, dynamic>{'raw': content};
    }
  }

  String _resolveErrorMessage(Map<String, dynamic> body, int statusCode) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return 'Request failed with status $statusCode.';
  }

  String? _resolveErrorCode(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final code = error['code'];
      if (code != null) {
        return code.toString();
      }
    }

    final legacyCode = body['error_code'];
    if (legacyCode != null) {
      return legacyCode.toString();
    }

    return null;
  }

  void dispose() {
    _httpClient.close();
  }
}

class ApiClientException implements Exception {
  ApiClientException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.body,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic body;

  @override
  String toString() {
    final codePart = errorCode != null ? ' [$errorCode]' : '';
    final statusPart = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '$message$codePart$statusPart';
  }
}
