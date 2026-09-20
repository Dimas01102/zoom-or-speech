import 'package:cloud_firestore/cloud_firestore.dart';

/// Representasi dokumen koleksi `konten` dibuat/diedit lewat Panel Admin
class Konten {
  const Konten({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.video,
    this.diperbaruiOleh,
  });

  final String id;
  final String judul;
  final String deskripsi;
  final String video; // link YouTube / Firebase Storage
  final String? diperbaruiOleh;

  factory Konten.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Konten(
      id: doc.id,
      judul: data['judul'] as String? ?? '',
      deskripsi: data['deskripsi'] as String? ?? '',
      video: data['video'] as String? ?? '',
      diperbaruiOleh: data['diperbarui_oleh'] as String?,
    );
  }
}