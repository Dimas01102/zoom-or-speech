import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/skeleton.dart';
import '../providers/konten_provider.dart';
import 'tutorial_detail_page.dart';

/// Daftar konten tutorial dari API Laravel.
class TutorialListPage extends ConsumerWidget {
  const TutorialListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.tutorial)),
      body: ref.watch(kontenListProvider).when(
            loading: () => const SkeletonListView(),
            error: (error, _) {
              debugPrint('TutorialListPage error: $error');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Gagal memuat konten tutorial. Cek koneksi internet.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(kontenListProvider),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              );
            },
            data: (items) {
              if (items.isEmpty) {
                return Center(child: Text(t.tutorialEmpty));
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(kontenListProvider.future),
                child: ListView.separated(
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
                          konten.ringkasan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TutorialDetailPage(konten: konten)),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
    );
  }
}