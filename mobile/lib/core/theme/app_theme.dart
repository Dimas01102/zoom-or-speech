import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Oranye aksi utama (Zoom, tombol Google, tombol lanjut)
  static const Color primary = Color(0xFFB5541D);
  static const Color primaryDark = Color(0xFF8A3F14);

  // Hijau tua mode Suara / TTS
  static const Color secondary = Color(0xFF1B4D3E);
  static const Color secondaryDark = Color(0xFF123529);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE6E6E6);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);

  // Palet halaman Scan & Tutorial (sesuai Figma)
  static const Color cream = Color(0xFFFAF7F2);
  static const Color cardBorder = Color(0xFFEDE7DF);
  static const Color orangeSoft = Color(0xFFFDF1E8);
  static const Color orangeBorder = Color(0xFFF1D2BC);
  static const Color greenSoft = Color(0xFFE6F0EB);
  static const Color greenBorder = Color(0xFFC5DDD1);
  static const Color cameraDark = Color(0xFF2B2B2B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.light,
      ),
      // Ukuran teks & target umum
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }
}