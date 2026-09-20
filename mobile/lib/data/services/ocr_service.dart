import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR on-device via Google ML Kit
class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// [imagePath] = path file hasil CameraService.takePicture().
  /// Auto-rotate: InputImage.fromFilePath membaca EXIF orientation file secara
  /// otomatis, jadi teks tetap terbaca benar walau device diputar saat memotret.
  Future<String> recognizeFromFile(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<void> dispose() => _recognizer.close();
}