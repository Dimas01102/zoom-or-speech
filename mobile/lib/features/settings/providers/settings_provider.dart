import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/models/user_setting.dart';
import '../../../data/repositories/firestore_service.dart';
import '../../scan/providers/scan_provider.dart' show firestoreServiceProvider;

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, UserSetting>((ref) {
  final controller = SettingsController(ref.watch(firestoreServiceProvider));
  ref.onDispose(controller.disposeController);
  return controller;
});

class SettingsController extends StateNotifier<UserSetting> {
  SettingsController(this._firestore) : super(UserSetting.defaultValue) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _subscription = _firestore.watchUserSetting(userId).listen((setting) {
        state = setting;
      });
    }
  }

  final FirestoreService _firestore;
  StreamSubscription<UserSetting>? _subscription;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> setBahasa(String bahasa) async {
    state = state.copyWith(bahasa: bahasa);
    await _persist();
  }

  Future<void> setKecepatanSuara(double rate) async {
    state = state.copyWith(kecepatanSuara: rate);
    await _persist();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore.saveUserSetting(userId, state);
  }

  void disposeController() {
    _subscription?.cancel();
  }
}