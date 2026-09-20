import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';

/// Ditampilkan sekali setelah login pertama kali (ditandai lewat SharedPreferences).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  static const _prefsKey = 'onboarding_completed';

  static Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.title, required this.description, required this.icon});
  final String title;
  final String description;
  final IconData icon;
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.document_scanner_outlined,
      title: 'Pindai teks apa saja',
      description:
          'Arahkan kamera ke tulisan buku, resep, label obat dan biarkan aplikasi membacanya untukmu.',
    ),
    _OnboardingSlide(
      icon: Icons.zoom_in,
      title: 'Perbesar atau dengarkan',
      description:
          'Pilih hasil ditampilkan dengan huruf besar (Zoom) atau dibacakan lewat suara (TTS).',
    ),
    _OnboardingSlide(
      icon: Icons.history,
      title: 'Semua tersimpan rapi',
      description:
          'Riwayat pemindaianmu tersimpan otomatis, mudah dibuka dan diputar ulang kapan saja.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingPage._prefsKey, true);
    widget.onFinished();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text('Lewati'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final slide = _slides[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon dgn animasi masuk (fade + scale) tiap pindah slide.
                      TweenAnimationBuilder<double>(
                        key: ValueKey(i),
                        tween: Tween(begin: 0.6, end: 1.0),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Transform.scale(scale: value, child: child),
                          );
                        },
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 80, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: i == _index ? 24 : 8,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.primary : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _next,
              child: Text(isLast ? 'Mulai' : 'Lanjut'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}