import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../quiz/quiz_screen.dart';
import '../quiz/failed_questions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPremium = false;
  bool isLoadingUser = true;

  final List<Map<String, String>> options = const [
    {'title': 'Simulacro de examen'},
    {'title': 'Generar Test'},
    {'title': 'Parte específica'},
    {'title': 'Parte general'},
    {'title': 'Preguntas falladas'},
  ];

  // 🔹 Cargar isPremium desde SharedPreferences
  Future<void> loadUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final premium = prefs.getBool('isPremium') ?? false;

    setState(() {
      isPremium = premium;
      isLoadingUser = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserStatus();
  }

  void _showLoadingSpinner(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 4,
            ),
          ),
        );
      },
    );
  }

  Future<void> _startGeneratingTest(BuildContext context) async {
    _showLoadingSpinner(context);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }

  void _openFailedQuestions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FailedQuestionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 🔹 LISTA DE OPCIONES
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final title = options[index]['title']!;

              // Función para comprobar si el usuario puede abrir esta opción
              bool isAllowed = isPremium || title == 'Generar Test';

              return Opacity(
                opacity: isAllowed ? 1 : 0.4, // Visualmente bloqueado
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: title == 'Preguntas falladas'
                          ? Colors.red[50]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: title == 'Preguntas falladas'
                              ? Colors.red[900]
                              : Colors.black,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: title == 'Preguntas falladas'
                            ? Colors.redAccent
                            : Colors.black54,
                      ),
                      onTap: () {
                        if (!isAllowed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🔒 "$title" es una función premium',
                              ),
                            ),
                          );
                          return;
                        }

                        if (title == 'Generar Test') {
                          _startGeneratingTest(context);
                        } else if (title == 'Preguntas falladas') {
                          _openFailedQuestions(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Funcionalidad "$title" en desarrollo 🚧',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
