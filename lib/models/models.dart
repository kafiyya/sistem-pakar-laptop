/// Model data aplikasi Sistem Pakar Diagnosis Hardware Laptop.
/// File ini murni Dart (tanpa dependensi Flutter) sehingga bisa diuji unit.

class Gejala {
  final String id;
  final String nama;

  /// Bobot gejala (0.1 - 5.0). Gejala yang lebih menentukan diberi bobot lebih besar.
  final double bobot;

  const Gejala({required this.id, required this.nama, this.bobot = 1.0});

  factory Gejala.fromMap(Map<String, Object?> m) => Gejala(
    id: m['id'] as String,
    nama: m['nama'] as String,
    bobot: (m['bobot'] as num?)?.toDouble() ?? 1.0,
  );

  Map<String, Object?> toMap() => {'id': id, 'nama': nama, 'bobot': bobot};
}

class Kerusakan {
  final String id;
  final String nama;
  final String deskripsi;
  final String solusi;

  const Kerusakan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.solusi,
  });

  factory Kerusakan.fromMap(Map<String, Object?> m) => Kerusakan(
    id: m['id'] as String,
    nama: m['nama'] as String,
    deskripsi: m['deskripsi'] as String,
    solusi: m['solusi'] as String,
  );

  Map<String, Object?> toMap() =>
      {'id': id, 'nama': nama, 'deskripsi': deskripsi, 'solusi': solusi};
}

/// Aturan: IF (semua gejala) THEN kerusakan.
class Rule {
  final String id;
  final List<String> gejalaIds;
  final String kerusakanId;

  const Rule({required this.id, required this.gejalaIds, required this.kerusakanId});

  factory Rule.fromMap(Map<String, Object?> m) => Rule(
    id: m['id'] as String,
    gejalaIds: (m['gejala_ids'] as String)
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(),
    kerusakanId: m['kerusakan_id'] as String,
  );

  Map<String, Object?> toMap() =>
      {'id': id, 'gejala_ids': gejalaIds.join(','), 'kerusakan_id': kerusakanId};
}

/// Snapshot basis pengetahuan (gejala + kerusakan + aturan).
class KnowledgeBase {
  final List<Gejala> gejala;
  final List<Kerusakan> kerusakan;
  final List<Rule> rules;

  const KnowledgeBase({
    required this.gejala,
    required this.kerusakan,
    required this.rules,
  });

  Gejala? gejalaById(String id) {
    for (final g in gejala) {
      if (g.id == id) return g;
    }
    return null;
  }

  Kerusakan? kerusakanById(String id) {
    for (final k in kerusakan) {
      if (k.id == id) return k;
    }
    return null;
  }
}

/// Satu kandidat hasil diagnosis.
class DiagnosisResult {
  final Rule rule;
  final Kerusakan kerusakan;

  /// Persentase kecocokan berbobot (0 - 100).
  final double percent;
  final List<String> matchedIds;
  final List<String> missingIds;

  const DiagnosisResult({
    required this.rule,
    required this.kerusakan,
    required this.percent,
    required this.matchedIds,
    required this.missingIds,
  });

  bool get isFullMatch => missingIds.isEmpty;
}

class HistoryModel {
  final int? id;
  final String date; // ISO-8601
  final String merkLaptop;
  final String gejalaTerpilih;
  final String hasilDiagnosis;
  final double matchPercentage;

  const HistoryModel({
    this.id,
    required this.date,
    required this.merkLaptop,
    required this.gejalaTerpilih,
    required this.hasilDiagnosis,
    required this.matchPercentage,
  });

  factory HistoryModel.fromMap(Map<String, Object?> m) => HistoryModel(
    id: m['id'] as int?,
    date: m['date'] as String,
    merkLaptop: m['merkLaptop'] as String,
    gejalaTerpilih: m['gejalaTerpilih'] as String,
    hasilDiagnosis: m['hasilDiagnosis'] as String,
    matchPercentage: (m['matchPercentage'] as num).toDouble(),
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'merkLaptop': merkLaptop,
    'gejalaTerpilih': gejalaTerpilih,
    'hasilDiagnosis': hasilDiagnosis,
    'matchPercentage': matchPercentage,
  };
}
