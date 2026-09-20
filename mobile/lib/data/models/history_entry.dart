import 'package:cloud_firestore/cloud_firestore.dart';

/// Representasi dokumen koleksi `history`.
/// type: 'zoom' | 'tts'
class HistoryEntry {
  const HistoryEntry({
    this.id,
    required this.idUser,
    required this.waktuScan,
    required this.type,
    required this.teksHasil,
    this.gambar,
  });

  final String? id;
  final String idUser;
  final DateTime waktuScan;
  final String type;
  final String teksHasil;
  final String? gambar;

  Map<String, dynamic> toMap() {
    return {
      'id_user': idUser,
      'waktu_scan': Timestamp.fromDate(waktuScan),
      'type': type,
      'teks_hasil': teksHasil,
      'gambar': gambar,
    };
  }

  factory HistoryEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HistoryEntry(
      id: doc.id,
      idUser: data['id_user'] as String,
      waktuScan: (data['waktu_scan'] as Timestamp).toDate(),
      type: data['type'] as String,
      teksHasil: data['teks_hasil'] as String,
      gambar: data['gambar'] as String?,
    );
  }
}