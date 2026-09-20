import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/history/pages/history_list_page.dart';
import '../features/output/pages/home_page.dart';
import '../features/output/providers/output_mode_provider.dart';
import '../features/scan/pages/camera_permission_page.dart';
import '../features/settings/pages/settings_page.dart';
import 'feature_tour.dart';
import 'tutorial_keys.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _pages = [
    HomePage(),
    HistoryListPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Tur fitur (coach mark) utk user baru sekali aja, setelah frame
    // pertama selesai render supaya key target widget-nya udah ada ukurannya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FeatureTour.maybeShow(context);
    });
  }

  void _openScanModeSheet(BuildContext context) {
    final t = ref.read(appStringsProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.chooseModeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ScanModeOption(
                      icon: Icons.zoom_in,
                      label: t.zoom,
                      color: AppColors.primary,
                      onTap: () => _startScan(sheetContext, OutputMode.zoom),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ScanModeOption(
                      icon: Icons.volume_up,
                      label: t.suara,
                      color: AppColors.secondary,
                      onTap: () => _startScan(sheetContext, OutputMode.speech),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startScan(BuildContext sheetContext, OutputMode mode) {
    ref.read(selectedOutputModeProvider.notifier).state = mode;
    Navigator.of(sheetContext).pop(); // tutup bottom sheet dulu
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraPermissionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appStringsProvider);

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: SizedBox(
        key: TutorialKeys.scanFab,
        height: 64,
        width: 64,
        child: FloatingActionButton(
          elevation: 4,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          onPressed: () => _openScanModeSheet(context),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: t.navHome,
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              key: TutorialKeys.navHistory,
              icon: Icons.history,
              label: t.navHistory,
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 48), // ruang kosong utk notch tombol scan
            _NavItem(
              key: TutorialKeys.navSettings,
              icon: Icons.settings_outlined,
              label: t.navSettings,
              selected: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanModeOption extends StatelessWidget {
  const _ScanModeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}