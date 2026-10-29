import 'package:flutter/material.dart';

import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  /// Nama laptop sebelumnya (diisi saat pengguna memilih "Ganti perangkat").
  final String initialName;
  const WelcomeScreen({super.key, this.initialName = ''});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
  TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mulai() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(laptopName: _controller.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.laptop_chromebook, size: 100, color: Color(0xFF1E3A8A)),
                  const SizedBox(height: 24),
                  const Text(
                    'Sistem Pakar Diagnosis Hardware',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diagnosis awal kerusakan laptop dengan metode Forward Chaining',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _controller,
                    maxLength: 40,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _mulai(),
                    decoration: const InputDecoration(
                      labelText: 'Masukkan Merk/Tipe Laptop',
                      hintText: 'Contoh: Lenovo LOQ, Asus ROG',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.computer),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Merk laptop wajib diisi';
                      if (t.length < 2) return 'Minimal 2 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _mulai,
                      child: const Text('Masuk ke Aplikasi', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
