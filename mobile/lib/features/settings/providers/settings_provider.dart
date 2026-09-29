import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/models/user_setting.dart';
import '../../../data/repositories/api_repository.dart';
import '../../auth/providers/auth_provider.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, UserSetting>((ref) {
  // Watch auth supaya controller dibuat ulang (dan load ulang) saat akun ganti.
  ref.watch(authStateProvider);
  final controller = SettingsController(ref.watch(apiRepositoryProvider));
  controller.load();
  return controller;
});

class SettingsController extends StateNotifier<UserSetting> {
  SettingsController(this._api) : super(UserSetting.defaultValue);

  final ApiRepository _api;

  Future<void> load() async {
    try {
      final setting = await _api.fetchUserSetting();
      state = setting;
    } catch (e, st) {
      debugPrint('SettingsController.load error: $e\n$st');
    }
  }

  Future<void> setBahasa(String bahasa) async {
    state = state.copyWith(bahasa: bahasa);
    await _persist();
  }

  Future<void> setKecepatanSuara(double rate) async {
    state = state.copyWith(kecepatanSuara: rate);
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _api.updateUserSetting(bahasa: state.bahasa, kecepatanSuara: state.kecepatanSuara);
    } catch (e, st) {
      debugPrint('SettingsController._persist error: $e\n$st');
    }
  }
}