import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeFromFile(String imagePath) async {
    final preprocessedPath = await _preprocessForOcr(imagePath);
    final inputImage = InputImage.fromFilePath(preprocessedPath);
    final RecognizedText result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<String> _preprocessForOcr(String originalPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final outPath = '${dir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final processedPath = await compute(
        _processImageInBackground,
        _PreprocessArgs(originalPath, outPath),
      );
      return processedPath ?? originalPath;
    } catch (_) {
      // Preprocessing gagal
      return originalPath;
    }
  }

  Future<void> dispose() => _recognizer.close();
}

class _PreprocessArgs {
  const _PreprocessArgs(this.inputPath, this.outputPath);
  final String inputPath;
  final String outputPath;
}

String? _processImageInBackground(_PreprocessArgs args) {
  final bytes = File(args.inputPath).readAsBytesSync();
  var image = img.decodeImage(bytes);
  if (image == null) return null;

  // Normalisasi orientasi
  image = img.bakeOrientation(image);

  if (image.width > 1600) {
    image = img.copyResize(image, width: 1600);
  }

  image = img.grayscale(image);
  image = img.adjustColor(image, contrast: 1.35, brightness: 1.05);

  File(args.outputPath).writeAsBytesSync(img.encodeJpg(image, quality: 92));
  return args.outputPath;
}