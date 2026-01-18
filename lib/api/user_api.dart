import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class UserApi {
  /// Registro normal (email + password)
  static Future<bool> registerUser(
      String name, String email, String password) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'provider': 'local',
    };

    // Registro NO necesita token todavía
    final response = await ApiService.post('/users', body, auth: false);

    return response.statusCode == 201;
  }

  /// Login con email y contraseña
  static Future<Map<String, dynamic>?> loginUser(
      String email, String password) async {
    final response = await ApiService.post(
      '/login',
      {
        'email': email,
        'password': password,
      },
      auth: false, // 👈 aquí JAMÁS hay token aún
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Guardamos token y datos básicos de usuario
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userEmail', data['user']['email']);
      await prefs.setString('userName', data['user']['name']);

      return data; // contiene token + user
    } else {
      print('❌ Error loginUser: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  /// Registro con Google
  static Future<Map<String, dynamic>?> registerWithGoogle(
      String name, String email) async {
    final body = {
      'name': name,
      'email': email,
    };

    final response =
        await ApiService.post('/google-register', body, auth: false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    print(
        '❌ Error registerWithGoogle: ${response.statusCode} ${response.body}');
    return null;
  }

  /// Login con Google
  static Future<Map<String, dynamic>?> loginWithGoogle(
      String name, String email) async {
    final body = {
      'name': name,
      'email': email,
    };

    final response =
        await ApiService.post('/google-login', body, auth: false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userEmail', data['user']['email']);
      await prefs.setString('userName', data['user']['name']);

      return data;
    }

    print('❌ Error loginWithGoogle: ${response.statusCode} ${response.body}');
    return null;
  }

    /// Guarda en el backend las preguntas que el usuario ha fallado
  static Future<void> sendFailedQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    final response = await ApiService.post(
      '/failed-questions',
      {
        'question_ids': questionIds,
      },
      // usamos auth por defecto (true) → se enviará el Bearer
    );

    if (response.statusCode != 200) {
      print('❌ Error sendFailedQuestions: ${response.statusCode} ${response.body}');
      throw Exception('Error al guardar preguntas falladas');
    }
  }

}
