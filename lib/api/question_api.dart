import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class QuestionApi {
  /// Obtiene un listado de preguntas aleatorias desde la API
  static Future<List<dynamic>> getRandomQuestions() async {
    final http.Response response =
        await ApiService.get('/questions/random', auth: false); 
        // auth:false si tu endpoint no exige login

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data;
    } else {
      print('❌ Error getRandomQuestions: ${response.statusCode} ${response.body}');
      throw Exception('Error al obtener preguntas');
    }
  }

  /// Envía al backend las preguntas que el usuario ha fallado
  static Future<void> sendFailedQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    final http.Response response = await ApiService.post(
      '/failed-questions',
      {
        'question_ids': questionIds,
      },
      // aquí no pasamos auth:false → usa el token (Bearer) por defecto
    );

    if (response.statusCode != 200) {
      print('❌ Error sendFailedQuestions: ${response.statusCode} ${response.body}');
      throw Exception('Error al guardar preguntas falladas');
    }
  }
}
