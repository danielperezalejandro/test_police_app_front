import 'package:flutter/material.dart'; 
import 'dart:convert';
import 'package:test_police_app_front/api/question_api.dart'; // 👈 USAMOS QuestionApi

import 'quiz_review_screen.dart'; // 👈 Pantalla de revisión

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;

  /// Respuesta seleccionada por pregunta (índice 0,1,2 o null si no contestó)
  List<int?> userAnswers = [];

  /// Resultado por pregunta: true = correcta, false = incorrecta, null = sin evaluar / sin contestar
  List<bool?> userResults = [];

  bool answered = false; // para mostrar feedback en la pantalla de test
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final data = await QuestionApi.getRandomQuestions();

      setState(() {
        questions = data;
        userAnswers = List<int?>.filled(data.length, null);
        userResults = List<bool?>.filled(data.length, null);
      });
    } catch (e) {
      print('⚠️ Error al obtener preguntas: $e');
    }
  }

  void checkAnswer() {
    final selectedIndex = userAnswers[currentIndex];
    if (selectedIndex == null) return;

    final correctIndex = questions[currentIndex]['correct_index']; // 1-based
    final correct = (selectedIndex + 1 == correctIndex);

    setState(() {
      answered = true;
      isCorrect = correct;
      userResults[currentIndex] = correct;
    });
  }

  void nextQuestion() {
    // 1️⃣ Si hay respuesta marcada y aún no se ha evaluado, la evaluamos aquí
    final selected = userAnswers[currentIndex];
    if (userResults[currentIndex] == null && selected != null) {
      final correctIndex = questions[currentIndex]['correct_index']; // 1-based
      final correct = (selected + 1 == correctIndex);
      userResults[currentIndex] = correct;
    }

    // 2️⃣ Navegación normal
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        _restoreSelection();
      });
    } else {
      _showResults();
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _restoreSelection();
      });
    }
  }

  void _restoreSelection() {
    final selected = userAnswers[currentIndex];
    if (selected != null) {
      answered = userResults[currentIndex] != null;
      isCorrect = userResults[currentIndex] ?? false;
    } else {
      answered = false;
      isCorrect = false;
    }
  }

  void selectAnswer(int index) {
    setState(() {
      userAnswers[currentIndex] = index;
      // No marcamos "answered" aquí; solo cuando se comprueba o al pasar de pregunta
    });
  }

  void closeQuiz() {
    Navigator.pop(context);
  }

  Future<void> _showResults() async {
    final total = questions.length;
    final correct = userResults.where((e) => e == true).length;

    // 🔹 Construir lista de IDs de preguntas falladas
    final List<int> failedIds = [];
    for (int i = 0; i < questions.length; i++) {
      if (userResults[i] == false) {
        final qid = questions[i]['id'];

        if (qid is int) {
          failedIds.add(qid);
        } else if (qid is String) {
          final parsed = int.tryParse(qid);
          if (parsed != null) failedIds.add(parsed);
        }
      }
    }

    // 🔹 Enviar al backend las falladas (si hay)
    if (failedIds.isNotEmpty) {
      try {
        await QuestionApi.sendFailedQuestions(failedIds);
      } catch (e) {
        print('⚠️ Error enviando preguntas falladas: $e');
      }
    }

    if (!mounted) return;

    // 🔹 Mostrar resultados
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resultado final'),
          content: Text('Has acertado $correct de $total preguntas 🎯'),
          actions: [
            TextButton(
              onPressed: () {
                // Cerrar diálogo y salir del test
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                // Cerrar diálogo y abrir revisión
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizReviewScreen(
                      questions: questions,
                      userAnswers: userAnswers,
                      userResults: userResults,
                    ),
                  ),
                );
              },
              child: const Text('Revisar preguntas'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];
    final options = [
      question['answer_a'],
      question['answer_b'],
      question['answer_c'],
    ];

    final selectedIndex = userAnswers[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('POLICE TEST'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: closeQuiz,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${currentIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(options.length, (index) {
              final option = options[index];
              final isSelected = selectedIndex == index;

              Color tileColor = Colors.white;
              if (answered && isSelected) {
                tileColor = isCorrect ? Colors.green[100]! : Colors.red[100]!;
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: RadioListTile<int>(
                  title: Text(option),
                  value: index,
                  groupValue: selectedIndex,
                  activeColor: Colors.blueAccent,
                  onChanged: answered
                      ? null
                      : (value) {
                          if (value != null) {
                            selectAnswer(value);
                          }
                        },
                ),
              );
            }),
            const SizedBox(height: 20),
            if (answered)
              Text(
                isCorrect ? '✅ ¡Respuesta correcta!' : '❌ Respuesta incorrecta',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0 ? prevQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Atrás'),
                ),
                ElevatedButton(
                  onPressed:
                      selectedIndex != null && !answered ? checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: selectedIndex != null ? Colors.white : Colors.black,
                  ),
                  child: const Text('Comprobar'),
                ),
                ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currentIndex < questions.length - 1
                        ? 'Siguiente'
                        : 'Finalizar',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
