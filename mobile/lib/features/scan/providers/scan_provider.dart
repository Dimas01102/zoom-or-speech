import 'package:camera/camera.dart' show XFile;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/models/history_entry.dart';
import '../../../data/repositories/firestore_service.dart';
import '../../../data/services/camera_service.dart';
import '../../../data/services/image_codec_service.dart';
import '../../../data/services/ocr_service.dart';
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

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
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
    ref.watch(firestoreServiceProvider),
    ref.watch(imageCodecServiceProvider),
  );
});

class ScanController extends StateNotifier<ScanState> {
  ScanController(this._camera, this._ocr, this._firestore, this._imageCodec)
      : super(const ScanState());

  final CameraService _camera;
  final OcrService _ocr;
  final FirestoreService _firestore;
  final ImageCodecService _imageCodec;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> initCamera() async {
    try {
      await _camera.initialize();
      state = state.copyWith(isCameraReady: true);
    } catch (e, st) {
      debugPrint('ScanController.initCamera error: $e\n$st');
      state = state.copyWith(
        errorMessage: 'Gagal mengakses kamera. Cek izin kamera di pengaturan.',
      );
      await _firestore.logError(_userId, 'camera_init');
    }
  }

  /// Flashlight manual hanya berubah saat tombol ini ditekan pengguna.
  Future<void> toggleTorch() async {
    await _camera.toggleTorch();
    state = state.copyWith(isTorchOn: _camera.isTorchOn);
  }

  /// [mode] menentukan field `type` di history: 'zoom' atau 'tts'.
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
      await _firestore.logError(_userId, 'scan_capture');
      return;
    }

    // Tampilkan hasil OCR 
    // (mis. rules belum dideploy, atau offline) bikin hasil scan yg udah
    // berhasil ini ikut hilang / dianggap gagal total.
    state = state.copyWith(
      isProcessing: false,
      capturedImagePath: file.path,
      recognizedText: text,
    );

    try {
      await _firestore.logActivity(userId: _userId, jenisAktivitas: 'scan');

      if (_userId != null) {
        // Kompres foto -> base64, simpan langsung di field `gambar`
        final imageBase64 = await _imageCodec.compressToBase64(file.path);

        await _firestore.addHistory(
          HistoryEntry(
            idUser: _userId!,
            waktuScan: DateTime.now(),
            type: mode == OutputMode.zoom ? 'zoom' : 'tts',
            teksHasil: text,
            gambar: imageBase64,
          ),
        );
      }
    } catch (e, st) {
      // Gagal simpan history/log).
      debugPrint('ScanController.captureAndRecognize (save history) error: $e\n$st');
    }
  }

  void reset() {
    state = state.copyWith(capturedImagePath: null, recognizedText: null);
  }
}