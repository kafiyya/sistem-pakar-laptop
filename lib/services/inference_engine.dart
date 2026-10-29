import '../models/models.dart';

/// Mesin inferensi Forward Chaining (data-driven) dengan pencocokan berbobot.
///
/// Fakta awal (working memory) = gejala yang dipilih/dijawab "Ya" pengguna.
/// Setiap aturan dievaluasi TEPAT SATU KALI (satu pass atas daftar aturan),
/// sehingga proses selalu berhenti (bebas logical loop): O(jumlah aturan).
/// Aturan dengan kecocokan 100% = terpicu penuh; aturan dengan kecocokan
/// >= [defaultThreshold] dianggap kandidat (metode hibrida, sesuai Tahap 1).
class InferenceEngine {
  static const double defaultThreshold = 60;

  static double _w(KnowledgeBase kb, String gejalaId) =>
      kb.gejalaById(gejalaId)?.bobot ?? 1.0;

  /// Mengembalikan kandidat kerusakan, diurutkan dari kecocokan tertinggi.
  /// Satu kerusakan hanya muncul sekali (diambil aturan dengan skor tertinggi).
  static List<DiagnosisResult> diagnose(
      KnowledgeBase kb,
      Set<String> facts, {
        double threshold = defaultThreshold,
      }) {
    final best = <String, DiagnosisResult>{};

    for (final rule in kb.rules) {
      if (rule.gejalaIds.isEmpty) continue;
      final kerusakan = kb.kerusakanById(rule.kerusakanId);
      if (kerusakan == null) continue;

      double total = 0, matchedW = 0;
      final matched = <String>[], missing = <String>[];
      for (final gid in rule.gejalaIds) {
        final w = _w(kb, gid);
        total += w;
        if (facts.contains(gid)) {
          matchedW += w;
          matched.add(gid);
        } else {
          missing.add(gid);
        }
      }
      if (total <= 0) continue;
      final pct = matchedW / total * 100;
      if (pct < threshold || matched.isEmpty) continue;

      final cand = DiagnosisResult(
        rule: rule,
        kerusakan: kerusakan,
        percent: pct,
        matchedIds: matched,
        missingIds: missing,
      );
      final old = best[kerusakan.id];
      if (old == null || cand.percent > old.percent) best[kerusakan.id] = cand;
    }

    final list = best.values.toList()
      ..sort((a, b) {
        final c = b.percent.compareTo(a.percent);
        if (c != 0) return c;
        final m = b.matchedIds.length.compareTo(a.matchedIds.length);
        if (m != 0) return m;
        return a.kerusakan.id.compareTo(b.kerusakan.id);
      });
    return list;
  }

  /// Apakah aturan masih mungkin mencapai [threshold] bila gejala yang belum
  /// dijawab ternyata "Ya" (dipakai mode tanya-jawab untuk memangkas pertanyaan).
  static bool isRuleViable(
      KnowledgeBase kb,
      Rule rule,
      Map<String, bool> answers, {
        double threshold = defaultThreshold,
      }) {
    double total = 0, achievable = 0;
    for (final gid in rule.gejalaIds) {
      final w = _w(kb, gid);
      total += w;
      if (answers[gid] != false) achievable += w;
    }
    if (total <= 0) return false;
    return achievable / total * 100 >= threshold;
  }

  /// Pertanyaan berikutnya pada mode tanya-jawab, atau null bila sudah selesai.
  /// Gejala yang hanya muncul pada aturan yang sudah tidak mungkin terpenuhi
  /// dilewati. Tiap gejala ditanyakan maksimal sekali sehingga pasti berhenti.
  static Gejala? nextQuestion(
      KnowledgeBase kb,
      Map<String, bool> answers, {
        double threshold = defaultThreshold,
      }) {
    final viable = kb.rules
        .where((r) => isRuleViable(kb, r, answers, threshold: threshold))
        .toList();
    for (final g in kb.gejala) {
      if (answers.containsKey(g.id)) continue;
      if (viable.any((r) => r.gejalaIds.contains(g.id))) return g;
    }
    return null;
  }

  /// Fakta = gejala yang dijawab "Ya".
  static Set<String> factsFromAnswers(Map<String, bool> answers) =>
      {for (final e in answers.entries) if (e.value) e.key};
}
