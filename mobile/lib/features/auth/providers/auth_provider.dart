import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; 

import '../../../data/repositories/firestore_service.dart';
import '../../../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final _firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

/// Status login realtime — null = belum login.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Controller utk aksi tombol di LoginPage (loading state + error message).
final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref.watch(authServiceProvider), ref.watch(_firestoreServiceProvider));
});

class LoginState {
  const LoginState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  LoginState copyWith({bool? isLoading, String? errorMessage}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._authService, this._firestore) : super(const LoginState());

  final AuthService _authService;
  final FirestoreService _firestore;

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _syncUserData(user.uid, user.displayName ?? 'Pengguna', user.email);
      }
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Gagal login dengan Google.',
      );
      await _firestore.logError(null, 'login_google');
    } catch (e, st) {
      debugPrint('signInWithGoogle error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan, coba lagi.',
      );
      await _firestore.logError(null, 'login_google');
    }
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authService.signInAsGuest();
      final user = credential.user;
      if (user != null) {
        await _syncUserData(user.uid, 'Tamu', null);
      }
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      debugPrint('continueAsGuest error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal masuk sebagai tamu, coba lagi.',
      );
      await _firestore.logError(null, 'login_guest');
    }
  }

  /// Simpan ke koleksi user dan catat log. Dipisah try-catch sendiri supaya
  /// gagal simpan data ini TIDAK bikin login utamanya keanggap gagal.
  Future<void> _syncUserData(String uid, String username, String? email) async {
    try {
      await _firestore.upsertUser(uid, username: username, email: email);
    } catch (e, st) {
      debugPrint('upsertUser error (cek firestore.rules sudah dideploy belum): $e\n$st');
    }
    try {
      await _firestore.logActivity(userId: uid, jenisAktivitas: 'login');
    } catch (e, st) {
      debugPrint('logActivity error: $e\n$st');
    }
  }
}