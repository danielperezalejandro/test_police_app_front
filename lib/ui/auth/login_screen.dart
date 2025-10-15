import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user_api.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String message = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => message = 'Por favor, rellena todos los campos.');
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final result = await UserApi.loginUser(email, password);

      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['token']);
        await prefs.setString('userEmail', result['user']['email']);
        await prefs.setString('userName', result['user']['name']);

        setState(() => message = '✅ Inicio de sesión correcto');

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        });
      } else {
        setState(() => message = '❌ Correo o contraseña incorrectos');
      }
    } catch (e) {
      setState(() => message = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 LOGIN/REGISTRO CON GOOGLE
  Future<void> signInWithGoogle() async {
  try {
    setState(() => isLoading = true);

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      setState(() => message = 'Inicio con Google cancelado');
      return;
    }

    final name = googleUser.displayName ?? '';
    final email = googleUser.email;

    // 1️⃣ Intentar login primero
    var loginResult = await UserApi.loginWithGoogle(name, email);

    // 2️⃣ Si no existe, registrar y luego volver a loguear
    if (loginResult == null) {
      final registerResult = await UserApi.registerWithGoogle(name, email);
      if (registerResult != null) {
        // Ahora sí, hacer login
        loginResult = await UserApi.loginWithGoogle(name, email);
      }
    }

    // 3️⃣ Si el login fue exitoso
    if (loginResult != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResult['token']);
      await prefs.setString('userEmail', loginResult['user']['email']);
      await prefs.setString('userName', loginResult['user']['name']);

      setState(() => message = '✅ Sesión iniciada con Google');

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    } else {
      setState(() => message = '❌ No se pudo iniciar sesión con Google');
    }
  } catch (e) {
    setState(() => message = 'Error al iniciar sesión: $e');
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", width: 100, height: 100),
                const SizedBox(height: 40),
                const Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                // Campos
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Contraseña"),
                ),
                const SizedBox(height: 24),

                // Botón normal
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      disabledBackgroundColor: Colors.blueAccent.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // 🔹 BOTÓN GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google-logo.png', // agrega el logo aquí
                      height: 24,
                    ),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black26),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      color: message.startsWith('✅')
                          ? Colors.green
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
