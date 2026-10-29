import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/models.dart';
import '../../widgets/kb_builder.dart';
import 'admin_common.dart';

class GejalaAdminTab extends StatelessWidget {
  const GejalaAdminTab({super.key});

  Future<void> _form(BuildContext context, {Gejala? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nama = TextEditingController(text: existing?.nama ?? '');
    final bobot = TextEditingController(text: (existing?.bobot ?? 1.0).toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'Tambah Gejala' : 'Ubah Gejala ${existing.id}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nama,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Nama gejala'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama gejala wajib diisi' : null,
                ),
                TextFormField(
                  controller: bobot,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Bobot (0.1 - 5)'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (n == null) return 'Masukkan angka';
                    if (n < 0.1 || n > 5) return 'Bobot harus 0.1 - 5';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(c, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    final namaText = nama.text.trim();
    final bobotVal = double.tryParse(bobot.text.replaceAll(',', '.')) ?? 1.0;
    nama.dispose();
    bobot.dispose();
    if (ok != true || !context.mounted) return;

    try {
      if (existing == null) {
        final id = await DatabaseHelper.instance.nextId('gejala', 'G');
        await DatabaseHelper.instance.insertGejala(Gejala(id: id, nama: namaText, bobot: bobotVal));
      } else {
        await DatabaseHelper.instance
            .updateGejala(Gejala(id: existing.id, nama: namaText, bobot: bobotVal));
      }
      notifyKbChanged();
    } catch (_) {
      if (context.mounted) showMsg(context, 'Gagal menyimpan gejala.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context),
        icon: const Icon(Icons.add),
        label: const Text('Gejala'),
      ),
      body: KbBuilder(
        builder: (context, kb) {
          if (kb.gejala.isEmpty) return const Center(child: Text('Belum ada gejala.'));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: kb.gejala.length,
            itemBuilder: (context, i) {
              final g = kb.gejala[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(g.id, style: const TextStyle(fontSize: 11))),
                  title: Text(g.nama),
                  subtitle: Text('Bobot: ${g.bobot}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _form(context, existing: g)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final used = kb.rules.where((r) => r.gejalaIds.contains(g.id)).length;
                          final ok = await confirmDelete(
                            context,
                            'Hapus ${g.id}?',
                            used > 0
                                ? 'Gejala dipakai pada $used aturan dan akan dihapus dari aturan tersebut.'
                                : 'Gejala akan dihapus permanen.',
                          );
                          if (!ok) return;
                          await DatabaseHelper.instance.deleteGejala(g.id);
                          notifyKbChanged();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
