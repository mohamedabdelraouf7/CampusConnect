import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_connect/main.dart' as app;
import 'package:campus_connect/models/class_model.dart';
import 'package:campus_connect/models/event_model.dart';
import 'package:campus_connect/models/study_group_model.dart';
import 'package:campus_connect/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Test event feed interactions', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in (assuming test user credentials)
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Test creating a new event
      await _testCreateEvent(tester);

      // Test event details view
      await _testEventDetails(tester);

      // Test event filtering
      await _testEventFiltering(tester);
    });

    testWidgets('Test class schedule interactions', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Navigate to Classes tab
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Test adding a new class
      await _testAddClass(tester);

      // Test class details view
      await _testClassDetails(tester);

      // Test class schedule view
      await _testScheduleView(tester);
    });

    testWidgets('Test study group interactions', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Navigate to Study Groups tab
      await tester.tap(find.byIcon(Icons.group));
      await tester.pumpAndSettle();

      // Test creating a study group
      await _testCreateStudyGroup(tester);

      // Test study group details
      await _testStudyGroupDetails(tester);

      // Test joining a study group
      await _testJoinStudyGroup(tester);
    });
  });
}

Future<void> _signIn(WidgetTester tester) async {
  // Find and fill email field
  final emailField = find.byType(TextFormField).first;
  await tester.enterText(emailField, 'test@example.com');
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextFormField).last;
  await tester.enterText(passwordField, 'testpassword123');
  await tester.pumpAndSettle();

  // Tap sign in button
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
}

Future<void> _testCreateEvent(WidgetTester tester) async {
  // Tap add event button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill event details
  await tester.enterText(find.byType(TextFormField).at(0), 'Test Event');
  await tester.enterText(find.byType(TextFormField).at(1), 'Test Location');
  await tester.enterText(find.byType(TextFormField).at(2), 'Test Description');
  
  // Select date and time (you'll need to implement date/time picker interaction)
  // This is a simplified version - you'll need to adapt based on your date picker implementation
  await tester.tap(find.byIcon(Icons.calendar_today));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Submit the form
  await tester.tap(find.text('Create Event'));
  await tester.pumpAndSettle();

  // Verify event was created
  expect(find.text('Test Event'), findsOneWidget);
}

Future<void> _testEventDetails(WidgetTester tester) async {
  // Tap on an event to view details
  await tester.tap(find.text('Test Event'));
  await tester.pumpAndSettle();

  // Verify event details are displayed
  expect(find.text('Test Location'), findsOneWidget);
  expect(find.text('Test Description'), findsOneWidget);
}

Future<void> _testEventFiltering(WidgetTester tester) async {
  // Open filter menu
  await tester.tap(find.byIcon(Icons.filter_list));
  await tester.pumpAndSettle();

  // Select a category
  await tester.tap(find.text('Academic'));
  await tester.pumpAndSettle();

  // Verify filtered results
  // Add appropriate expectations based on your filtering implementation
}

Future<void> _testAddClass(WidgetTester tester) async {
  // Tap add class button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill class details
  await tester.enterText(find.byType(TextFormField).at(0), 'Test Class');
  await tester.enterText(find.byType(TextFormField).at(1), 'CS101');
  await tester.enterText(find.byType(TextFormField).at(2), 'Room 101');
  
  // Select day and time
  await tester.tap(find.byIcon(Icons.access_time));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Submit the form
  await tester.tap(find.text('Add Class'));
  await tester.pumpAndSettle();

  // Verify class was added
  expect(find.text('Test Class'), findsOneWidget);
}

Future<void> _testClassDetails(WidgetTester tester) async {
  // Tap on a class to view details
  await tester.tap(find.text('Test Class'));
  await tester.pumpAndSettle();

  // Verify class details are displayed
  expect(find.text('CS101'), findsOneWidget);
  expect(find.text('Room 101'), findsOneWidget);
}

Future<void> _testScheduleView(WidgetTester tester) async {
  // Switch to weekly view
  await tester.tap(find.byIcon(Icons.view_week));
  await tester.pumpAndSettle();

  // Verify schedule is displayed
  expect(find.byType(TableCalendar), findsOneWidget);
}

Future<void> _testCreateStudyGroup(WidgetTester tester) async {
  // Tap create study group button
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill study group details
  await tester.enterText(find.byType(TextFormField).at(0), 'Test Study Group');
  await tester.enterText(find.byType(TextFormField).at(1), 'CS101 Study Group');
  await tester.enterText(find.byType(TextFormField).at(2), 'Library Room 3');
  
  // Select date and time
  await tester.tap(find.byIcon(Icons.calendar_today));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Submit the form
  await tester.tap(find.text('Create Study Group'));
  await tester.pumpAndSettle();

  // Verify study group was created
  expect(find.text('Test Study Group'), findsOneWidget);
}

Future<void> _testStudyGroupDetails(WidgetTester tester) async {
  // Tap on a study group to view details
  await tester.tap(find.text('Test Study Group'));
  await tester.pumpAndSettle();

  // Verify study group details are displayed
  expect(find.text('CS101 Study Group'), findsOneWidget);
  expect(find.text('Library Room 3'), findsOneWidget);
}

Future<void> _testJoinStudyGroup(WidgetTester tester) async {
  // Find and tap join button on a study group
  await tester.tap(find.byIcon(Icons.person_add));
  await tester.pumpAndSettle();

  // Verify join confirmation dialog
  expect(find.text('Join Study Group'), findsOneWidget);
  
  // Confirm joining
  await tester.tap(find.text('Join'));
  await tester.pumpAndSettle();

  // Verify joined status
  expect(find.byIcon(Icons.check_circle), findsOneWidget);
} 