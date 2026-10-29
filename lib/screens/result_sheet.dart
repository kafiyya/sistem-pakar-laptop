import 'package:flutter/material.dart';
import '../models/models.dart';
import 'service_screen.dart';

/// Menampilkan hasil diagnosis (kandidat utama + kemungkinan lain) dalam bottom sheet.
Future<void> showResultSheet(
    BuildContext context,
    String laptopName,
    List<DiagnosisResult> results,
    ) {
  final navigator = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      final top = results.isEmpty ? null : results.first;
      final others = results.length > 1 ? results.sublist(1) : <DiagnosisResult>[];
      return Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(top != null ? Icons.warning_amber_rounded : Icons.help_outline,
                      color: top != null ? Colors.orange[800] : Colors.blue, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      top != null ? 'Hasil Diagnosis Forward Chaining' : 'Tidak Ditemukan Kecocokan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Text('Perangkat: $laptopName',
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              const Divider(height: 24),
              if (top == null)
                const Text(
                  'Gejala yang Anda pilih belum cocok dengan aturan pada sistem (kecocokan minimal 60%). '
                      'Coba tambahkan gejala lain yang dialami, atau konsultasikan ke teknisi.',
                )
              else ...[
                Text(top.kerusakan.nama,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(sheetContext).primaryColor)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'Tingkat Kecocokan: ${top.percent.toStringAsFixed(1)}%'
                        '${top.isFullMatch ? ' (semua gejala aturan terpenuhi)' : ''}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[900]),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(top.kerusakan.deskripsi, style: TextStyle(color: Colors.grey[800])),
                const SizedBox(height: 12),
                const Text('Instruksi Penanganan:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(top.kerusakan.solusi, style: TextStyle(color: Colors.green[900], height: 1.4)),
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Kemungkinan lain:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...others.map((o) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.chevron_right),
                    title: Text(o.kerusakan.nama),
                    trailing: Text('${o.percent.toStringAsFixed(1)}%'),
                  )),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Masalah belum terselesaikan?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 8),
                      const Text(
                        'Jika Anda ragu melakukan perbaikan mandiri, sebaiknya bawa laptop ke teknisi profesional.',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Lihat Rekomendasi Servis'),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            navigator.push(MaterialPageRoute(builder: (_) => const ServisScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Catatan: hasil ini adalah perkiraan awal berdasarkan gejala yang dipilih, '
                    'bukan pengganti pemeriksaan teknisi.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Tutup Laporan'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
