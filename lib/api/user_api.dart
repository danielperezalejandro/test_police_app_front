import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart';

class UserApi {

  static Future<bool> registerUser(String name, String email, String password) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'provider': 'local',
    };
    final response = await ApiService.post('/users', body);
    return response.statusCode == 201;
  }
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await ApiService.post('/login', {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // contiene token + user
    } else {
      return null; // error de login
    }
  }

  static Future<Map<String, dynamic>?> registerWithGoogle(String name, String email) async {
    final body = {'name': name, 'email': email};
    final response = await ApiService.post('/google-register', body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Login con Google
  static Future<Map<String, dynamic>?> loginWithGoogle(String name, String email) async {
    final body = {'name': name, 'email': email};
    final response = await ApiService.post('/google-login', body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
  
}
