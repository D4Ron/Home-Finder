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

  Future<dynamic> get(String endpoint) async {
    final res = await _client
        .get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(),
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final res = await _client
        .patch(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    )
        .timeout(ApiConstants.timeout);
    return _parse(res);
  }

  Future<void> delete(String endpoint) async {
    final res = await _client
        .delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: await _headers(),
    )
        .timeout(ApiConstants.timeout);
    _parse(res);
  }

  dynamic _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      final decoded = jsonDecode(res.body);
      // Backend wraps data in { success, data, message }
      return decoded is Map && decoded.containsKey('data')
          ? decoded['data']
          : decoded;
    }
    final msg = _errorMsg(res);
    throw ApiException(msg, res.statusCode);
  }

  String _errorMsg(http.Response res) {
    try {
      return jsonDecode(res.body)['message'] ?? 'Erreur ${res.statusCode}';
    } catch (_) {
      return 'Erreur ${res.statusCode}';
    }
  }

  void dispose() => _client.close();
}