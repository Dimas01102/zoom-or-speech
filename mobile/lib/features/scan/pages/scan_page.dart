import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../output/pages/tts_result_page.dart';
import '../../output/pages/zoom_result_page.dart';
import '../../output/providers/output_mode_provider.dart';
import '../providers/scan_provider.dart';

/// kamera real-time, flashlight manual (BUKAN otomatis), capture -> OCR.
/// Setelah OCR selesai, teks & path gambar diteruskan ke mode output.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scanControllerProvider.notifier).initCamera());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final camera = ref.read(cameraServiceProvider);

    ref.listen(scanControllerProvider, (previous, next) {
      if (next.recognizedText != null &&
          previous?.recognizedText != next.recognizedText) {
        final mode = ref.read(selectedOutputModeProvider);
        final text = next.recognizedText!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => mode == OutputMode.zoom
                ? ZoomResultPage(
                    recognizedText: text,
                    capturedImagePath: next.capturedImagePath,
                  )
                : TtsResultPage(recognizedText: text),
          ),
        );
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (state.isCameraReady && camera.controller != null)
            CameraPreview(camera.controller!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Tombol kembali
          Positioned(
            top: 16,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),

          // Tombol flashlight manual, hanya berubah saat ditekan pengguna.
          Positioned(
            top: 16,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  state.isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: state.isCameraReady ? controller.toggleTorch : null,
              ),
            ),
          ),

          // Tombol capture, di bawah tengah sesuai mockup.
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: state.isCameraReady && !state.isProcessing
                    ? () => controller.captureAndRecognize(
                          ref.read(selectedOutputModeProvider),
                        )
                    : null,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white70, width: 4),
                  ),
                  child: state.isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(cameraServiceProvider).dispose();
    super.dispose();
  }
}