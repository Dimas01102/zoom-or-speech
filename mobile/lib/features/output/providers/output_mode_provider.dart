import 'package:flutter_riverpod/legacy.dart'; // StateProvider 

/// utk menentukan mau diarahkan ke ZoomResultPage atau TtsResultPage.
enum OutputMode { zoom, speech }

final selectedOutputModeProvider = StateProvider<OutputMode>((ref) {
  return OutputMode.zoom;
});