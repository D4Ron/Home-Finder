import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/api_constants.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  final _client = http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String endpoint, {Map<String, String>? queryParams}) {
    final base = '${ApiConstants.baseUrl}$endpoint';
    final uri = Uri.parse(base);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final res = await _client
        .get(_uri(endpoint, queryParams: queryParams), headers: await _headers())
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .post(
      _uri(endpoint),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  /// POST with query parameters (e.g. /auth/firebase-token?token=xxx)
  Future<dynamic> postWithQuery(
      String endpoint, {
        Map<String, String>? queryParams,
        Map<String, dynamic>? body,
      }) async {
    final res = await _client
        .post(
      _uri(endpoint, queryParams: queryParams),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .put(
      _uri(endpoint),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .patch(
      _uri(endpoint),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<void> delete(String endpoint) async {
    final res = await _client
        .delete(_uri(endpoint), headers: await _headers())
        .timeout(ApiConstants.timeout);
    _parse(res);
  }

  Future<dynamic> uploadFile(
      String endpoint,
      File file,
      String fieldName, {
        bool multipleFiles = false,
      }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath(fieldName, file.path),
    );
    final streamed = await request.send().timeout(ApiConstants.timeout);
    final res = await http.Response.fromStream(streamed);
    return _parse(res);
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      // Backend wraps data in { success, data, message }
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    final msg = _errorMsg(res);
    throw ApiException(msg, res.statusCode);
  }

  String _errorMsg(http.Response res) {
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      return body['message'] ?? body['error'] ?? 'Erreur ${res.statusCode}';
    } catch (_) {
      return 'Erreur ${res.statusCode}';
    }
  }

  void dispose() => _client.close();
}