import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../stats/stats_screen.dart';
import 'package:test_police_app_front/api/stats_api.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1; // Test por defecto

  final List<String> _titles = ['Perfil', 'Test', 'Estadísticas'];

  // 🔥 Guardamos aquí las stats para pasarlas a StatsScreen
  Map<String, dynamic>? _statsData;
  bool _loadingStats = false;

  void _onNavTapped(int index) async {
    // ✅ Si pulsa "Estadísticas", primero llamamos API
    if (index == 2) {
      setState(() => _loadingStats = true);

      try {
        final data = await StatsApi.getBreakdown();
        _statsData = data;
      } catch (e) {
        _statsData = {
          "success": false,
          "error": e.toString(),
        };
      } finally {
        if (!mounted) return;

        setState(() {
          _loadingStats = false;
          _selectedIndex = 2;
        });
      }

      return;
    }

    // Perfil / Test normal
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ProfileScreen(),
      const HomeScreen(),
      StatsScreen(
        statsData: _statsData, // 👈 le pasamos los datos ya cargados
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),

          // 👇 Overlay de carga mientras llama a stats
          if (_loadingStats)
            Container(
              color: Colors.black.withOpacity(0.05),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
