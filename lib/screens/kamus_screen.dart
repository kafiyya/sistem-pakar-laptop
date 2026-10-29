import 'package:flutter/material.dart';

import '../widgets/kb_builder.dart';

class KamusScreen extends StatelessWidget {
  const KamusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamus Hardware Laptop')),
      body: KbBuilder(
        builder: (context, kb) {
          if (kb.kerusakan.isEmpty) {
            return const Center(child: Text('Belum ada data kerusakan.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: kb.kerusakan.length,
            itemBuilder: (context, i) {
              final item = kb.kerusakan[i];
              final gejalaTerkait = <String>{
                for (final r in kb.rules.where((r) => r.kerusakanId == item.id)) ...r.gejalaIds,
              }.map((id) => kb.gejalaById(id)?.nama).whereType<String>().toList();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(item.id,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ),
                  title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deskripsi Komponen:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item.deskripsi),
                    if (gejalaTerkait.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Gejala yang umum muncul:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...gejalaTerkait.map((n) => Text('• $n')),
                    ],
                    const SizedBox(height: 12),
                    const Text('Saran Tindakan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 4),
                    Text(item.solusi),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
