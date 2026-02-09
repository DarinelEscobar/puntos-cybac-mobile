import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Uri _uri(String path) => Uri.parse('
      ' '$baseUrl$path');

  Future<http.Response> get(String path) async {
    return http.get(_uri(path));
  }
}
