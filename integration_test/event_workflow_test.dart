import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_connect/main.dart' as app;
import 'package:campus_connect/models/event_model.dart';
import 'package:campus_connect/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Event Workflow Tests', () {
    late FirebaseService firebaseService;
    late FirebaseAuth auth;

    setUpAll(() async {
      firebaseService = FirebaseService();
      auth = FirebaseAuth.instance;
      
      // Sign in with test account
      await auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'testpassword123',
      );
    });

    tearDownAll(() async {
      // Clean up test data
      await auth.signOut();
    });

    testWidgets('Complete event creation workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Tap create event button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill in event details
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test Integration Event',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Test Description for Integration',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Test Location',
      );
      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('Academic'));
      await tester.pumpAndSettle();

      // Set max attendees
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '10',
      );
      await tester.pumpAndSettle();

      // Save event
      await tester.tap(find.text('Create Event'));
      await tester.pumpAndSettle();

      // Verify event appears in list
      expect(find.text('Test Integration Event'), findsOneWidget);
      expect(find.text('Test Description for Integration'), findsOneWidget);
    });

    testWidgets('Event update workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Find and tap the event to edit
      await tester.tap(find.text('Test Integration Event'));
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Update event details
      await tester.enterText(
        find.byType(TextFormField).first,
        'Updated Integration Event',
      );
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify updates
      expect(find.text('Updated Integration Event'), findsOneWidget);
      expect(find.text('Test Integration Event'), findsNothing);
    });

    testWidgets('Event attendance workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Find and tap the event
      await tester.tap(find.text('Updated Integration Event'));
      await tester.pumpAndSettle();

      // Tap attend button
      await tester.tap(find.text('Attend'));
      await tester.pumpAndSettle();

      // Verify attendance status
      expect(find.text('You are attending'), findsOneWidget);
      expect(find.text('Attend'), findsNothing);

      // Cancel attendance
      await tester.tap(find.text('Cancel Attendance'));
      await tester.pumpAndSettle();

      // Verify cancellation
      expect(find.text('Attend'), findsOneWidget);
      expect(find.text('You are attending'), findsNothing);
    });

    testWidgets('Event filtering and search', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Open filter menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Select category filter
      await tester.tap(find.text('Academic'));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.text('Updated Integration Event'), findsOneWidget);

      // Clear filters
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // Search for event
      await tester.enterText(
        find.byType(TextField).first,
        'Updated Integration',
      );
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.text('Updated Integration Event'), findsOneWidget);
    });

    testWidgets('Event deletion workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Events tab
      await tester.tap(find.byIcon(Icons.event));
      await tester.pumpAndSettle();

      // Find and tap the event to delete
      await tester.tap(find.text('Updated Integration Event'));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify event is removed
      expect(find.text('Updated Integration Event'), findsNothing);
    });
  });
} 