import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campusconnect/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Integration Tests', () {
    testWidgets('Navigate through bottom navigation bar', (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Verify we're on the home screen
      expect(find.text('CampusConnect'), findsOneWidget);
      
      // Navigate to Classes screen
      await tester.tap(find.text('Classes'));
      await tester.pumpAndSettle();
      expect(find.text('Class Schedule'), findsOneWidget);
      
      // Navigate to Study Groups screen
      await tester.tap(find.text('Study Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Study Groups'), findsOneWidget);
      
      // Navigate to Events screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Campus Events'), findsOneWidget);
      
      // Navigate to Announcements screen
      await tester.tap(find.text('Announcements'));
      await tester.pumpAndSettle();
      expect(find.text('Campus Announcements'), findsOneWidget);
    });
    
    testWidgets('Create and view a class', (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to Classes screen
      await tester.tap(find.text('Classes'));
      await tester.pumpAndSettle();
      
      // Tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill in the class form
      await tester.enterText(find.byType(TextFormField).at(0), 'Introduction to Programming');
      await tester.enterText(find.byType(TextFormField).at(1), 'CS101');
      await tester.enterText(find.byType(TextFormField).at(2), 'Dr. Smith');
      await tester.enterText(find.byType(TextFormField).at(3), 'Room 101');
      
      // Save the class
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify the class was added
      expect(find.text('Introduction to Programming'), findsOneWidget);
      expect(find.text('CS101'), findsOneWidget);
    });
  });
}