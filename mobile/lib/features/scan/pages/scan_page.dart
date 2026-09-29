import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../output/pages/tts_result_page.dart';
import '../../output/pages/zoom_result_page.dart';
import '../../output/providers/output_mode_provider.dart';
import '../providers/scan_provider.dart';

/// kamera real-time, flashlight manual capture -> OCR.
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

  /// Preview kamera dipotong mengisi kartu (cover), tanpa gepeng.
  Widget _preview(CameraController c) {
    final size = c.value.previewSize;
    if (size == null) return CameraPreview(c);
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final camera = ref.read(cameraServiceProvider);
    final mode = ref.watch(selectedOutputModeProvider);

    ref.listen(scanControllerProvider, (previous, next) {
      if (next.recognizedText != null &&
          previous?.recognizedText != next.recognizedText) {
        final outputMode = ref.read(selectedOutputModeProvider);
        final text = next.recognizedText!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => outputMode == OutputMode.zoom
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

    final cameraController = camera.controller;
    final showPreview = state.isCameraReady &&
        cameraController != null &&
        cameraController.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          mode == OutputMode.zoom ? t.scanTitleZoom : t.scanTitleSpeech,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Flashlight manual, hanya berubah saat ditekan pengguna.
          IconButton(
            icon: Icon(state.isTorchOn ? Icons.flash_on : Icons.flash_off),
            color: AppColors.textPrimary,
            onPressed: state.isCameraReady ? controller.toggleTorch : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cameraDark,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (showPreview)
                        _preview(cameraController!)
                      else
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.78,
                          child: AspectRatio(
                            aspectRatio: 1.1,
                            child: CustomPaint(
                              painter: _DashedRRectPainter(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.scanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Tombol capture, di bawah tengah sesuai desain.
            GestureDetector(
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
                  color: AppColors.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: state.isProcessing
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ref.read(cameraServiceProvider).dispose();
    super.dispose();
  }
}

/// Bingkai putus-putus berujung membulat di tengah kartu kamera.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    this.radius = 24,
    this.dash = 8,
    this.gap = 7,
    this.strokeWidth = 1.8,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}