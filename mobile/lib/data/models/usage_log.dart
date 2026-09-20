import 'package:cloud_firestore/cloud_firestore.dart';

/// Representasi dokumen koleksi `usage_logs`.
/// id_user nullable -> dipakai jg utk event sistem tanpa user (mis. error global).
/// jenis_aktivitas contoh: 'login', 'scan', 'ganti_mode', 'error', dst.
class UsageLog {
  const UsageLog({
    this.idUser,
    required this.jenisAktivitas,
    required this.waktu,
  });

  final String? idUser;
  final String jenisAktivitas;
  final DateTime waktu;

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'jenis_aktivitas': jenisAktivitas,
      'waktu': Timestamp.fromDate(waktu),
    };
  }
}