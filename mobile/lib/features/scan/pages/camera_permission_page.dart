import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import 'scan_page.dart';

/// permission kamera
class CameraPermissionPage extends StatefulWidget {
  const CameraPermissionPage({super.key});

  @override
  State<CameraPermissionPage> createState() => _CameraPermissionPageState();
}

class _CameraPermissionPageState extends State<CameraPermissionPage> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  /// Kalau kamera sudah pernah diizinkan sebelumnya, langsung lompat ke
  /// ScanPage tanpa nampilin halaman "Izinkan Akses" ini lagi.
  Future<void> _checkExistingPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    if (status.isGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScanPage()),
      );
    } else {
      setState(() => _checking = false);
    }
  }

  Future<void> _requestAndContinue(BuildContext context) async {
    final status = await Permission.camera.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScanPage()),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin kamera ditolak permanen aktifkan lewat Pengaturan HP.'),
        ),
      );
      await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin kamera dibutuhkan untuk memindai teks.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Izinkan Akses Kamera',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi butuh akses kamera untuk memindai dan membacakan teks di sekitarmu.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _requestAndContinue(context),
                child: const Text('Izinkan Akses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}