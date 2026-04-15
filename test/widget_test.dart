import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aisend/main.dart';

void main() {
  testWidgets('AiSend app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiSendApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
