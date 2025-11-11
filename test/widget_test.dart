import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_app/main.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Books'), findsOneWidget);
  });
}