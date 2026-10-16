import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart'; // Mengimpor helper database sqflite

void main() {
  runApp(const LaptopExpertSystemApp());
}

class LaptopExpertSystemApp extends StatelessWidget {
  const LaptopExpertSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Pakar Laptop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF0D9488),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ==================== MODEL DATA ====================

class Gejala {
  final String id;
  final String nama;
  Gejala({required this.id, required this.nama});
}

class Kerusakan {
  final String id;
  final String nama;
  final String deskripsi;
  final String solusi;
  Kerusakan({required this.id, required this.nama, required this.deskripsi, required this.solusi});
}

class Rule {
  final String id;
  final List<String> requiredGejalaIds;
  final String targetKerusakanId;
  Rule({required this.id, required this.requiredGejalaIds, required this.targetKerusakanId});
}

// ==================== BASIS PENGETAHUAN ====================

class KnowledgeBase {
  static List<Gejala> listGejala = [
    Gejala(id: 'G01', nama: 'Laptop mati total / tidak mau menyala'),
    Gejala(id: 'G02', nama: 'Lampu indikator daya/power mati total'),
    Gejala(id: 'G03', nama: 'Baterai tidak terisi saat charger terhubung'),
    Gejala(id: 'G04', nama: 'Mesin menyala tetapi layar tetap gelap/hitam'),
    Gejala(id: 'G05', nama: 'Terdengar bunyi beeping berulang saat baru dinyalakan'),
    Gejala(id: 'G06', nama: 'Laptop sering mati mendadak atau restart sendiri'),
    Gejala(id: 'G07', nama: 'Suhu bodi laptop terasa sangat panas (Overheating)'),
    Gejala(id: 'G08', nama: 'Kipas pendingin berbunyi sangat bising atau mati'),
    Gejala(id: 'G09', nama: 'Layar bergaris, flickering, atau muncul artifak warna'),
    Gejala(id: 'G10', nama: 'Sistem mengalami Blue Screen (BSOD) / Disk Usage 100%'),
  ];

  static List<Kerusakan> listKerusakan = [
    Kerusakan(
      id: 'K01',
      nama: 'Kerusakan Power Supply / Adapter / Baterai',
      deskripsi: 'Terjadi gangguan pada sirkuit masuk daya utama, konektor charger, atau sel baterai.',
      solusi: '1. Periksa kondisi kabel adapter dan sumber listrik.\n2. Lakukan hard reset baterai.\n3. Lakukan pengujian charger pengganti.',
    ),
    Kerusakan(
      id: 'K02',
      nama: 'Malfungsi Memori Utama (RAM)',
      deskripsi: 'Kegagalan pemuatan BIOS atau instruksi POST akibat modul RAM kotor atau rusak.',
      solusi: '1. Lepas modul RAM dan bersihkan pin emas dengan penghapus pensil.\n2. Coba pasang RAM pada slot alternatif.\n3. Uji dengan modul RAM lain yang normal.',
    ),
    Kerusakan(
      id: 'K03',
      nama: 'Gangguan Termal & Sistem Pendingin',
      deskripsi: 'Prosesor/GPU mencapai ambang panas maksimum akibat pasta termal mengering atau fan tersumbat.',
      solusi: '1. Bersihkan debu pada kipas dan saluran udara heatsink.\n2. Oleskan kembali thermal paste baru pada CPU & GPU.\n3. Gunakan cooling pad tambahan.',
    ),
  ];

  static List<Rule> listRule = [
    Rule(id: 'R01', requiredGejalaIds: ['G01', 'G02', 'G03'], targetKerusakanId: 'K01'),
    Rule(id: 'R02', requiredGejalaIds: ['G01', 'G04', 'G05'], targetKerusakanId: 'K02'),
    Rule(id: 'R03', requiredGejalaIds: ['G06', 'G07', 'G08'], targetKerusakanId: 'K03'),
  ];
}

