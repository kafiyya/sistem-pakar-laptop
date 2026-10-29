import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/models.dart';
import '../../widgets/kb_builder.dart';
import 'admin_common.dart';

class KerusakanAdminTab extends StatelessWidget {
  const KerusakanAdminTab({super.key});

  Future<void> _form(BuildContext context, {Kerusakan? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nama = TextEditingController(text: existing?.nama ?? '');
    final deskripsi = TextEditingController(text: existing?.deskripsi ?? '');
    final solusi = TextEditingController(text: existing?.solusi ?? '');

    String? required(String? v, String label) =>
        (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'Tambah Kerusakan' : 'Ubah Kerusakan ${existing.id}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama kerusakan'),
                  validator: (v) => required(v, 'Nama'),
                ),
                TextFormField(
                  controller: deskripsi,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  validator: (v) => required(v, 'Deskripsi'),
                ),
                TextFormField(
                  controller: solusi,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Solusi (satu langkah per baris)'),
                  validator: (v) => required(v, 'Solusi'),
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

    final n = nama.text.trim(), d = deskripsi.text.trim(), s = solusi.text.trim();
    nama.dispose();
    deskripsi.dispose();
    solusi.dispose();
    if (ok != true || !context.mounted) return;

    try {
      if (existing == null) {
        final id = await DatabaseHelper.instance.nextId('kerusakan', 'K');
        await DatabaseHelper.instance
            .insertKerusakan(Kerusakan(id: id, nama: n, deskripsi: d, solusi: s));
      } else {
        await DatabaseHelper.instance
            .updateKerusakan(Kerusakan(id: existing.id, nama: n, deskripsi: d, solusi: s));
      }
      notifyKbChanged();
    } catch (_) {
      if (context.mounted) showMsg(context, 'Gagal menyimpan kerusakan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context),
        icon: const Icon(Icons.add),
        label: const Text('Kerusakan'),
      ),
      body: KbBuilder(
        builder: (context, kb) {
          if (kb.kerusakan.isEmpty) return const Center(child: Text('Belum ada kerusakan.'));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: kb.kerusakan.length,
            itemBuilder: (context, i) {
              final k = kb.kerusakan[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(k.id, style: const TextStyle(fontSize: 11))),
                  title: Text(k.nama),
                  subtitle: Text(k.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _form(context, existing: k)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final used = kb.rules.where((r) => r.kerusakanId == k.id).length;
                          final ok = await confirmDelete(
                            context,
                            'Hapus ${k.id}?',
                            used > 0
                                ? '$used aturan yang menuju kerusakan ini juga akan dihapus.'
                                : 'Kerusakan akan dihapus permanen.',
                          );
                          if (!ok) return;
                          await DatabaseHelper.instance.deleteKerusakan(k.id);
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
