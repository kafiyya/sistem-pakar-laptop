import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/inference_engine.dart';
import '../widgets/kb_builder.dart';
import 'result_sheet.dart';
import 'welcome_screen.dart';

class DiagnosisScreen extends StatelessWidget {
  final String laptopName;
  const DiagnosisScreen({super.key, required this.laptopName});

  @override
  Widget build(BuildContext context) {
    // ObjectKey(kb): saat admin mengubah basis pengetahuan, state diagnosis di-reset.
    return KbBuilder(
      builder: (context, kb) => _DiagnosisBody(key: ObjectKey(kb), kb: kb, laptopName: laptopName),
    );
  }
}

class _DiagnosisBody extends StatefulWidget {
  final KnowledgeBase kb;
  final String laptopName;
  const _DiagnosisBody({super.key, required this.kb, required this.laptopName});

  @override
  State<_DiagnosisBody> createState() => _DiagnosisBodyState();
}

class _DiagnosisBodyState extends State<_DiagnosisBody> {
  bool _qaMode = false; // false = checklist, true = tanya-jawab
  final Set<String> _selected = {};
  final Map<String, bool> _answers = {};
  final List<String> _askedOrder = [];
  String _query = '';
  bool _busy = false;

  KnowledgeBase get kb => widget.kb;

  Future<void> _run(Set<String> facts, {bool allowEmpty = false, bool save = true}) async {
    if (facts.isEmpty && !allowEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilihlah setidaknya 1 gejala awal!')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    final results = InferenceEngine.diagnose(kb, facts);
    var saveFailed = false;
    if (save) {
      try {
        final top = results.isEmpty ? null : results.first;
        await DatabaseHelper.instance.insertHistory(HistoryModel(
          date: DateTime.now().toIso8601String(),
          merkLaptop: widget.laptopName,
          gejalaTerpilih: facts.isEmpty
              ? '(tidak ada gejala dipilih)'
              : facts.map((id) => kb.gejalaById(id)?.nama ?? id).join(', '),
          hasilDiagnosis: top?.kerusakan.nama ?? 'Tidak ditemukan kecocokan',
          matchPercentage: top?.percent ?? 0,
        ));
        AppState.instance.historyRevision.value++;
      } catch (_) {
        saveFailed = true;
      }
    }

    if (!mounted) return;
    setState(() => _busy = false);
    if (saveFailed) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Hasil tampil, tetapi riwayat gagal disimpan.')),
      );
    }
    await showResultSheet(context, widget.laptopName, results);
  }

  // ----------------------------------------------------------- Mode tanya-jawab

  void _answer(Gejala g, bool yes) {
    setState(() {
      _answers[g.id] = yes;
      _askedOrder.add(g.id);
    });
    if (InferenceEngine.nextQuestion(kb, _answers) == null) {
      _run(InferenceEngine.factsFromAnswers(_answers), allowEmpty: true);
    }
  }

  void _undo() {
    if (_askedOrder.isEmpty) return;
    setState(() => _answers.remove(_askedOrder.removeLast()));
  }

  void _restartQa() => setState(() {
    _answers.clear();
    _askedOrder.clear();
  });

  Widget _buildQa() {
    if (kb.gejala.isEmpty || kb.rules.isEmpty) {
      return const Center(child: Text('Basis pengetahuan masih kosong. Hubungi admin.'));
    }
    final next = InferenceEngine.nextQuestion(kb, _answers);
    final answered = _askedOrder.length;

    if (next == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 12),
              const Text('Semua pertanyaan telah dijawab.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _run(InferenceEngine.factsFromAnswers(_answers), allowEmpty: true, save: false),
                child: const Text('Lihat Hasil Lagi'),
              ),
              TextButton(onPressed: _restartQa, child: const Text('Ulangi Diagnosis')),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pertanyaan ${answered + 1}', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('[${next.id}]', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    'Apakah laptop Anda mengalami:\n"${next.nama}"?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _answer(next, false),
                    child: const Text('Tidak', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _busy ? null : () => _answer(next, true),
                    child: const Text('Ya', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _askedOrder.isEmpty ? null : _undo,
                icon: const Icon(Icons.undo),
                label: const Text('Kembali'),
              ),
              TextButton(onPressed: answered == 0 ? null : _restartQa, child: const Text('Mulai Ulang')),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- Mode checklist

  Future<void> _confirmReset() async {
    if (_selected.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset pilihan?'),
        content: Text('${_selected.length} gejala yang dipilih akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && mounted) setState(_selected.clear);
  }

  Widget _buildChecklist() {
    final q = _query.trim().toLowerCase();
    final items = kb.gejala
        .where((g) => q.isEmpty || g.nama.toLowerCase().contains(q) || g.id.toLowerCase().contains(q))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Cari gejala...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Gejala tidak ditemukan.'))
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final g = items[i];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  title: Text('[${g.id}] ${g.nama}'),
                  value: _selected.contains(g.id),
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(g.id);
                    } else {
                      _selected.remove(g.id);
                    }
                  }),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                OutlinedButton(onPressed: _confirmReset, child: const Text('Reset')),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _busy ? null : () => _run(Set<String>.from(_selected)),
                    child: Text('Proses Diagnosis (${_selected.length})'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Kerusakan'),
        actions: [
          IconButton(
            tooltip: 'Ganti perangkat',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => WelcomeScreen(initialName: widget.laptopName)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _qaMode
                            ? 'Jawab pertanyaan untuk laptop ${widget.laptopName}.'
                            : 'Tandai indikasi yang dialami oleh laptop ${widget.laptopName}:',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Checklist'), icon: Icon(Icons.checklist)),
                    ButtonSegment(value: true, label: Text('Tanya-Jawab'), icon: Icon(Icons.question_answer)),
                  ],
                  selected: {_qaMode},
                  onSelectionChanged: (s) => setState(() => _qaMode = s.first),
                ),
              ],
            ),
          ),
          Expanded(child: _qaMode ? _buildQa() : _buildChecklist()),
        ],
      ),
    );
  }
}
