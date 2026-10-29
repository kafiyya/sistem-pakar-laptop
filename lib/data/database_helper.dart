import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';
import 'seed_data.dart';

/// Akses SQLite: tabel history (riwayat) + tabel basis pengetahuan (gejala, kerusakan, rule).
/// Versi 2 menambahkan tabel basis pengetahuan; pengguna versi 1 dimigrasi lewat [onUpgrade]
/// tanpa kehilangan riwayat.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'laptop_expert.db';
  static const _dbVersion = 2;

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createHistory(db);
        await _createKnowledgeTables(db);
        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createKnowledgeTables(db);
          await _seed(db);
        }
      },
    );
  }

  Future<void> _createHistory(Database db) => db.execute('''
    CREATE TABLE history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      merkLaptop TEXT NOT NULL,
      gejalaTerpilih TEXT NOT NULL,
      hasilDiagnosis TEXT NOT NULL,
      matchPercentage REAL NOT NULL
    )''');

  Future<void> _createKnowledgeTables(Database db) async {
    await db.execute('''
      CREATE TABLE gejala (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        bobot REAL NOT NULL DEFAULT 1.0
      )''');
    await db.execute('''
      CREATE TABLE kerusakan (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        solusi TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE rule (
        id TEXT PRIMARY KEY,
        gejala_ids TEXT NOT NULL,
        kerusakan_id TEXT NOT NULL
      )''');
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    for (final g in SeedData.gejala) {
      batch.insert('gejala', g.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final k in SeedData.kerusakan) {
      batch.insert('kerusakan', k.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    for (final r in SeedData.rules) {
      batch.insert('rule', r.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- Basis pengetahuan

  Future<KnowledgeBase> loadKnowledgeBase() async {
    final db = await database;
    final g = await db.query('gejala', orderBy: 'id ASC');
    final k = await db.query('kerusakan', orderBy: 'id ASC');
    final r = await db.query('rule', orderBy: 'id ASC');
    return KnowledgeBase(
      gejala: g.map(Gejala.fromMap).toList(),
      kerusakan: k.map(Kerusakan.fromMap).toList(),
      rules: r.map(Rule.fromMap).toList(),
    );
  }

  /// ID berikutnya, mis. prefix 'G' -> 'G14' (angka tertinggi + 1).
  Future<String> nextId(String table, String prefix) async {
    final db = await database;
    final rows = await db.query(table, columns: ['id']);
    var max = 0;
    for (final row in rows) {
      final n = int.tryParse((row['id'] as String).replaceFirst(prefix, ''));
      if (n != null && n > max) max = n;
    }
    return '$prefix${(max + 1).toString().padLeft(2, '0')}';
  }

  Future<void> insertGejala(Gejala g) async {
    final db = await database;
    await db.insert('gejala', g.toMap());
  }

  Future<void> updateGejala(Gejala g) async {
    final db = await database;
    await db.update('gejala', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  /// Menghapus gejala sekaligus membersihkan referensinya pada aturan;
  /// aturan yang menjadi kosong ikut dihapus.
  Future<void> deleteGejala(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('gejala', where: 'id = ?', whereArgs: [id]);
      final rules = await txn.query('rule');
      for (final row in rules) {
        final rule = Rule.fromMap(row);
        if (!rule.gejalaIds.contains(id)) continue;
        final rest = rule.gejalaIds.where((e) => e != id).toList();
        if (rest.isEmpty) {
          await txn.delete('rule', where: 'id = ?', whereArgs: [rule.id]);
        } else {
          await txn.update('rule', {'gejala_ids': rest.join(',')},
              where: 'id = ?', whereArgs: [rule.id]);
        }
      }
    });
  }

  Future<void> insertKerusakan(Kerusakan k) async {
    final db = await database;
    await db.insert('kerusakan', k.toMap());
  }

  Future<void> updateKerusakan(Kerusakan k) async {
    final db = await database;
    await db.update('kerusakan', k.toMap(), where: 'id = ?', whereArgs: [k.id]);
  }

  /// Menghapus kerusakan beserta seluruh aturan yang menuju kerusakan tersebut.
  Future<void> deleteKerusakan(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('rule', where: 'kerusakan_id = ?', whereArgs: [id]);
      await txn.delete('kerusakan', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> insertRule(Rule r) async {
    final db = await database;
    await db.insert('rule', r.toMap());
  }

  Future<void> updateRule(Rule r) async {
    final db = await database;
    await db.update('rule', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<void> deleteRule(String id) async {
    final db = await database;
    await db.delete('rule', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------- Riwayat

  Future<int> insertHistory(HistoryModel h) async {
    final db = await database;
    return db.insert('history', h.toMap());
  }

  Future<List<HistoryModel>> getAllHistory() async {
    final db = await database;
    final rows = await db.query('history', orderBy: 'id DESC');
    return rows.map(HistoryModel.fromMap).toList();
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllHistory() async {
    final db = await database;
    return db.delete('history');
  }
}
