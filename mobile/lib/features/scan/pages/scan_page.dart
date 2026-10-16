import 'dart:async';
import 'dart:io';

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
  bool _chosen = false;
  bool _fresh = false; // true setelah state scan lama dibersihkan

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final c = ref.read(scanControllerProvider.notifier);
      // State provider ini hidup terus; bersihkan sisa scan sebelumnya dulu.
      c.reset();
      if (mounted) setState(() => _fresh = true);
      c.initCamera();
    });
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

  /// User pilih Zoom / Suara setelah foto. History disimpan di background,
  /// halaman hasil langsung dibuka.
  void _choose(OutputMode mode) {
    if (_chosen) return;
    final s = ref.read(scanControllerProvider);
    final text = s.recognizedText;
    if (text == null) return;
    _chosen = true;

    ref.read(scanControllerProvider.notifier).saveHistory(mode);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => mode == OutputMode.zoom
            ? ZoomResultPage(recognizedText: text, capturedImagePath: s.capturedImagePath)
            : TtsResultPage(recognizedText: text, capturedImagePath: s.capturedImagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);
    final state = ref.watch(scanControllerProvider);
    final controller = ref.read(scanControllerProvider.notifier);
    final camera = ref.read(cameraServiceProvider);

    ref.listen(scanControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final captured = _fresh && state.capturedImagePath != null && state.recognizedText != null;

    final cameraController = camera.controller;
    final showPreview = state.isCameraReady &&
        cameraController != null &&
        cameraController.value.isInitialized;

    // Setelah foto: tombol back = ambil ulang, bukan keluar halaman.
    return PopScope(
      canPop: !captured,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && captured) controller.retake();
      },
      child: Scaffold(
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
          t.scanTitle,
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
            onPressed: state.isCameraReady && !captured ? controller.toggleTorch : null,
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
                    onTapUp: showPreview && !captured ? (d) => _handleTapToFocus(d, controller) : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (captured)
                          Image.file(
                            File(state.capturedImagePath!),
                            fit: BoxFit.cover,
                            cacheWidth: 1080,
                          )
                        else if (showPreview)
                          _preview(cameraController)
                        else
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        if (_focusPoint != null && !captured)
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
              captured ? t.chooseResultHint : t.scanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            if (captured)
              // Pilih hasil: icon saja (Zoom / Suara)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ChoiceButton(
                    icon: Icons.zoom_in,
                    tooltip: t.zoom,
                    color: AppColors.primary,
                    onTap: () => _choose(OutputMode.zoom),
                  ),
                  const SizedBox(width: 40),
                  _ChoiceButton(
                    icon: Icons.volume_up,
                    tooltip: t.suara,
                    color: AppColors.secondary,
                    onTap: () => _choose(OutputMode.speech),
                  ),
                ],
              )
            else
              // Tombol capture
              GestureDetector(
                onTap: state.isCameraReady && !state.isProcessing
                    ? controller.captureAndRecognize
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

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              height: 80,
              width: 80,
              child: Icon(icon, color: Colors.white, size: 38),
            ),
          ),
        ),
      ),
    );
  }
}
