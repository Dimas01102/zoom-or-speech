import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Popup "Anda belum Login" untuk fitur yang butuh akun (mis. Riwayat) saat
/// pengguna masuk sebagai Tamu. Tutup dengan tap di luar kotak.
Future<void> showLoginRequiredDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xFFF9E7E0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Color(0xFFF9E7E0), size: 56),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}