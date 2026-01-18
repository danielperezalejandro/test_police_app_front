import 'package:flutter/material.dart';
import 'package:test_police_app_front/api/failed_questions_api.dart';

class FailedQuestionsScreen extends StatefulWidget {
  const FailedQuestionsScreen({super.key});

  @override
  State<FailedQuestionsScreen> createState() => _FailedQuestionsScreenState();
}

class _FailedQuestionsScreenState extends State<FailedQuestionsScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;

  /// Respuesta seleccionada por pregunta (0,1,2 o null)
  List<int?> userAnswers = [];

  /// Resultado por pregunta:
  /// true = correcta, false = incorrecta, null = aún no comprobada
  List<bool?> userResults = [];

  bool isLoading = true;

  // Estado de la pregunta actual (solo para pintar cómodo)
  int? selectedIndex;
  bool answered = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadFailedQuestions();
  }

  Future<void> _loadFailedQuestions() async {
    try {
      final data = await FailedQuestionsApi.getFailedQuestions();
      setState(() {
        questions = data;
        userAnswers = List<int?>.filled(data.length, null);
        userResults = List<bool?>.filled(data.length, null);
        isLoading = false;
      });

      if (questions.isNotEmpty) {
        currentIndex = 0;
        _restoreSelection();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar falladas: $e')),
      );
    }
  }

  /// Restaura la selección y el resultado de la pregunta actual
  void _restoreSelection() {
    if (questions.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= questions.length ||
        userAnswers.length != questions.length ||
        userResults.length != questions.length) {
      selectedIndex = null;
      answered = false;
      isCorrect = false;
      return;
    }

    selectedIndex = userAnswers[currentIndex];

    final result = userResults[currentIndex];
    answered = result != null;
    isCorrect = result ?? false;
  }

  Future<void> _checkAnswer() async {
    if (questions.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= questions.length) {
      return;
    }

    // Ya se comprobó esta pregunta → no se vuelve a comprobar
    if (userResults[currentIndex] != null) {
      return;
    }

    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una respuesta')),
      );
      return;
    }

    final question = questions[currentIndex];
    final correctIndex = question['correct_index']; // 1-based
    final correct = (selectedIndex! + 1 == correctIndex);

    // Guardar resultado (marca como "ya comprobada" en memoria)
    if (currentIndex < userResults.length) {
      userResults[currentIndex] = correct;
    }

    setState(() {
      answered = true;
      isCorrect = correct;
    });

    if (correct) {
      final int questionId = question['id'] is int
          ? question['id']
          : int.parse(question['id'].toString());

      try {
        // 👇 Solo limpiamos en backend, NO tocamos el array local
        await FailedQuestionsApi.removeSingleFailedQuestion(questionId);

        if (!mounted) return;
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar de falladas: $e')),
        );
      }
    }
  }

  void _nextQuestion() {
    if (questions.isEmpty) return;
    if (currentIndex >= questions.length - 1) return;

    setState(() {
      currentIndex++;
      _restoreSelection();
    });
  }

  void _prevQuestion() {
    if (questions.isEmpty) return;
    if (currentIndex <= 0) return;

    setState(() {
      currentIndex--;
      _restoreSelection();
    });
  }

  void _onSelectOption(int index) {
    if (questions.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= questions.length) {
      return;
    }

    // Si ya se ha comprobado esta pregunta, no dejamos cambiar respuesta
    if (userResults[currentIndex] != null) {
      return;
    }

    setState(() {
      if (currentIndex < userAnswers.length) {
        userAnswers[currentIndex] = index;
      }
      selectedIndex = index;

      // Mientras no se compruebe, no mostramos resultado
      answered = false;
      isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preguntas falladas'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preguntas falladas'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'No tienes preguntas falladas 🎉',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // Seguridad extra
    if (currentIndex < 0 || currentIndex >= questions.length) {
      currentIndex = 0;
      _restoreSelection();
    }

    final question = questions[currentIndex];
    final options = [
      question['answer_a'],
      question['answer_b'],
      question['answer_c'],
    ];

    final currentSelected =
        (currentIndex < userAnswers.length) ? userAnswers[currentIndex] : null;

    final alreadyChecked = userResults[currentIndex] != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas falladas'),
        centerTitle: true,
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(options.length, (index) {
              final option = options[index];
              final isSelected = currentSelected == index;

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
                  groupValue: currentSelected,
                  activeColor: Colors.blueAccent,
                  // Si ya está comprobada, no dejamos cambiar la selección
                  onChanged: alreadyChecked
                      ? null
                      : (value) {
                          if (value != null) {
                            _onSelectOption(value);
                          }
                        },
                ),
              );
            }),
            const SizedBox(height: 20),
            if (answered)
              Text(
                isCorrect
                    ? '✅ ¡Respuesta correcta! Esta pregunta ya no contará como fallada en próximos tests.'
                    : '❌ Respuesta incorrecta. La pregunta sigue en falladas.',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0 ? _prevQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  // Botón Comprobar desactivado si ya se comprobó
                  onPressed: alreadyChecked ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        alreadyChecked ? Colors.grey : Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Comprobar'),
                ),
                ElevatedButton(
                  onPressed:
                      currentIndex < questions.length - 1 ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Siguiente'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
