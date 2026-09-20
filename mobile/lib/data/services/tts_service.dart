import 'package:flutter_tts/flutter_tts.dart';

/// (mode Suara) pakai Android TTS Engine native, on-device.
class TtsService {
  TtsService() {
    _tts.setCompletionHandler(() => _onComplete?.call());
  }

  final FlutterTts _tts = FlutterTts();
  void Function()? _onComplete;

  set onComplete(void Function() callback) => _onComplete = callback;

  Future<void> setLanguage(String languageCode) => _tts.setLanguage(languageCode);

  /// [rate] 0.0 - 1.0, sinkron dengan kecepatan_suara di user_setting
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> pause() => _tts.pause();

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();
}