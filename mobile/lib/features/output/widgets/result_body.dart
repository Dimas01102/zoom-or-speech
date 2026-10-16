import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Isi halaman hasil (Zoom & Suara)
class ResultBody extends StatefulWidget {
  const ResultBody({
    super.key,
    required this.recognizedText,
    this.capturedImagePath,
    this.imageBase64,
    this.imageFlex = 3,
    this.textFlex = 2,
  });

  final String recognizedText;
  final String? capturedImagePath;
  final String? imageBase64;
  final int imageFlex;
  final int textFlex;

  @override
  State<ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<ResultBody> {
  // Base64 di-decode sekali saja (bukan tiap rebuild) biar ringan.
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final b64 = widget.imageBase64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        _bytes = base64Decode(b64);
      } catch (_) {
        _bytes = null;
      }
    }
  }

  Widget? _buildImage() {
    final path = widget.capturedImagePath;
    // cacheWidth: foto kamera bisa 12MP+, di-decode lebih kecil supaya hemat RAM
    // tapi tetap tajam saat di-zoom.
    if (path != null && path.isNotEmpty) {
      return Image.file(File(path), fit: BoxFit.contain, cacheWidth: 2048);
    }
    if (_bytes != null) {
      return Image.memory(_bytes!, fit: BoxFit.contain, cacheWidth: 2048);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    final text = widget.recognizedText;

    return Column(
      children: [
        Expanded(
          flex: widget.imageFlex,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: image != null
                ? InteractiveViewer(
                    minScale: 1,
                    maxScale: 6,
                    child: Center(child: image),
                  )
                : const Center(
                    child: Text(
                      'Foto tidak tersedia',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
          ),
        ),
        Expanded(
          flex: widget.textFlex,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.background,
            child: SingleChildScrollView(
              child: Text(
                text.isEmpty ? 'Tidak ada teks terdeteksi.' : text,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tombol bulat berisi icon saja. [tooltip] dipakai sebagai label TalkBack.
class ResultIconButton extends StatelessWidget {
  const ResultIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
    this.filled = false,
    this.color = AppColors.secondary,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: filled ? color : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              height: size,
              width: size,
              child: Icon(
                icon,
                color: filled ? Colors.white : color,
                size: filled ? size * 0.5 : size * 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bar kontrol bawah: icon kiri, tengah (besar), kanan.
class ResultControlBar extends StatelessWidget {
  const ResultControlBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
