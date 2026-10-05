import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/history_entry.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../shared/skeleton.dart';
import '../providers/history_provider.dart';
import '../../output/pages/tts_result_page.dart';
import '../../output/pages/zoom_result_page.dart';

class HistoryListPage extends ConsumerStatefulWidget {
  const HistoryListPage({super.key});

  @override
  ConsumerState<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends ConsumerState<HistoryListPage> {
  bool _selecting = false;
  final Set<int> _selectedIds = {};
  final Set<int> _hiddenIds = {};

  void _reload() {
    ref.invalidate(historyListProvider);
  }

  void _replay(HistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => entry.type == 'zoom'
            ? ZoomResultPage(recognizedText: entry.teksHasil, imageBase64: entry.gambar)
            : TtsResultPage(recognizedText: entry.teksHasil),
      ),
    );
  }

  Future<void> _deleteOne(int id) async {
    await ref.read(apiRepositoryProvider).deleteHistory(id);
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

    final api = ref.read(apiRepositoryProvider);
    await Future.wait(_selectedIds.map(api.deleteHistory));

    setState(() {
      _selectedIds.clear();
      _selecting = false;
    });
    _reload();
  }

  void _toggleSelect(int id) {
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
    final t = ref.watch(appStringsProvider);

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
      body: ref.watch(historyListProvider).when(
        skipLoadingOnRefresh: false,
        loading: () => const SkeletonListView(),
        error: (error, _) {
          debugPrint('HistoryListPage error: $error');
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat riwayat. Cek koneksi internet.'),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _reload, child: const Text('Coba lagi')),
                  ],
                ),
              ),
          );
        },
        data: (allItems) {
          final items = allItems
              .where((e) => e.id == null || !_hiddenIds.contains(e.id))
              .toList();
          if (items.isEmpty) {
            return Center(child: Text(t.historyEmpty));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(historyListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = items[index];
                final id = entry.id;

                if (_selecting) {
                  return _HistoryTile(
                    entry: entry,
                    onTap: () {
                      if (id != null) _toggleSelect(id);
                    },
                    selecting: true,
                    selected: id != null && _selectedIds.contains(id),
                  );
                }

                return Dismissible(
                  key: ValueKey(id ?? index),
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
                  onDismissed: (_) async {
                    if (id == null) return;
                    // Sembunyikan langsung, Dismissible wajib hilang dari tree.
                    setState(() => _hiddenIds.add(id));
                    try {
                      await _deleteOne(id);
                    } catch (e) {
                      debugPrint('Hapus riwayat gagal: $e');
                      if (mounted) setState(() => _hiddenIds.remove(id));
                    }
                    _reload();
                  },
                  child: _HistoryTile(entry: entry, onTap: () => _replay(entry)),
                );
              },
            ),
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
        leading: selecting ? Checkbox(value: selected, onChanged: (_) => onTap()) : leading,
        title: Text(
          entry.teksHasil.isEmpty ? '(Tidak ada teks)' : entry.teksHasil,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${isZoom ? 'Zoom' : 'Suara'} | ${DateFormat('d MMM yyyy, HH:mm').format(entry.waktuScan.toLocal())}',
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