import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/repositories/api_repository.dart';
import '../../../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Status login realtime. Null berarti belum login.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref.watch(authServiceProvider), ref.watch(apiRepositoryProvider));
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
  LoginController(this._authService, this._api) : super(const LoginState());

  final AuthService _authService;
  final ApiRepository _api;

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _syncToBackend(user.displayName ?? 'Pengguna', user.email);
      }
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Gagal login dengan Google.',
      );
    } catch (e, st) {
      debugPrint('signInWithGoogle error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan, coba lagi.',
      );
    }
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.signInAsGuest();
      await _syncToBackend('Tamu', null);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      debugPrint('continueAsGuest error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal masuk sebagai tamu, coba lagi.',
      );
    }
  }

  /// Sync sekali ke Postgres lewat API. Dipisah try-catch sendiri, gagal
  /// sync tidak boleh bikin login utamanya keanggap gagal.
  Future<void> _syncToBackend(String username, String? email) async {
    try {
      await _api.syncLogin(username: username, email: email);
    } catch (e, st) {
      debugPrint('syncLogin error: $e\n$st');
    }
  }
}