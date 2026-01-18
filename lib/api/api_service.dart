import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // tu API Slim

  /// Lee el token guardado
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Construye los headers. Si [auth] es true, añade Authorization: Bearer <token>
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// GET genérico
  static Future<http.Response> get(
    String endpoint, {
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.get(url, headers: headers);
  }

  /// POST genérico
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  /// DELETE genérico (con body opcional)
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers(auth: auth);

    return await http.delete(
      url,
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
  }
}
