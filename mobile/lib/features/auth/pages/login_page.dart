import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    ref.listen(loginControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo — ganti dengan asset sesuai mockup (ikon kamera + lensa).
              Image.asset(
                'assets/logo.png',
                height: 88,
                width: 88,
              ),
              const SizedBox(height: 16),
              Text(
                'JELAS',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Baca teks apa pun dengan mudah',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              if (state.isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton.icon(
                  onPressed: controller.signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Masuk dengan Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: controller.continueAsGuest,
                  child: const Text('Lanjutkan sebagai Tamu'),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}