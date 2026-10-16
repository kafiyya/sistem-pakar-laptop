import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoryModel {
  final int? id;
  final String date;
  final String merkLaptop;
  final String gejalaTerpilih;
  final String hasilDiagnosis;
  final double matchPercentage;

  HistoryModel({
    this.id,
    required this.date,
    required this.merkLaptop,
    required this.gejalaTerpilih,
    required this.hasilDiagnosis,
    required this.matchPercentage,
  });

  // Konversi dari Map SQLite ke Objek Model
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'],
      date: map['date'],
      merkLaptop: map['merkLaptop'],
      gejalaTerpilih: map['gejalaTerpilih'],
      hasilDiagnosis: map['hasilDiagnosis'],
      matchPercentage: map['matchPercentage'],
    );
  }

  // Konversi dari Objek Model ke Map SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'merkLaptop': merkLaptop,
      'gejalaTerpilih': gejalaTerpilih,
      'hasilDiagnosis': hasilDiagnosis,
      'matchPercentage': matchPercentage,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('laptop_expert.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        merkLaptop TEXT NOT NULL,
        gejalaTerpilih TEXT NOT NULL,
        hasilDiagnosis TEXT NOT NULL,
        matchPercentage REAL NOT NULL
      )
    ''');
  }

  // Masukkan riwayat baru ke database
  Future<int> insertHistory(HistoryModel history) async {
    final db = await instance.database;
    return await db.insert('history', history.toMap());
  }

  // Ambil seluruh riwayat (diurutkan dari yang terbaru)
  Future<List<HistoryModel>> getAllHistory() async {
    final db = await instance.database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((json) => HistoryModel.fromMap(json)).toList();
  }

  // Hapus semua riwayat
  Future<int> deleteAllHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }
}