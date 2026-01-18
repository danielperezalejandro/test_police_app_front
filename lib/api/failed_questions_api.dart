import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class FailedQuestionsApi {
  /// 🔹 Guarda preguntas falladas para el usuario actual
  /// POST /failed-questions
  static Future<void> saveFailedQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    final http.Response response = await ApiService.post(
      '/failed-questions',
      {
        'question_ids': questionIds,
      },
      // auth por defecto = true → envía Bearer
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al guardar preguntas falladas: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// 🔹 Obtiene todas las preguntas falladas del usuario actual
  /// GET /failed-questions
  static Future<List<dynamic>> getFailedQuestions() async {
    final http.Response response = await ApiService.get(
      '/failed-questions',
      // auth: true por defecto → requiere token
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception('Formato de respuesta inválido en getFailedQuestions');
      }
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado. ¿Token inválido o no logueado?');
    } else {
      throw Exception(
        'Error al obtener preguntas falladas: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// 🔹 Elimina una o varias preguntas falladas cuando el usuario acierta
  /// DELETE /failed-questions
  static Future<void> removeFailedQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return;

    final http.Response response = await ApiService.delete(
      '/failed-questions',
      data: {
        'question_ids': questionIds,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al eliminar preguntas falladas: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Helper cómodo para borrar solo una pregunta
  static Future<void> removeSingleFailedQuestion(int questionId) async {
    await removeFailedQuestions([questionId]);
  }
}
