import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/format_utils.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<HistoryModel>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppState.instance.historyRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppState.instance.historyRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await DatabaseHelper.instance.getAllHistory();
      if (!mounted) return;
      setState(() {
        _items = data;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat riwayat.');
    }
  }

  Future<void> _deleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Seluruh catatan diagnosis akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseHelper.instance.deleteAllHistory();
    AppState.instance.historyRevision.value++;
  }

  Future<void> _deleteOne(int index) async {
    final item = _items![index];
    setState(() => _items!.removeAt(index)); // hapus dari daftar dulu (syarat Dismissible)
    if (item.id != null) await DatabaseHelper.instance.deleteHistory(item.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat dihapus.')));
  }

  void _showDetail(HistoryModel h) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Detail Diagnosis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Waktu: ${formatTanggal(h.date)}'),
              const SizedBox(height: 6),
              Text('Laptop: ${h.merkLaptop}'),
              const SizedBox(height: 6),
              Text('Hasil: ${h.hasilDiagnosis}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Kecocokan: ${h.matchPercentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 6),
              Text('Gejala: ${h.gejalaTerpilih}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Diagnosis'),
        actions: [
          IconButton(tooltip: 'Muat ulang', icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            tooltip: 'Hapus semua',
            icon: const Icon(Icons.delete_sweep),
            onPressed: (items == null || items.isEmpty) ? null : _deleteAll,
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (_error != null) return Center(child: Text(_error!));
        if (items == null) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Belum ada catatan riwayat.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final log = items[i];
            return Dismissible(
              key: ValueKey(log.id ?? i),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteOne(i),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () => _showDetail(log),
                  leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                  title: Text(log.hasilDiagnosis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Laptop: ${log.merkLaptop}\nGejala: ${log.gejalaTerpilih}\nWaktu: ${formatTanggal(log.date)}',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Chip(
                    label: Text('${log.matchPercentage.toStringAsFixed(0)}%'),
                    backgroundColor: Colors.blue[50],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
