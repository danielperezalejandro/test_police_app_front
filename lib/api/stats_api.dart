import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class StatsApi {
  /// Guarda resultados del test:
  /// answers = [{questionId: 1, isCorrect: true}, ...]
  static Future<void> saveTestResults(List<Map<String, dynamic>> answers) async {
    if (answers.isEmpty) return;

    final http.Response response = await ApiService.post(
      '/stats/save-test-results',
      {
        'answers': answers,
      },
      // no auth:false -> usa token por defecto (igual que failed-questions)
    );

    if (response.statusCode != 200) {
      print('❌ Error saveTestResults: ${response.statusCode} ${response.body}');
      throw Exception('Error al guardar estadísticas');
    }
  }

  /// Obtiene breakdown por type y topics
  static Future<Map<String, dynamic>> getBreakdown() async {
    final http.Response response = await ApiService.get(
      '/stats/breakdown',
      // requiere token -> no ponemos auth:false
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      print('❌ Error getBreakdown: ${response.statusCode} ${response.body}');
      throw Exception('Error al obtener estadísticas');
    }
  }
}
