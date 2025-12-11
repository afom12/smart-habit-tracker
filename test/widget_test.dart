// This is a basic Flutter widget test for Smart Habit Tracker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:afomi_habit_tracker/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartHabitTrackerApp(),
      ),
    );

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app title is present (either in splash or home screen)
    // The app should show "Smart Habit Tracker" somewhere
    expect(find.text('Smart Habit Tracker'), findsWidgets);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SmartHabitTrackerApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the app title is set correctly
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Smart Habit Tracker');
  });
}
