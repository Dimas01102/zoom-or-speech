import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App boots and shows a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: JelasApp()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}