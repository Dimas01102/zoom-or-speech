import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ZoomOrSpeechApp());
}

class ZoomOrSpeechApp extends StatelessWidget {
  const ZoomOrSpeechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zoom or Speech',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zoom or Speech'),
        ),
        body: const Center(
          child: Text('Firebase Connected'),
        ),
      ),
    );
  }
}