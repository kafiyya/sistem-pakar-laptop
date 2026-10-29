import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServisScreen extends StatelessWidget {
  const ServisScreen({super.key});

  // Data contoh tempat servis di sekitar Malang. Ganti dengan data yang sudah diverifikasi.
  static const List<Map<String, String>> _tempatServis = [
    {'nama': 'Good Laptop Suhat', 'alamat': 'Jl. Soekarno Hatta, Jatimulyo', 'kontak': '081234567890', 'spesialisasi': 'Spesialis Hardware & Reballing Chipset'},
    {'nama': 'Dinoyo Computer Service', 'alamat': 'Jl. MT. Haryono, Dinoyo', 'kontak': '085678901234', 'spesialisasi': 'Servis Ringan, Ganti RAM/SSD, Cleaning'},
    {'nama': 'Malang IT Center Sumbersari', 'alamat': 'Kawasan Sumbersari', 'kontak': '081911223344', 'spesialisasi': 'Mati Total & Ganti Layar LCD'},
  ];

  Future<void> _open(BuildContext context, Uri uri, String failMessage) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) messenger.showSnackBar(SnackBar(content: Text(failMessage)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failMessage)));
    }
  }

  Uri _mapsUri(String keyword) => Uri.https(
    'www.google.com',
    '/maps/search/',
    {'api': '1', 'query': keyword},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Servis')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _tempatServis.length + 1,
        itemBuilder: (context, index) {
          if (index == _tempatServis.length) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Daftar di atas adalah contoh rujukan. Pastikan jam buka dan layanan dengan menghubungi tempat servis.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            );
          }
          final b = _tempatServis[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build_circle, color: Colors.indigo, size: 28),
                      const SizedBox(width: 10),
                      Expanded(child: Text(b['nama']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                  const Divider(),
                  Text('📍 ${b['alamat']!}'),
                  const SizedBox(height: 4),
                  Text('🛠 Spesialisasi: ${b['spesialisasi']!}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text('Maps'),
                        onPressed: () => _open(
                          context,
                          _mapsUri('${b['nama']} ${b['alamat']}'),
                          'Tidak dapat membuka Google Maps.',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Hubungi'),
                        onPressed: () => _open(
                          context,
                          Uri(scheme: 'tel', path: b['kontak']),
                          'Tidak dapat membuka aplikasi telepon.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
