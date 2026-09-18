import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_task_2/main.dart';
import 'package:flutter_task_2/logic/theme_provider.dart';

void main() {
  testWidgets('App initialization widget smoke test', (WidgetTester tester) async {
    // Set mock shared preferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Pump app with ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );

    // Verify loading screen is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Allow async initialization to settle (generous timeout for CI)
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // After settling, either login or main layout should be shown
    final loginOrMain =
        find.text('Sign In').evaluate().isNotEmpty ||
        find.text('Enterprise Nexus').evaluate().isNotEmpty;
    expect(loginOrMain, isTrue);
  });
}
