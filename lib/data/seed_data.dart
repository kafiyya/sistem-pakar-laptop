import '../models/models.dart';

/// Data awal basis pengetahuan. Dimasukkan ke SQLite saat database pertama dibuat;
/// selanjutnya pakar/admin mengelolanya lewat Portal Admin (tanpa mengubah kode).
class SeedData {
  static const List<Gejala> gejala = [
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
    Gejala(id: 'G11', nama: 'Tampilan di monitor eksternal normal, hanya layar laptop yang bermasalah'),
    Gejala(id: 'G12', nama: 'Proses booting sangat lama atau aplikasi sering tidak merespons'),
    Gejala(id: 'G13', nama: 'Muncul pesan "No bootable device" atau file hilang/korup'),
  ];

  static const List<Kerusakan> kerusakan = [
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
    Kerusakan(
      id: 'K04',
      nama: 'Kerusakan Layar / Kabel Fleksibel / GPU',
      deskripsi: 'Panel LCD, kabel fleksibel (flexible cable) layar, atau chip grafis mengalami gangguan sehingga tampilan tidak normal.',
      solusi: '1. Hubungkan ke monitor eksternal untuk memastikan sumber masalah.\n2. Periksa dan pasang ulang kabel fleksibel layar.\n3. Bawa ke teknisi untuk penggantian panel atau reballing GPU.',
    ),
    Kerusakan(
      id: 'K05',
      nama: 'Gangguan Penyimpanan (HDD/SSD) & Sistem Operasi',
      deskripsi: 'Media penyimpanan memiliki bad sector/menuju rusak, atau berkas sistem operasi korup sehingga sistem tidak stabil.',
      solusi: '1. Cadangkan data penting segera.\n2. Jalankan pemeriksaan disk (CHKDSK / SMART).\n3. Instal ulang sistem operasi atau ganti HDD/SSD bila bad sector bertambah.',
    ),
  ];

  static const List<Rule> rules = [
    Rule(id: 'R01', gejalaIds: ['G01', 'G02', 'G03'], kerusakanId: 'K01'),
    Rule(id: 'R02', gejalaIds: ['G01', 'G04', 'G05'], kerusakanId: 'K02'),
    Rule(id: 'R03', gejalaIds: ['G06', 'G07', 'G08'], kerusakanId: 'K03'),
    Rule(id: 'R04', gejalaIds: ['G04', 'G09', 'G11'], kerusakanId: 'K04'),
    Rule(id: 'R05', gejalaIds: ['G10', 'G12', 'G13'], kerusakanId: 'K05'),
    Rule(id: 'R06', gejalaIds: ['G05', 'G06', 'G10'], kerusakanId: 'K02'),
  ];
}
