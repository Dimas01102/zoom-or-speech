import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'tutorial_keys.dart';

class FeatureTour {
  FeatureTour._();

  static const _prefsKey = 'feature_tour_completed';

  static Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  static Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  static Future<void> maybeShow(BuildContext context) async {
    if (await hasCompleted()) return;
    if (!context.mounted) return;

    final targets = <TargetFocus>[
      _target(
        TutorialKeys.cameraButton,
        'Kamera',
        'Tekan ini lalu foto teksnya. Setelah itu pilih icon Zoom untuk memperbesar atau icon Suara untuk dibacakan.',
      ),
      _target(
        TutorialKeys.scanFab,
        'Tombol Scan',
        'Akses cepat: tekan ini kapan saja untuk langsung membuka kamera.',
      ),
      _target(
        TutorialKeys.navHistory,
        'Riwayat',
        'Semua hasil scan kamu sebelumnya tersimpan & bisa diputar ulang di sini.',
      ),
      _target(
        TutorialKeys.navTutorial,
        'Tutorial',
        'Panduan singkat cara memakai aplikasi, lengkap dengan langkah-langkahnya.',
      ),
      _target(
        TutorialKeys.navSettings,
        'Pengaturan',
        'Atur bahasa dan kecepatan suara di sini.',
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black87,
      textSkip: 'Lewati',
      onFinish: _markCompleted,
      onSkip: () {
        _markCompleted();
        return true;
      },
    ).show(context: context);
  }

  static TargetFocus _target(GlobalKey key, String title, String desc) {
    return TargetFocus(
      identify: title,
      keyTarget: key,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(desc, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}