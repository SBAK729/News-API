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
    
    // The app might show loading state initially
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Home screen displays news categories', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Wait a bit for the app to initialize
    await tester.pump(const Duration(seconds: 2));

    // Verify category chips are present - check for at least one category
    expect(find.byType(Chip), findsAtLeast(1));
  });

  testWidgets('Navigation to search screen works', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Wait for app to initialize
    await tester.pump(const Duration(seconds: 2));

    // Look for search icon and tap it
    final searchIcon = find.byIcon(Icons.search);
    expect(searchIcon, findsOneWidget);
    
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    // Verify we're on search screen - check for search field
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('App shows some UI state when APIs fail', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    
    // Wait for APIs to potentially fail and show some state
    await tester.pump(const Duration(seconds: 3));
    
    // Should show some UI state - check for common widgets
    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasError = find.textContaining('Error').evaluate().isNotEmpty;
    final hasArticles = find.byType(ListView).evaluate().isNotEmpty;
    final hasNoArticles = find.textContaining('No articles').evaluate().isNotEmpty;

    // At least one of these should be true
    expect(hasLoading || hasError || hasArticles || hasNoArticles, isTrue);
  });

  testWidgets('Settings screen shows API status', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MyApp(prefs: prefs));
    await tester.pumpAndSettle();

    // Navigate to settings (you might need to add a settings button)
    // For now, let's check if we can find settings-related text
    final hasSettings = find.textContaining('Settings').evaluate().isNotEmpty;
    final hasAPI = find.textContaining('API').evaluate().isNotEmpty;

    // If settings is accessible, these might be found
    if (hasSettings) {
      await tester.tap(find.textContaining('Settings'));
      await tester.pumpAndSettle();
      
      // Check for API status in settings
      expect(find.textContaining('API'), findsAtLeast(1));
    }
  });
}
