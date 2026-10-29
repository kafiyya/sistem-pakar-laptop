import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'admin/admin_screen.dart';
import 'diagnosis_screen.dart';
import 'kamus_screen.dart';
import 'riwayat_screen.dart';

class MainShell extends StatefulWidget {
  final String laptopName;
  const MainShell({super.key, required this.laptopName});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DiagnosisScreen(laptopName: widget.laptopName),
      const KamusScreen(),
      const RiwayatScreen(),
      const AdminScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          // Riwayat selalu dimuat ulang saat tab dibuka.
          if (i == 2) AppState.instance.historyRevision.value++;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), activeIcon: Icon(Icons.build_circle), label: 'Diagnosis'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Kamus'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
