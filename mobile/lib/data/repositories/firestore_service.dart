import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/history_entry.dart';
import '../models/konten.dart';
import '../models/usage_log.dart';
import '../models/user_setting.dart';

/// Wrapper akses Firestore dari sisi Mobile App (client).
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _history => _db.collection('history');
  CollectionReference<Map<String, dynamic>> get _usageLogs => _db.collection('usage_logs');
  CollectionReference<Map<String, dynamic>> get _konten => _db.collection('konten');
  CollectionReference<Map<String, dynamic>> get _userSetting => _db.collection('user_setting');

  Future<void> addHistory(HistoryEntry entry) {
    return _history.add(entry.toMap());
  }

  /// Bikin reference dgn ID
  DocumentReference<Map<String, dynamic>> newHistoryRef() => _history.doc();

  Future<void> saveHistory(
    DocumentReference<Map<String, dynamic>> ref,
    HistoryEntry entry,
  ) {
    return ref.set(entry.toMap());
  }

  Stream<List<HistoryEntry>> watchHistoryForUser(String userId) {
    return _history
        .where('id_user', isEqualTo: userId)
        .orderBy('waktu_scan', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(HistoryEntry.fromDoc).toList());
  }

  /// hapus satu entri riwayat.
  Future<void> deleteHistory(String id) {
    return _history.doc(id).delete();
  }

  /// hapus banyak entri sekaligus (mode pilih banyak), 
  Future<void> deleteHistoryMany(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_history.doc(id));
    }
    await batch.commit();
  }

  /// Dipanggil di setiap aktivitas (login, scan, ganti mode) DAN saat error,
  Future<void> logActivity({
    required String? userId,
    required String jenisAktivitas,
  }) {
    final log = UsageLog(
      idUser: userId,
      jenisAktivitas: jenisAktivitas,
      waktu: DateTime.now(),
    );
    return _usageLogs.add(log.toMap());
  }

  Future<void> logError(String? userId, String context) {
    return logActivity(userId: userId, jenisAktivitas: 'error');
  }

  /// UC-004 — daftar konten tutorial. Isi manual dulu via Firebase Console
  /// sebelum Panel Admin (UC-008) ada.
  Stream<List<Konten>> watchKontenList() {
    return _konten.snapshots().map(
          (snap) => snap.docs.map(Konten.fromDoc).toList(),
        );
  }

  /// id dokumen = id_user (1-1). set(...) tanpa merge:true krn cuma
  Stream<UserSetting> watchUserSetting(String userId) {
    return _userSetting.doc(userId).snapshots().map(UserSetting.fromDoc);
  }

  Future<void> saveUserSetting(String userId, UserSetting setting) {
    return _userSetting.doc(userId).set(setting.toMap());
  }
}