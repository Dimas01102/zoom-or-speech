import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_entry.dart';
import '../models/konten.dart';
import '../models/user_setting.dart';
import '../services/api_client.dart';

class ApiRepository {
  ApiRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// Dipanggil sekali sesaat abis Google/Guest sign-in berhasil.
  Future<void> syncLogin({required String username, String? email}) {
    return _client.post('auth/login', {'username': username, 'email': email});
  }

  Future<List<HistoryEntry>> fetchHistory() async {
    final list = await _client.get('history') as List;
    return list.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addHistory({required String type, required String teksHasil, String? gambar}) {
    return _client.post('history', {
      'type': type,
      'teks_hasil': teksHasil,
      'gambar': gambar,
    });
  }

  Future<void> deleteHistory(int id) {
    return _client.delete('history/$id');
  }

  Future<UserSetting> fetchUserSetting() async {
    final data = await _client.get('user-setting') as Map<String, dynamic>;
    return UserSetting.fromJson(data);
  }

  Future<void> updateUserSetting({String? bahasa, double? kecepatanSuara}) {
    return _client.put('user-setting', {
      'bahasa':? bahasa,
      'kecepatan_suara':? kecepatanSuara,
    });
  }

  Future<List<Konten>> fetchKonten() async {
    final list = await _client.get('konten') as List;
    return list.map((e) => Konten.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> logActivity(String jenisAktivitas) {
    return _client.post('usage-log', {'jenis_aktivitas': jenisAktivitas});
  }
}

final apiRepositoryProvider = Provider<ApiRepository>((ref) => ApiRepository());