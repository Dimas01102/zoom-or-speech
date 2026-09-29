/// Representasi baris tabel history dari response API Laravel.
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

  final int? id;
  final int idUser;
  final DateTime waktuScan;
  final String type;
  final String teksHasil;
  final String? gambar;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id_history'] as int?,
      idUser: json['id_user'] as int,
      waktuScan: DateTime.parse(json['waktu_scan'] as String),
      type: json['type'] as String,
      teksHasil: json['teks_hasil'] as String,
      gambar: json['gambar'] as String?,
    );
  }
}