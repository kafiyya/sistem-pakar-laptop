/// Memformat tanggal ISO-8601 (atau format lama "yyyy-MM-dd HH:mm") menjadi "dd/MM/yyyy HH:mm".
String formatTanggal(String raw) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
