import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Kompres & encode foto hasil scan jadi base64, disimpan LANGSUNG di field
/// `gambar` pada tabel history di server, tanpa upload storage
/// (yang mewajibkan upgrade ke plan Blaze / kartu kredit).
///
/// Foto WAJIB dikompres supaya payload API kecil.
/// Tambahkan dependency: flutter pub add image
class ImageCodecService {
  /// [maxWidth] & [quality] dipilih supaya hasil base64 biasanya di bawah
  /// ~150 KB, masih cukup jelas utk thumbnail
  /// riwayat (bukan utk ditampilkan full-screen resolusi tinggi).
  Future<String> compressToBase64(
    String filePath, {
    int maxWidth = 480,
    int quality = 50,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Gagal membaca file gambar hasil scan.');
    }

    final resized =
        decoded.width > maxWidth ? img.copyResize(decoded, width: maxWidth) : decoded;

    final Uint8List compressed = Uint8List.fromList(
      img.encodeJpg(resized, quality: quality),
    );

    return base64Encode(compressed);
  }
}