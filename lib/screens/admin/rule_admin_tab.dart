import 'package:flutter/material.dart';

import '../../data/database_helper.dart';
import '../../models/models.dart';
import '../../widgets/kb_builder.dart';
import 'admin_common.dart';

class RuleAdminTab extends StatelessWidget {
  const RuleAdminTab({super.key});

  Future<void> _form(BuildContext context, KnowledgeBase kb, {Rule? existing}) async {
    if (kb.gejala.isEmpty || kb.kerusakan.isEmpty) {
      showMsg(context, 'Tambahkan gejala dan kerusakan terlebih dahulu.');
      return;
    }
    String? kerusakanId = existing?.kerusakanId;
    final selected = <String>{...?existing?.gejalaIds};
    String? error;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Tambah Aturan' : 'Ubah Aturan ${existing.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: kerusakanId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'THEN (kerusakan)'),
                    items: kb.kerusakan
                        .map((k) => DropdownMenuItem(value: k.id, child: Text('${k.id} - ${k.nama}', overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setLocal(() => kerusakanId = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('IF (semua gejala berikut):', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...kb.gejala.map((g) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text('[${g.id}] ${g.nama}', style: const TextStyle(fontSize: 13)),
                    value: selected.contains(g.id),
                    onChanged: (v) => setLocal(() {
                      if (v == true) {
                        selected.add(g.id);
                      } else {
                        selected.remove(g.id);
                      }
                    }),
                  )),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (kerusakanId == null) {
                  setLocal(() => error = 'Pilih kerusakan tujuan.');
                } else if (selected.length < 2) {
                  setLocal(() => error = 'Pilih minimal 2 gejala.');
                } else {
                  final dup = kb.rules.any((r) =>
                  r.id != existing?.id &&
                      r.kerusakanId == kerusakanId &&
                      r.gejalaIds.length == selected.length &&
                      r.gejalaIds.toSet().containsAll(selected));
                  if (dup) {
                    setLocal(() => error = 'Aturan yang sama sudah ada.');
                  } else {
                    Navigator.pop(c, true);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !context.mounted) return;
    // Pertahankan urutan ID gejala sesuai daftar.
    final ids = kb.gejala.map((g) => g.id).where(selected.contains).toList();
    try {
      if (existing == null) {
        final id = await DatabaseHelper.instance.nextId('rule', 'R');
        await DatabaseHelper.instance.insertRule(Rule(id: id, gejalaIds: ids, kerusakanId: kerusakanId!));
      } else {
        await DatabaseHelper.instance
            .updateRule(Rule(id: existing.id, gejalaIds: ids, kerusakanId: kerusakanId!));
      }
      notifyKbChanged();
    } catch (_) {
      if (context.mounted) showMsg(context, 'Gagal menyimpan aturan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KbBuilder(
      builder: (context, kb) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _form(context, kb),
          icon: const Icon(Icons.add),
          label: const Text('Aturan'),
        ),
        body: kb.rules.isEmpty
            ? const Center(child: Text('Belum ada aturan.'))
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: kb.rules.length,
          itemBuilder: (context, i) {
            final r = kb.rules[i];
            final target = kb.kerusakanById(r.kerusakanId);
            return Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.id}  →  ${r.kerusakanId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const SizedBox(height: 4),
                          Text('IF (${r.gejalaIds.join(' AND ')}) THEN ${target?.nama ?? '(kerusakan dihapus)'}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _form(context, kb, existing: r)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await confirmDelete(context, 'Hapus ${r.id}?', 'Aturan akan dihapus permanen.');
                        if (!ok) return;
                        await DatabaseHelper.instance.deleteRule(r.id);
                        notifyKbChanged();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
