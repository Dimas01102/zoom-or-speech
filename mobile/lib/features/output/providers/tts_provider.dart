import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/services/tts_service.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

class TtsPlaybackState {
  const TtsPlaybackState({this.isSpeaking = false, this.speechRate = 0.5});
  final bool isSpeaking;
  final double speechRate;

  TtsPlaybackState copyWith({bool? isSpeaking, double? speechRate}) {
    return TtsPlaybackState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      speechRate: speechRate ?? this.speechRate,
    );
  }
}

final ttsControllerProvider =
    StateNotifierProvider<TtsController, TtsPlaybackState>((ref) {
  return TtsController(ref.watch(ttsServiceProvider));
});

class TtsController extends StateNotifier<TtsPlaybackState> {
  TtsController(this._service) : super(const TtsPlaybackState()) {
    _service.onComplete = () => state = state.copyWith(isSpeaking: false);
    _service.setSpeechRate(state.speechRate);
  }

  final TtsService _service;
  String _lastText = '';

  Future<void> play(String text) async {
    _lastText = text;
    state = state.copyWith(isSpeaking: true);
    await _service.speak(text);
  }

  Future<void> stop() async {
    await _service.stop();
    state = state.copyWith(isSpeaking: false);
  }

  /// Ulangi dari awal.
  Future<void> replay(String text) async {
    await _service.stop();
    await play(text);
  }

  Future<void> setSpeechRate(double rate) async {
    await _service.setSpeechRate(rate);
    state = state.copyWith(speechRate: rate);
  }

  /// Dipanggil dari slider kecepatan di Hasil Suara
  Future<void> setSpeechRateAndApply(double rate) async {
    final wasSpeaking = state.isSpeaking;
    await _service.setSpeechRate(rate);
    state = state.copyWith(speechRate: rate);
    if (wasSpeaking && _lastText.isNotEmpty) {
      await replay(_lastText);
    }
  }

  /// [bahasa] = 'id' atau 'en' dari user_setting 
  Future<void> setLanguageFromBahasa(String bahasa) {
    final code = bahasa == 'en' ? 'en-US' : 'id-ID';
    return _service.setLanguage(code);
  }
}