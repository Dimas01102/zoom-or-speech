import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Mode Zoom. Foto asli ditampilkan dengan pinch to zoom, teks hasil OCR
/// ditampilkan di panel bawah.
class ZoomResultPage extends StatelessWidget {
  const ZoomResultPage({
    super.key,
    required this.recognizedText,
    this.capturedImagePath,
    this.imageBase64,
  });

  final String recognizedText;
  final String? capturedImagePath;
  final String? imageBase64;

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;
    if (capturedImagePath != null && capturedImagePath!.isNotEmpty) {
      imageWidget = Image.file(File(capturedImagePath!), fit: BoxFit.contain);
    } else if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        imageWidget = Image.memory(base64Decode(imageBase64!), fit: BoxFit.contain);
      } catch (_) {
        imageWidget = null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Zoom')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: imageWidget != null
                  ? InteractiveViewer(
                      minScale: 1,
                      maxScale: 6,
                      child: Center(child: imageWidget),
                    )
                  : const Center(
                      child: Text('Foto tidak tersedia', style: TextStyle(color: Colors.white70)),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teks Terdeteksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        recognizedText.isEmpty ? 'Tidak ada teks terdeteksi.' : recognizedText,
                        style: const TextStyle(fontSize: 18, height: 1.4, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}