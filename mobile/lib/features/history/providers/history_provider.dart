import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/history_entry.dart';
import '../../../data/repositories/api_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Watch authStateProvider supaya otomatis fetch ulang saat akun ganti.
/// Panggil ref.invalidate(historyListProvider) setelah tambah/hapus riwayat.
final historyListProvider = FutureProvider<List<HistoryEntry>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(apiRepositoryProvider).fetchHistory();
});
