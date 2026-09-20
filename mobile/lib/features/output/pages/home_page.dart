import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/app_title_bar.dart';
import '../../../shared/tutorial_keys.dart';
import '../../scan/pages/camera_permission_page.dart';
import '../providers/output_mode_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _selectModeAndScan(BuildContext context, WidgetRef ref, OutputMode mode) {
    ref.read(selectedOutputModeProvider.notifier).state = mode;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraPermissionPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const AppTitleBar()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.homeHeadline, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                t.homeSubtitle,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 170,
                          child: _ModeCard(
                            key: TutorialKeys.zoomButton,
                            icon: Icons.zoom_in,
                            label: t.zoom,
                            description: t.zoomDesc,
                            color: AppColors.primary,
                            onTap: () => _selectModeAndScan(context, ref, OutputMode.zoom),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 170,
                          child: _ModeCard(
                            key: TutorialKeys.suaraButton,
                            icon: Icons.volume_up,
                            label: t.suara,
                            description: t.suaraDesc,
                            color: AppColors.secondary,
                            onTap: () => _selectModeAndScan(context, ref, OutputMode.speech),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}