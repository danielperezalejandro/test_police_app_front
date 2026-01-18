import 'package:flutter/material.dart';

class QuizReviewScreen extends StatefulWidget {
  final List<dynamic> questions;
  final List<int?> userAnswers;
  final List<bool?> userResults;

  const QuizReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.userResults,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];
    final options = [
      question['answer_a'],
      question['answer_b'],
      question['answer_c'],
    ];

    final selectedIndex = widget.userAnswers[currentIndex];
    final result = widget.userResults[currentIndex]; // true / false / null
    final correctIndex = question['correct_index'] - 1; // API 1-based

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión del test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona una pregunta para revisarla',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            /// 🔹 Cuadrícula de preguntas
            SizedBox(
              height: 180, // ajusta si quieres más/menos alto
              child: GridView.builder(
                itemCount: widget.questions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // nº columnas
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final qResult = widget.userResults[index];
                  Color bgColor;
                  if (qResult == true) {
                    bgColor = Colors.green[400]!;
                  } else if (qResult == false) {
                    bgColor = Colors.red[400]!;
                  } else {
                    bgColor = Colors.blueGrey[400]!;
                  }

                  final isCurrent = index == currentIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? Colors.black : Colors.white70,
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            /// 🔹 Detalle de la pregunta seleccionada
            Text(
              'Pregunta ${currentIndex + 1}/${widget.questions.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(options.length, (index) {
                      final option = options[index];
                      final isSelected = selectedIndex == index;
                      final isCorrectAnswer = index == correctIndex;

                      Color tileColor = Colors.white;
                      Color borderColor = Colors.grey.shade300;
                      IconData leadingIcon = Icons.circle_outlined;

                      // Respuesta correcta en verde
                      if (isCorrectAnswer) {
                        tileColor = Colors.green[50]!;
                        borderColor = Colors.green;
                        leadingIcon = Icons.check_circle_outline;
                      }

                      // Si marcó una incorrecta, la pintamos en rojo
                      if (!isCorrectAnswer && isSelected && result == false) {
                        tileColor = Colors.red[50]!;
                        borderColor = Colors.red;
                        leadingIcon = Icons.cancel_outlined;
                      }

                      // Si marcó la correcta, también icono bonito
                      if (isCorrectAnswer && isSelected && result == true) {
                        leadingIcon = Icons.check_circle;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          title: Text(option),
                          leading: Icon(leadingIcon),
                          // 👇 En revisión no dejamos cambiar nada
                          onTap: null,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    if (result != null)
                      Text(
                        result
                            ? '✅ Contestaste bien esta pregunta'
                            : '❌ Contestaste mal esta pregunta',
                        style: TextStyle(
                          color: result ? Colors.green : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        '⚠️ No contestaste esta pregunta',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            /// 🔹 Botón salir
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
