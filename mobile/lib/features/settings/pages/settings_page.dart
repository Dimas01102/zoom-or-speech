import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final t = ref.read(appStringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.logout),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // AuthGate otomatis balik ke LoginPage begitu authStateChanges = null.
      await ref.read(authServiceProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(t.language, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'id', label: Text(t.indonesian)),
              ButtonSegment(value: 'en', label: Text(t.english)),
            ],
            selected: {setting.bahasa},
            onSelectionChanged: (selection) => controller.setBahasa(selection.first),
          ),
          const SizedBox(height: 32),
          Text(t.speechSpeed, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(t.speechSpeedDesc, style: Theme.of(context).textTheme.bodyMedium),
          Slider(
            value: setting.kecepatanSuara,
            min: 0.25,
            max: 1.0,
            divisions: 3,
            label: setting.kecepatanSuara.toStringAsFixed(2),
            activeColor: AppColors.secondary,
            onChanged: controller.setKecepatanSuara,
          ),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(t.logout, style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}