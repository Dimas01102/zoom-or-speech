import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart' show Offset;

class CameraService {
  CameraController? _controller;
  bool _isTorchOn = false;
  DateTime? _lastManualFocusAt;

  CameraController? get controller => _controller;
  bool get isTorchOn => _isTorchOn;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller!.initialize();
    try {
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (_) {
      
    }
  }

  Future<void> toggleTorch() async {
    if (_controller == null || !isInitialized) return;
    _isTorchOn = !_isTorchOn;
    await _controller!.setFlashMode(
      _isTorchOn ? FlashMode.torch : FlashMode.off,
    );
  }

  /// [point] relatif 0.0-1.0 terhadap area preview (bukan pixel layar).
  /// Dipanggil saat user tap layar utk fokus manual ke bagian teks tertentu.
  Future<void> focusAndExposeAt(Offset point) async {
    if (_controller == null || !isInitialized) return;
    try {
      await _controller!.setFocusPoint(point);
      await _controller!.setExposurePoint(point);
      _lastManualFocusAt = DateTime.now();
    } catch (_) {

    }
  }

  Future<XFile> takePicture() async {
    if (_controller == null || !isInitialized) {
      throw StateError('Kamera belum diinisialisasi.');
    }

    final lastFocus = _lastManualFocusAt;
    if (lastFocus != null) {
      final sinceFocus = DateTime.now().difference(lastFocus);
      if (sinceFocus < const Duration(milliseconds: 800)) {
        await Future.delayed(const Duration(milliseconds: 250) - sinceFocus);
      }
    }

    return _controller!.takePicture();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}