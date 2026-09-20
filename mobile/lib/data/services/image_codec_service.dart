import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Kompres & encode foto hasil scan jadi base64, disimpan langsung di field
/// `gambar` pada dokumen Firestore `history`
class ImageCodecService {
  /// [maxWidth] & [quality] base64
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