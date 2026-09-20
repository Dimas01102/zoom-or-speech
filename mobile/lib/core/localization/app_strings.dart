import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_provider.dart';

class AppStrings {
  const AppStrings(this.lang);

  final String lang; // 'id' | 'en'
  bool get _en => lang == 'en';

  String get appName => 'JELAS';
  String get tagline => _en ? 'Read any text with ease' : 'Baca teks apa pun dengan mudah';

  // Login
  String get loginWithGoogle => _en ? 'Sign in with Google' : 'Masuk dengan Google';
  String get continueAsGuest => _en ? 'Continue as Guest' : 'Lanjutkan sebagai Tamu';

  // Onboarding
  String get skip => _en ? 'Skip' : 'Lewati';
  String get next => _en ? 'Next' : 'Lanjut';
  String get start => _en ? 'Get Started' : 'Mulai';

  // Home
  String get homeHeadline => _en ? 'How do you want to read the text?' : 'Mau baca teks dengan cara apa?';
  String get homeSubtitle => _en
      ? 'Pick one, then point the camera at the text you want to read.'
      : 'Pilih salah satu, lalu arahkan kamera ke teks yang mau dibaca.';
  String get zoom => _en ? 'Zoom' : 'Zoom';
  String get zoomDesc => _en ? 'Enlarge the scanned text on screen.' : 'Perbesar teks hasil scan di layar.';
  String get suara => _en ? 'Voice' : 'Suara';
  String get suaraDesc =>
      _en ? 'Listen to the scanned text read aloud.' : 'Dengarkan teks hasil scan dibacakan.';

  // Nav
  String get navHome => _en ? 'Home' : 'Beranda';
  String get navHistory => _en ? 'History' : 'Riwayat';
  String get navSettings => _en ? 'Settings' : 'Pengaturan';

  // Tutorial
  String get tutorial => _en ? 'Tutorial' : 'Tutorial';
  String get tutorialEmpty => _en ? 'No tutorial content yet.' : 'Belum ada konten tutorial.';

  // History
  String get historyEmpty => _en ? 'No scan history yet.' : 'Belum ada riwayat pemindaian.';
  String get select => _en ? 'Select' : 'Pilih';
  String get selectAll => _en ? 'Select All' : 'Pilih Semua';
  String get delete => _en ? 'Delete' : 'Hapus';
  String get deleteConfirmTitle => _en ? 'Delete history?' : 'Hapus riwayat?';
  String deleteConfirmBody(int count) => _en
      ? 'Delete $count selected item(s)? This cannot be undone.'
      : 'Hapus $count item terpilih? Tindakan ini tidak bisa dibatalkan.';
  String get cancel => _en ? 'Cancel' : 'Batal';

  // Settings
  String get settingsTitle => _en ? 'Settings' : 'Pengaturan';
  String get language => _en ? 'Language' : 'Bahasa';
  String get indonesian => _en ? 'Indonesian' : 'Indonesia';
  String get english => _en ? 'English' : 'Inggris';
  String get speechSpeed => _en ? 'Voice Speed' : 'Kecepatan Suara';
  String get speechSpeedDesc =>
      _en ? 'Controls the reading speed in Voice mode.' : 'Mengatur kecepatan pembacaan teks di mode Suara.';
  String get logout => _en ? 'Log Out' : 'Keluar';
  String get logoutConfirmBody => _en ? 'Are you sure you want to log out?' : 'Yakin mau keluar dari akun ini?';

  // Scan mode picker sheet
  String get chooseModeTitle => _en ? 'How do you want to read the text?' : 'Mau baca teks dengan cara apa?';
}

final appStringsProvider = Provider<AppStrings>((ref) {
  final bahasa = ref.watch(settingsControllerProvider).bahasa;
  return AppStrings(bahasa);
});