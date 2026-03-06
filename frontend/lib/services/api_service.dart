import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiService {
  ApiService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.baseUrl}$path')
        .replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path,
      {Map<String, String>? query, bool auth = true}) async {
    try {
      final response = await http
          .get(_uri(path, query), headers: await _headers(auth: auth))
          .timeout(
            const Duration(seconds: 15),
          );
      return _handleResponse(response);
    } catch (_) {
      throw Exception(
          'Network error: unable to reach backend at ${AppConfig.baseUrl}. Make sure backend server is running.');
    }
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (_) {
      throw Exception(
          'Network error: unable to reach backend at ${AppConfig.baseUrl}. Make sure backend server is running.');
    }
  }

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final response = await http
          .put(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (_) {
      throw Exception(
          'Network error: unable to reach backend at ${AppConfig.baseUrl}. Make sure backend server is running.');
    }
  }

  Future<dynamic> uploadFile({
    required String path,
    required String field,
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files
          .add(http.MultipartFile.fromBytes(field, bytes, filename: filename));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (_) {
      throw Exception(
          'Network error: unable to reach backend at ${AppConfig.baseUrl}. Make sure backend server is running.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body is Map<String, dynamic>
        ? (body['detail'] ?? 'Request failed')
        : 'Request failed';
    throw Exception(message.toString());
  }
}
