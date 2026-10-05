import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../output/pages/tts_result_page.dart';
import '../../output/pages/zoom_result_page.dart';
import '../../output/providers/output_mode_provider.dart';
import '../providers/scan_provider.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final GlobalKey _previewAreaKey = GlobalKey();
  Offset? _focusPoint;
  Timer? _focusIndicatorTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scanControllerProvider.notifier).initCamera());
  }

  /// Preview kamera dipotong mengisi kartu (cover)
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

  /// Tap di area kamera utk fokus manual ke titik itu (mis. tepat ke tulisan).
  void _handleTapToFocus(TapUpDetails details, ScanController controller) {
    final box = _previewAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final local = box.globalToLocal(details.globalPosition);
    final relative = Offset(
      (local.dx / box.size.width).clamp(0.0, 1.0),
      (local.dy / box.size.height).clamp(0.0, 1.0),
    );

    controller.focusAt(relative);

    setState(() => _focusPoint = local);
    _focusIndicatorTimer?.cancel();
    _focusIndicatorTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final camera = ref.read(cameraServiceProvider);
    final mode = ref.watch(selectedOutputModeProvider);

    ref.listen(scanControllerProvider, (previous, next) {
      final text = next.recognizedText;
      if (text != null && previous?.recognizedText != text) {
        final outputMode = ref.read(selectedOutputModeProvider);
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
                  key: _previewAreaKey,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cameraDark,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: showPreview ? (d) => _handleTapToFocus(d, controller) : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (showPreview)
                          _preview(cameraController)
                        else
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        if (_focusPoint != null)
                          Positioned(
                            left: _focusPoint!.dx - 24,
                            top: _focusPoint!.dy - 24,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 150),
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
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
            // Tombol capture
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
    _focusIndicatorTimer?.cancel();
    ref.read(cameraServiceProvider).dispose();
    super.dispose();
  }
}