import 'package:camera/camera.dart' show XFile;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show Offset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/repositories/api_repository.dart';
import '../../../data/services/camera_service.dart';
import '../../../data/services/image_codec_service.dart';
import '../../../data/services/ocr_service.dart';
import '../../history/providers/history_provider.dart';
import '../../output/providers/output_mode_provider.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(service.dispose);
  return service;
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});

final imageCodecServiceProvider = Provider<ImageCodecService>((ref) {
  return ImageCodecService();
});

class ScanState {
  const ScanState({
    this.isCameraReady = false,
    this.isTorchOn = false,
    this.isProcessing = false,
    this.errorMessage,
    this.capturedImagePath,
    this.recognizedText,
  });

  final bool isCameraReady;
  final bool isTorchOn;
  final bool isProcessing;
  final String? errorMessage;
  final String? capturedImagePath;
  final String? recognizedText;

  ScanState copyWith({
    bool? isCameraReady,
    bool? isTorchOn,
    bool? isProcessing,
    String? errorMessage,
    String? capturedImagePath,
    String? recognizedText,
  }) {
    return ScanState(
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      recognizedText: recognizedText ?? this.recognizedText,
    );
  }
}

final scanControllerProvider =
    StateNotifierProvider<ScanController, ScanState>((ref) {
  return ScanController(
    ref.watch(cameraServiceProvider),
    ref.watch(ocrServiceProvider),
    ref.watch(apiRepositoryProvider),
    ref.watch(imageCodecServiceProvider),
    () => ref.invalidate(historyListProvider),
  );
});

class ScanController extends StateNotifier<ScanState> {
  ScanController(this._camera, this._ocr, this._api, this._imageCodec, this._onHistorySaved)
      : super(const ScanState());

  final CameraService _camera;
  final OcrService _ocr;
  final ApiRepository _api;
  final ImageCodecService _imageCodec;
  final void Function() _onHistorySaved;

  Future<void> initCamera() async {
    try {
      await _camera.initialize();
      state = state.copyWith(isCameraReady: true);
    } catch (e, st) {
      debugPrint('ScanController.initCamera error: $e\n$st');
      state = state.copyWith(
        errorMessage: 'Gagal mengakses kamera. Cek izin kamera di pengaturan.',
      );
    }
  }

  /// Flashlight manual, hanya berubah saat tombol ini ditekan pengguna.
  Future<void> toggleTorch() async {
    await _camera.toggleTorch();
    state = state.copyWith(isTorchOn: _camera.isTorchOn);
  }

  /// [point] relatif 0.0-1.0, dipanggil pas user tap layar kamera utk
  /// fokus manual ke bagian teks tertentu.
  Future<void> focusAt(Offset point) {
    return _camera.focusAndExposeAt(point);
  }

  /// [mode] menentukan field type di history, zoom atau tts.
  Future<void> captureAndRecognize(OutputMode mode) async {
    if (!state.isCameraReady || state.isProcessing) return;
    state = state.copyWith(isProcessing: true, errorMessage: null);

    late final XFile file;
    late final String text;
    try {
      file = await _camera.takePicture();
      text = await _ocr.recognizeFromFile(file.path);
    } catch (e, st) {
      debugPrint('ScanController.captureAndRecognize (capture/OCR) error: $e\n$st');
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Gagal memindai teks, coba lagi.',
      );
      return;
    }

    // Tampilkan hasil OCR segera langsung
    state = state.copyWith(
      isProcessing: false,
      capturedImagePath: file.path,
      recognizedText: text,
    );

    try {
      final imageBase64 = await _imageCodec.compressToBase64(file.path);
      await _api.addHistory(
        type: mode == OutputMode.zoom ? 'zoom' : 'tts',
        teksHasil: text,
        gambar: imageBase64,
      );
      _onHistorySaved();
      await _api.logActivity('scan');
    } catch (e, st) {
      // Gagal simpan history/log tidak menggagalkan hasil scan yang sudah
      // ditampilkan, cuma dicatat di console
      debugPrint('ScanController.captureAndRecognize (save history) error: $e\n$st');
    }
  }

  void reset() {
    state = state.copyWith(capturedImagePath: null, recognizedText: null);
  }
}