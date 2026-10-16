import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/result_body.dart';
import 'tts_result_page.dart';

/// Mode Zoom Foto asli ditampilkan dengan pinch to zoom
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

  void _switchToTts(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TtsResultPage(
          recognizedText: recognizedText,
          capturedImagePath: capturedImagePath,
          imageBase64: imageBase64,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Zoom')),
      body: Column(
        children: [
          Expanded(
            child: ResultBody(
              recognizedText: recognizedText,
              capturedImagePath: capturedImagePath,
              imageBase64: imageBase64,
              imageFlex: 3,
              textFlex: 2,
            ),
          ),
          ResultControlBar(
            children: [
              ResultIconButton(
                icon: Icons.volume_up,
                tooltip: 'Pindah ke Suara',
                size: 72,
                filled: true,
                color: AppColors.secondary,
                onPressed: () => _switchToTts(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
