/// Representasi baris tabel konten dari response API Laravel.
///
/// Kolom `deskripsi` boleh berisi teks biasa, atau teks terstruktur ringan
/// supaya halaman detail bisa menampilkan tag, langkah, dan tips:
///
///   tags: Panduan Dasar, Mode Kamera
///
///   Paragraf pengantar.
///
///   # Judul Bagian Langkah
///   1. Judul Langkah | Isi langkah
///   2. Judul Langkah | Isi langkah
///
///   # Judul Bagian Tips
///   - Tips pertama
///   - Tips kedua
///
/// Teks biasa seluruhnya dianggap paragraf pengantar.
class Konten {
  const Konten({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.video,
    this.diperbaruiOleh,
    this.updatedAt,
  });

  final int id;
  final String judul;
  final String deskripsi;
  final String video;
  final String? diperbaruiOleh;
  final DateTime? updatedAt;

  factory Konten.fromJson(Map<String, dynamic> json) {
    return Konten(
      id: json['id_konten'] as int,
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      video: json['video'] as String? ?? '',
      diperbaruiOleh: json['diperbarui_oleh'] as String?,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '')?.toLocal(),
    );
  }

  KontenBody get body => KontenBody.parse(deskripsi);

  /// Paragraf pengantar saja (dipakai di daftar konten).
  String get ringkasan {
    final intro = body.intro;
    return intro.isNotEmpty ? intro.first : deskripsi;
  }
}

class KontenStep {
  const KontenStep(this.title, this.body);

  final String title;
  final String body;
}

class KontenBody {
  const KontenBody({
    required this.intro,
    required this.tags,
    required this.steps,
    required this.tips,
    this.stepsTitle,
    this.tipsTitle,
  });

  final List<String> intro;
  final List<String> tags;
  final List<KontenStep> steps;
  final List<String> tips;
  final String? stepsTitle;
  final String? tipsTitle;

  static final _stepFull = RegExp(r'^\d+[.)]\s*(.+?)\s*\|\s*(.+)$');
  static final _stepTitleOnly = RegExp(r'^\d+[.)]\s*(.+)$');
  static final _bullet = RegExp(r'^[-*\u2022]\s+(.+)$');

  factory KontenBody.parse(String raw) {
    final intro = <String>[];
    final tags = <String>[];
    final steps = <KontenStep>[];
    final tips = <String>[];
    String? stepsTitle;
    String? tipsTitle;
    String? heading;

    for (final rawLine in raw.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.toLowerCase().startsWith('tags:')) {
        tags.addAll(
          line.substring(5).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
        );
        continue;
      }

      if (line.startsWith('#')) {
        heading = line.replaceFirst(RegExp(r'^#+\s*'), '');
        continue;
      }

      final full = _stepFull.firstMatch(line);
      if (full != null) {
        if (steps.isEmpty) {
          stepsTitle = heading;
          heading = null;
        }
        steps.add(KontenStep(full.group(1)!, full.group(2)!));
        continue;
      }

      final bullet = _bullet.firstMatch(line);
      if (bullet != null) {
        if (tips.isEmpty) {
          tipsTitle = heading;
          heading = null;
        }
        tips.add(bullet.group(1)!);
        continue;
      }

      final titleOnly = _stepTitleOnly.firstMatch(line);
      if (titleOnly != null) {
        if (steps.isEmpty) {
          stepsTitle = heading;
          heading = null;
        }
        steps.add(KontenStep(titleOnly.group(1)!, ''));
        continue;
      }

      intro.add(line);
    }

    return KontenBody(
      intro: intro,
      tags: tags,
      steps: steps,
      tips: tips,
      stepsTitle: stepsTitle,
      tipsTitle: tipsTitle,
    );
  }
}