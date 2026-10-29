import 'package:flutter/material.dart';

import '../../config.dart';
import 'gejala_admin_tab.dart';
import 'kerusakan_admin_tab.dart';
import 'rule_admin_tab.dart';

/// Portal Admin: dikunci PIN, lalu berisi pengelolaan (CRUD) gejala, kerusakan, dan aturan.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _unlocked = false;
  final _pinController = TextEditingController();
  String? _pinError;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _tryUnlock() {
    if (_pinController.text == kAdminPin) {
      setState(() {
        _unlocked = true;
        _pinError = null;
        _pinController.clear();
      });
    } else {
      setState(() => _pinError = 'PIN salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Portal Knowledge Base Admin')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 16),
                const Text('Khusus Pakar/Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  onSubmitted: (_) => _tryUnlock(),
                  decoration: InputDecoration(
                    labelText: 'Masukkan PIN',
                    border: const OutlineInputBorder(),
                    errorText: _pinError,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _tryUnlock,
                    child: const Text('Buka Portal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portal Knowledge Base Admin'),
          actions: [
            IconButton(
              tooltip: 'Kunci portal',
              icon: const Icon(Icons.lock),
              onPressed: () => setState(() => _unlocked = false),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [Tab(text: 'Gejala'), Tab(text: 'Kerusakan'), Tab(text: 'Aturan')],
          ),
        ),
        body: const TabBarView(
          children: [GejalaAdminTab(), KerusakanAdminTab(), RuleAdminTab()],
        ),
      ),
    );
  }
}
