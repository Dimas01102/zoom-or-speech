import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// mode Zoom pinch to zoom pada teks hasil OCR.
class ZoomResultPage extends StatelessWidget {
  const ZoomResultPage({
    super.key,
    required this.recognizedText,
    this.capturedImagePath,
  });

  final String recognizedText;
  final String? capturedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Zoom')),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: AppColors.background,
          child: Text(
            recognizedText.isEmpty ? 'Tidak ada teks terdeteksi.' : recognizedText,
            style: const TextStyle(fontSize: 28, height: 1.4, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}