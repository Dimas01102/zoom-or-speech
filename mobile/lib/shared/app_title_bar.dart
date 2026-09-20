import 'package:flutter/material.dart';

/// Judul AppBar [logo] JELAS.
class AppTitleBar extends StatelessWidget {
  const AppTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/logo.png', height: 28, width: 28),
        const SizedBox(width: 8),
        const Text('JELAS'),
      ],
    );
  }
}