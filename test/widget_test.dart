// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campusconnect/main.dart';
import 'package:campusconnect/models/app_state.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Set up a mock SharedPreferences instance
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState(prefs);

    // Build our app and trigger a frame
    await tester.pumpWidget(CampusConnectApp(appState: appState));

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
