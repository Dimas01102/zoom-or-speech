import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Kompres & encode foto hasil scan jadi base64, disimpan langsung di field
/// `gambar` pada tabel history di server, tanpa upload storage.
///
class ImageCodecService {
  /// [maxWidth] & [quality]
  Future<String> compressToBase64(
    String filePath, {
    int maxWidth = 480,
    int quality = 50,
  }) async {
    final bytes = await compute(
      _compressInBackground,
      _CompressArgs(filePath: filePath, maxWidth: maxWidth, quality: quality),
    );
    if (bytes == null) {
      throw const FormatException('Gagal membaca file gambar hasil scan.');
    }
    return base64Encode(bytes);
  }
}

class _CompressArgs {
  const _CompressArgs({required this.filePath, required this.maxWidth, required this.quality});
  final String filePath;
  final int maxWidth;
  final int quality;
}

Uint8List? _compressInBackground(_CompressArgs args) {
  final bytes = File(args.filePath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  final resized = decoded.width > args.maxWidth
      ? img.copyResize(decoded, width: args.maxWidth)
      : decoded;

  return Uint8List.fromList(img.encodeJpg(resized, quality: args.quality));
}