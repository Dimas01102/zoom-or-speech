import 'package:camera/camera.dart';

/// Flashlight manual (tombol on/off)
class CameraService {
  CameraController? _controller;
  bool _isTorchOn = false;

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
      // Sebagian device/kamera nggak dukung mode ini aman jika diabaikan.
    }
  }

  Future<void> toggleTorch() async {
    if (_controller == null || !isInitialized) return;
    _isTorchOn = !_isTorchOn;
    await _controller!.setFlashMode(
      _isTorchOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<XFile> takePicture() async {
    if (_controller == null || !isInitialized) {
      throw StateError('Kamera belum diinisialisasi.');
    }
    return _controller!.takePicture();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}