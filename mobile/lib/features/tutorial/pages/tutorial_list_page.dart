import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/konten.dart';
import '../../../shared/skeleton.dart';
import '../../scan/providers/scan_provider.dart' show firestoreServiceProvider;
import 'tutorial_detail_page.dart';

/// daftar konten tutorial (dibuka dari ikon di Beranda).
class TutorialListPage extends ConsumerWidget {
  const TutorialListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: StreamBuilder<List<Konten>>(
        stream: firestore.watchKontenList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView();
          }
          if (snapshot.hasError) {
            debugPrint('TutorialListPage stream error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat konten tutorial.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada konten tutorial.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final konten = items[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(Icons.play_circle_outline, color: AppColors.primary),
                  ),
                  title: Text(
                    konten.judul,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    konten.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TutorialDetailPage(konten: konten)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}