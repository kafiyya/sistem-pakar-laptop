import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/models.dart';
import '../services/app_state.dart';

/// Memuat basis pengetahuan dari SQLite dan memuat ulang otomatis bila admin mengubahnya.
class KbBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, KnowledgeBase kb) builder;
  const KbBuilder({super.key, required this.builder});

  @override
  State<KbBuilder> createState() => _KbBuilderState();
}

class _KbBuilderState extends State<KbBuilder> {
  late Future<KnowledgeBase> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.loadKnowledgeBase();
    AppState.instance.kbRevision.addListener(_reload);
  }

  @override
  void dispose() {
    AppState.instance.kbRevision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = DatabaseHelper.instance.loadKnowledgeBase());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KnowledgeBase>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat basis pengetahuan.'),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _reload, child: const Text('Coba lagi')),
                ],
              ),
            ),
          );
        }
        return widget.builder(context, snap.data!);
      },
    );
  }
}
