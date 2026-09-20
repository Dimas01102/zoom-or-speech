import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/tts_provider.dart';

/// kontrol play/berhenti/ulangi via flutter_tts.
class TtsResultPage extends ConsumerStatefulWidget {
  const TtsResultPage({super.key, required this.recognizedText});

  final String recognizedText;

  @override
  ConsumerState<TtsResultPage> createState() => _TtsResultPageState();
}

class _TtsResultPageState extends ConsumerState<TtsResultPage> {
  @override
  void initState() {
    super.initState();
    // Terapkan bahasa & kecepatan_suara tersimpan (UC-005) sebelum mulai membaca.
    Future.microtask(() async {
      final setting = ref.read(settingsControllerProvider);
      final controller = ref.read(ttsControllerProvider.notifier);
      await controller.setLanguageFromBahasa(setting.bahasa);
      await controller.setSpeechRate(setting.kecepatanSuara);
      await controller.play(widget.recognizedText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ttsControllerProvider);
    final controller = ref.read(ttsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Suara')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.recognizedText.isEmpty
                      ? 'Tidak ada teks terdeteksi.'
                      : widget.recognizedText,
                  style: const TextStyle(fontSize: 18, height: 1.5, color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.replay, color: AppColors.secondary),
                  onPressed: () => controller.replay(widget.recognizedText),
                ),
                GestureDetector(
                  onTap: () => state.isSpeaking
                      ? controller.stop()
                      : controller.play(widget.recognizedText),
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      state.isSpeaking ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.speed, color: AppColors.secondary),
                  onPressed: () => _showSpeedPicker(context, controller, state.speechRate),
                ),
              ],
            ),
          ],
        ),
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
                  divisions: 3,
                  label: rate.toStringAsFixed(2),
                  onChanged: (value) {
                    setSheetState(() => rate = value);
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