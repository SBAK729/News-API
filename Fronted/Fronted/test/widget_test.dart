// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news/main.dart';

void main() {
  // Setup mock shared preferences
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build mock SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Verify that our app starts with the correct title
    expect(find.text('News Hub Ultra'), findsOneWidget);
    
    // Verify that home screen elements are present
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('Home screen displays news categories', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Verify category chips are present
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);
  });

  testWidgets('Navigation to search screen works', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Tap on search icon
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify we're on search screen
    expect(find.byType(TextField), findsOneWidget);
  });
}
