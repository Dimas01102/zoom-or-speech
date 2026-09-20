import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/konten.dart';

/// detail satu konten tutorial. Video dibuka via browser/app YouTube
/// eksternal (bukan embed player), supaya nggak perlu dependency player berat.
class TutorialDetailPage extends StatelessWidget {
  const TutorialDetailPage({super.key, required this.konten});

  final Konten konten;

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.tryParse(konten.video);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link video tidak valid.')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(konten.judul)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(konten.judul, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(konten.deskripsi, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            if (konten.video.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openVideo(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Tonton Video'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              ),
          ],
        ),
      ),
    );
  }
}