import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../pages/login_page.dart';
import '../pages/onboarding_page.dart';
import '../providers/auth_provider.dart';
import '../../../shared/main_shell.dart';

/// Menentukan halaman awal aplikasi:
/// - Sedang cek sesi        -> Splash (loading)
/// - Belum login            -> LoginPage
/// - Login tapi belum lihat onboarding -> OnboardingPage
/// - Sudah login & onboarding selesai  -> HomePage
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _SplashView(),
      error: (err, _) => _SplashView(errorMessage: err.toString()),
      data: (user) {
        if (user == null) {
          return const LoginPage();
        }
        return const _PostLoginRouter();
      },
    );
  }
}

/// Setelah login, cek sekali apakah onboarding sudah pernah dilihat.
/// Dipisah jadi StatefulWidget sendiri supaya bisa setStat
/// OnboardingPage selesai, tanpa perlu query ulang SharedPreferences.
class _PostLoginRouter extends StatefulWidget {
  const _PostLoginRouter();

  @override
  State<_PostLoginRouter> createState() => _PostLoginRouterState();
}

class _PostLoginRouterState extends State<_PostLoginRouter> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    OnboardingPage.hasCompleted().then((done) {
      if (mounted) setState(() => _onboardingDone = done);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) return const _SplashView();

    if (!_onboardingDone!) {
      return OnboardingPage(
        onFinished: () => setState(() => _onboardingDone = true),
      );
    }

    // Sudah login & onboarding selesai -> MainShell (Beranda/Riwayat/Pengaturan).
    return const MainShell();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 88,
                    width: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'JELAS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}