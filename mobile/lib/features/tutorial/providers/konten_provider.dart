import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/konten.dart';
import '../../../data/repositories/api_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Daftar konten tutorial dari API. Fetch ulang saat akun ganti.
final kontenListProvider = FutureProvider<List<Konten>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(apiRepositoryProvider).fetchKonten();
});