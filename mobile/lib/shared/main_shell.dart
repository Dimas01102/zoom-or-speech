import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/history/pages/history_list_page.dart';
import '../features/output/pages/home_page.dart';
import '../features/scan/pages/camera_permission_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/tutorial/pages/tutorial_list_page.dart';
import '../features/auth/providers/auth_provider.dart';
import 'feature_tour.dart';
import 'login_required_dialog.dart';
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
    TutorialListPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FeatureTour.maybeShow(context);
    });
  }

  void _openCamera() {
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
          onPressed: _openCamera,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              onTap: () {
                // Tamu (anonymous) belum boleh buka Riwayat.
                final user = ref.read(authStateProvider).value;
                if (user != null && user.isAnonymous) {
                  showLoginRequiredDialog(context, t.notLoggedIn);
                  return;
                }
                setState(() => _index = 1);
              },
            ),
            const SizedBox(width: 40),
            _NavItem(
              key: TutorialKeys.navTutorial,
              icon: Icons.menu_book_outlined,
              label: t.tutorial,
              selected: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              key: TutorialKeys.navSettings,
              icon: Icons.settings_outlined,
              label: t.navSettings,
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
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