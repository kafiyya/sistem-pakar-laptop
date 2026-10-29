import 'package:flutter/foundation.dart';

/// Penanda perubahan data lintas layar (tanpa package state management tambahan).
/// Layar yang mendengarkan akan memuat ulang datanya ketika nilainya naik.
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  /// Naik setiap kali basis pengetahuan (gejala/kerusakan/aturan) berubah.
  final ValueNotifier<int> kbRevision = ValueNotifier<int>(0);

  /// Naik setiap kali riwayat berubah (tambah/hapus).
  final ValueNotifier<int> historyRevision = ValueNotifier<int>(0);
}
