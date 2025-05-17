// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_connect/main.dart';
import 'package:campus_connect/models/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'test_helpers.dart';
import 'widget_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockPrefs;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    //await setupFirebaseForTesting();
  });

  setUp(() async {
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Create a mock AppState
    final appState = AppState(mockPrefs);

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: CampusConnectApp(appState: appState),
      ),
    );

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
