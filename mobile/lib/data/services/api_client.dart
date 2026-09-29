import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;

/// Alamat API Laravel.
/// - Android emulator otomatis pakai 10.0.2.2 (localhost emulator = emulator itu sendiri).
/// - HP fisik: jalankan `php artisan serve --host=0.0.0.0` lalu build dengan
///   `flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api`.
const String _kApiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

String get kApiBaseUrl {
  if (_kApiBaseUrlOverride.isNotEmpty) return _kApiBaseUrlOverride;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api';
  }
  return 'http://localhost:8000/api';
}

const _kTimeout = Duration(seconds: 10);

class ApiClient {
  Future<String?> _token() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future.value(null);
    return user.getIdToken();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _token();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final res = await http
        .get(Uri.parse('$kApiBaseUrl/$path'), headers: await _headers())
        .timeout(_kTimeout);
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http
        .post(
          Uri.parse('$kApiBaseUrl/$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http
        .put(
          Uri.parse('$kApiBaseUrl/$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        )
        .timeout(_kTimeout);
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http
        .delete(Uri.parse('$kApiBaseUrl/$path'), headers: await _headers())
        .timeout(_kTimeout);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, res.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}