// ==================== HALAMAN INPUT LAPTOP ====================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _laptopController = TextEditingController();

  void _mulai() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainHomeScreen(laptopName: _laptopController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.laptop_chromebook, size: 100, color: Color(0xFF1E3A8A)),
                const SizedBox(height: 24),
                const Text(
                  "Sistem Pakar Diagnosis Hardware",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _laptopController,
                  decoration: const InputDecoration(
                    labelText: "Masukkan Merk/Tipe Laptop",
                    hintText: "Contoh: Lenovo LOQ, Asus ROG",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Merk laptop wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                    onPressed: _mulai,
                    child: const Text("Masuk ke Aplikasi", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== NAVIGASI UTAMA ====================

class MainHomeScreen extends StatefulWidget {
  final String laptopName;
  const MainHomeScreen({super.key, required this.laptopName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DiagnosisScreen(laptopName: widget.laptopName),
      const KamusHardwareScreen(),
      const RiwayatScreen(),
      const AdminPortalScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), activeIcon: Icon(Icons.build_circle), label: 'Diagnosis'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Kamus'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

// ==================== TAB 1: MENU DIAGNOSIS ====================

class DiagnosisScreen extends StatefulWidget {
  final String laptopName;
  const DiagnosisScreen({super.key, required this.laptopName});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final Set<String> _selectedGejala = {};

  void _processForwardChaining() async {
    if (_selectedGejala.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilihlah setidaknya 1 gejala awal!')));
      return;
    }

    Rule? bestMatchedRule;
    double highestMatchPercentage = 0;

    for (var rule in KnowledgeBase.listRule) {
      int matchedCount = 0;
      for (var requiredId in rule.requiredGejalaIds) {
        if (_selectedGejala.contains(requiredId)) matchedCount++;
      }

      double percentage = (matchedCount / rule.requiredGejalaIds.length) * 100;
      if (percentage > highestMatchPercentage) {
        highestMatchPercentage = percentage;
        bestMatchedRule = rule;
      }
    }

    Kerusakan? resultKerusakan;
    if (bestMatchedRule != null && highestMatchPercentage > 0) {
      resultKerusakan = KnowledgeBase.listKerusakan.firstWhere((k) => k.id == bestMatchedRule!.targetKerusakanId);

      // Simpan riwayat secara permanen ke Database SQLite
      final newHistory = HistoryModel(
        date: DateTime.now().toString().substring(0, 16),
        merkLaptop: widget.laptopName,
        gejalaTerpilih: _selectedGejala.map((id) => KnowledgeBase.listGejala.firstWhere((g) => g.id == id).nama).join(', '),
        hasilDiagnosis: resultKerusakan.nama,
        matchPercentage: highestMatchPercentage,
      );

      await DatabaseHelper.instance.insertHistory(newHistory);
    }

    _showResultDialog(resultKerusakan, highestMatchPercentage);
  }

  void _showResultDialog(Kerusakan? kerusakan, double matchPercentage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: 24, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(kerusakan != null ? Icons.warning_amber_rounded : Icons.help_outline, color: kerusakan != null ? Colors.orange[800] : Colors.blue, size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: Text(kerusakan != null ? 'Hasil Diagnosis Forward Chaining' : 'Tidak Ditemukan Kecocokan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ],
                ),
                Text("Perangkat: ${widget.laptopName}", style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                const Divider(height: 24),
                if (kerusakan != null) ...[
                  Text(kerusakan.nama, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text('Tingkat Akurasi Aturan: ${matchPercentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[900])),
                  ),
                  const SizedBox(height: 12),
                  const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(kerusakan.deskripsi, style: TextStyle(color: Colors.grey[800])),
                  const SizedBox(height: 12),
                  const Text('Instruksi Penanganan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[200]!)),
                    child: Text(kerusakan.solusi, style: TextStyle(color: Colors.green[900], height: 1.4)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Masalah belum terselesaikan?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        const SizedBox(height: 8),
                        const Text("Jika Anda ragu melakukan perbaikan mandiri, sebaiknya bawa laptop ke teknisi profesional.", style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text("Lihat Rekomendasi Servis"),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ServisRekomendasiScreen()));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ] else ...[
                  const Text('Gejala yang Anda pilih belum cocok dengan aturan spesifik pada sistem saat ini.', style: TextStyle(color: Colors.black87)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup Laporan')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis Kerusakan')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 12),
                Expanded(child: Text('Tandai indikasi yang dialami oleh laptop ${widget.laptopName}:', style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A)))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: KnowledgeBase.listGejala.length,
              itemBuilder: (context, index) {
                final gejala = KnowledgeBase.listGejala[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    title: Text('[${gejala.id}] ${gejala.nama}'),
                    value: _selectedGejala.contains(gejala.id),
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGejala.add(gejala.id);
                        } else {
                          _selectedGejala.remove(gejala.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]),
            child: Row(
              children: [
                OutlinedButton(onPressed: () => setState(() => _selectedGejala.clear()), child: const Text('Reset')),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: _processForwardChaining,
                    child: Text('Proses Diagnosis (${_selectedGejala.length})'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HALAMAN REKOMENDASI SERVIS ====================
class ServisRekomendasiScreen extends StatelessWidget {
  const ServisRekomendasiScreen({super.key});

  Future<void> _bukaGoogleMaps(String keyword) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$keyword');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw Exception('Tidak dapat membuka Maps');
  }

  Future<void> _hubungiKontak(String nomor) async {
    final Uri url = Uri.parse('tel:$nomor');
    if (!await launchUrl(url)) throw Exception('Tidak dapat membuka Telepon');
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tempatServis = [
      {"nama": "Good Laptop Suhat", "alamat": "Jl. Soekarno Hatta, Jatimulyo", "kontak": "081234567890", "spesialisasi": "Spesialis Hardware & Reballing Chipset"},
      {"nama": "Dinoyo Computer Service", "alamat": "Jl. MT. Haryono, Dinoyo", "kontak": "085678901234", "spesialisasi": "Servis Ringan, Ganti RAM/SSD, Cleaning"},
      {"nama": "Malang IT Center Sumbersari", "alamat": "Kawasan Sumbersari", "kontak": "081911223344", "spesialisasi": "Mati Total & Ganti Layar LCD"}
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Rekomendasi Servis")),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: tempatServis.length,
        itemBuilder: (context, index) {
          final bengkel = tempatServis[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build_circle, color: Colors.indigo, size: 28),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bengkel["nama"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                  const Divider(),
                  Text("📍 ${bengkel["alamat"]!}"),
                  const SizedBox(height: 4),
                  Text("🛠 Spesialisasi: ${bengkel["spesialisasi"]!}"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text("Maps"),
                        onPressed: () => _bukaGoogleMaps("${bengkel["nama"]} ${bengkel["alamat"]}"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text("Hubungi"),
                        onPressed: () => _hubungiKontak(bengkel["kontak"]!),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== TAB LAINNYA ====================

class KamusHardwareScreen extends StatelessWidget {
  const KamusHardwareScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamus Hardware Laptop')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: KnowledgeBase.listKerusakan.length,
        itemBuilder: (context, index) {
          final item = KnowledgeBase.listKerusakan[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Text(item.id, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ),
              title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Deskripsi Komponen:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(item.deskripsi),
                      const SizedBox(height: 12),
                      const Text('Saran Tindakan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text(item.solusi),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<List<HistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getAllHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Diagnosis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
          )
        ],
      ),
      body: FutureBuilder<List<HistoryModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

          final history = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final log = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.assignment_turned_in, color: Colors.green),
                  title: Text(log.hasilDiagnosis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Laptop: ${log.merkLaptop}\nGejala: ${log.gejalaTerpilih}\nWaktu: ${log.date}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Chip(
                    label: Text('${log.matchPercentage.toStringAsFixed(0)}%'),
                    backgroundColor: Colors.blue[50],
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

class AdminPortalScreen extends StatelessWidget {
  const AdminPortalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portal Knowledge Base Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Aturan Inferensi (Rule Base Matrix)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...KnowledgeBase.listRule.map((rule) {
            final targetKerusakan = KnowledgeBase.listKerusakan.firstWhere((k) => k.id == rule.targetKerusakanId);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Rule ID: ${rule.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)), Text('Target: ${rule.targetKerusakanId}', style: const TextStyle(fontWeight: FontWeight.bold))],
                    ),
                    const SizedBox(height: 4),
                    Text('IF (${rule.requiredGejalaIds.join(' AND ')}) THEN ${targetKerusakan.nama}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}