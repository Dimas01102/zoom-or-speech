import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../providers/tts_provider.dart';
import '../widgets/result_body.dart';
import 'zoom_result_page.dart';

/// Mode suara Foto + teks
/// play/stop, dan kecepatan suara (flutter_tts).
class TtsResultPage extends ConsumerStatefulWidget {
  const TtsResultPage({
    super.key,
    required this.recognizedText,
    this.capturedImagePath,
    this.imageBase64,
  });

  final String recognizedText;
  final String? capturedImagePath;
  final String? imageBase64;

  @override
  ConsumerState<TtsResultPage> createState() => _TtsResultPageState();
}

class _TtsResultPageState extends ConsumerState<TtsResultPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final setting = ref.read(settingsControllerProvider);
      final controller = ref.read(ttsControllerProvider.notifier);
      await controller.setLanguageFromBahasa(setting.bahasa);
      await controller.setSpeechRate(setting.kecepatanSuara);
      await controller.play(widget.recognizedText);
    });
  }

  void _switchToZoom() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ZoomResultPage(
          recognizedText: widget.recognizedText,
          capturedImagePath: widget.capturedImagePath,
          imageBase64: widget.imageBase64,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ttsControllerProvider);
    final controller = ref.read(ttsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Suara')),
      body: Column(
        children: [
          Expanded(
            child: ResultBody(
              recognizedText: widget.recognizedText,
              capturedImagePath: widget.capturedImagePath,
              imageBase64: widget.imageBase64,
              imageFlex: 2,
              textFlex: 3,
            ),
          ),
          ResultControlBar(
            children: [
              ResultIconButton(
                icon: Icons.zoom_in,
                tooltip: 'Pindah ke Zoom',
                size: 56,
                onPressed: _switchToZoom,
              ),
              ResultIconButton(
                icon: state.isSpeaking ? Icons.stop : Icons.play_arrow,
                tooltip: state.isSpeaking ? 'Berhenti' : 'Putar',
                size: 72,
                filled: true,
                onPressed: () => state.isSpeaking
                    ? controller.stop()
                    : controller.play(widget.recognizedText),
              ),
              ResultIconButton(
                icon: Icons.speed,
                tooltip: 'Kecepatan suara',
                size: 56,
                onPressed: () => _showSpeedPicker(context, controller, state.speechRate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(ttsControllerProvider.notifier).stop();
    super.dispose();
  }

  void _showSpeedPicker(BuildContext context, TtsController controller, double current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          double rate = current;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Kecepatan Suara', style: TextStyle(fontSize: 18)),
                Slider(
                  value: rate,
                  min: 0.25,
                  max: 1.0,
                  label: rate.toStringAsFixed(2),
                  onChanged: (value) {
                    setSheetState(() => rate = value);
                    controller.setSpeechRate(value);
                  },
                  onChangeEnd: (value) {
                    controller.setSpeechRateAndApply(value);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}