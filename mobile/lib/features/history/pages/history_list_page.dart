import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/history_entry.dart';
import '../../../shared/skeleton.dart';
import '../../output/pages/tts_result_page.dart';
import '../../output/pages/zoom_result_page.dart';
import '../../scan/providers/scan_provider.dart' show firestoreServiceProvider;

/// daftar riwayat scan milik user. Bisa diputar ulang sesuai type,
/// swipe kiri utk hapus satu, atau masuk mode pilih-banyak via ikon di AppBar.
class HistoryListPage extends ConsumerStatefulWidget {
  const HistoryListPage({super.key});

  @override
  ConsumerState<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends ConsumerState<HistoryListPage> {
  bool _selecting = false;
  final Set<String> _selectedIds = {};

  void _replay(HistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => entry.type == 'zoom'
            ? ZoomResultPage(recognizedText: entry.teksHasil, imageBase64: entry.gambar)
            : TtsResultPage(recognizedText: entry.teksHasil),
      ),
    );
  }

  Future<void> _deleteOne(String id) async {
    await ref.read(firestoreServiceProvider).deleteHistory(id);
  }

  Future<void> _deleteSelected() async {
    final t = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.deleteConfirmBody(_selectedIds.length)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(firestoreServiceProvider).deleteHistoryMany(_selectedIds.toList());
    setState(() {
      _selectedIds.clear();
      _selecting = false;
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = ref.watch(firestoreServiceProvider);
    final t = ref.watch(appStringsProvider);

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Belum login.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? '${_selectedIds.length} ${t.select}' : t.navHistory),
        leading: _selecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _selecting = false;
                  _selectedIds.clear();
                }),
              )
            : null,
        actions: [
          if (_selecting)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            )
          else
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: t.select,
              onPressed: () => setState(() => _selecting = true),
            ),
        ],
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: firestore.watchHistoryForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonListView();
          }
          if (snapshot.hasError) {
            debugPrint('HistoryListPage stream error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat riwayat.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text(t.historyEmpty));
          }
          if (_selecting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = items[index];
                final selected = entry.id != null && _selectedIds.contains(entry.id);
                return _HistoryTile(
                  entry: entry,
                  onTap: () => entry.id != null ? _toggleSelect(entry.id!) : null,
                  selecting: true,
                  selected: selected,
                );
              },
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = items[index];
              return Dismissible(
                key: ValueKey(entry.id ?? index),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final t = ref.read(appStringsProvider);
                  return showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(t.deleteConfirmTitle),
                      content: Text(t.deleteConfirmBody(1)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(t.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(t.delete),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  if (entry.id != null) _deleteOne(entry.id!);
                },
                child: _HistoryTile(entry: entry, onTap: () => _replay(entry)),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.onTap,
    this.selecting = false,
    this.selected = false,
  });

  final HistoryEntry entry;
  final VoidCallback onTap;
  final bool selecting;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isZoom = entry.type == 'zoom';

    Widget leading;
    if (entry.gambar != null && entry.gambar!.isNotEmpty) {
      try {
        leading = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(entry.gambar!),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        leading = _fallbackIcon(isZoom);
      }
    } else {
      leading = _fallbackIcon(isZoom);
    }

    return Card(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: selecting
            ? Checkbox(value: selected, onChanged: (_) => onTap())
            : leading,
        title: Text(
          entry.teksHasil.isEmpty ? '(Tidak ada teks)' : entry.teksHasil,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${isZoom ? 'Zoom' : 'Suara'} • ${DateFormat('d MMM yyyy, HH:mm').format(entry.waktuScan)}',
        ),
        trailing: selecting ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _fallbackIcon(bool isZoom) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: isZoom ? AppColors.primary : AppColors.secondary,
      child: Icon(isZoom ? Icons.search : Icons.volume_up, color: Colors.white),
    );
  }
}