import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_connect/main.dart' as app;
import 'package:campus_connect/services/notification_service.dart';
import 'package:campus_connect/models/event_model.dart';
import 'package:campus_connect/models/class_model.dart';
import 'package:campus_connect/models/study_group_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Tests', () {
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin notificationsPlugin;

    setUp(() async {
      // Initialize notification service
      notificationService = NotificationService();
      notificationsPlugin = notificationService.flutterLocalNotificationsPlugin;
      await notificationService.init();
    });

    testWidgets('Test immediate notification delivery', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Show an immediate notification
      await notificationService.showRealTimeAlert(
        title: 'Test Alert',
        body: 'This is a test notification',
        payload: 'test_payload',
      );

      // Wait for notification to be delivered
      await Future.delayed(const Duration(seconds: 1));

      // Verify notification was shown
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 0); // Immediate notifications don't stay pending
    });

    testWidgets('Test scheduled event reminder', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Create a test event for 1 minute in the future
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test_user',
      );

      // Schedule notification for the event
      await notificationService.scheduleEventReminder(event);

      // Verify notification was scheduled
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Event Reminder: Test Event');
    });

    testWidgets('Test class reminder scheduling', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Create a test class
      final classModel = ClassModel(
        id: 'test_class_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Class',
        courseCode: 'CS101',
        professor: 'Test Professor',
        location: 'Room 101',
        dayOfWeek: DateTime.now().weekday,
        startTime: TimeOfDay.now(),
        endTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
        notes: '',
      );

      // Schedule class reminder
      await notificationService.scheduleClassReminders(classModel);

      // Verify notification was scheduled
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Class Reminder: Test Class');
    });

    testWidgets('Test study group reminder', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Create a test study group
      final studyGroup = StudyGroupModel(
        id: 'test_group_${DateTime.now().millisecondsSinceEpoch}',
        topic: 'Test Study Group',
        courseCode: 'CS101',
        courseName: 'CS101',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(minutes: 30)),
        location: 'Library Room 3',
        maxParticipants: 5,
        participants: [],
        createdBy: 'test_user',
      );

      // Schedule study group reminder
      await notificationService.scheduleStudyGroupReminder(studyGroup, 15); // 15 minutes before

      // Verify notification was scheduled
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.first.title, 'Study Group Reminder: Test Study Group');
    });

    testWidgets('Test notification cancellation', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Create and schedule a test event
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test_user',
      );

      // Schedule notification
      await notificationService.scheduleEventReminder(event);

      // Verify notification was scheduled
      var pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);

      // Cancel the notification
      await notificationService.cancelNotification(event.id.hashCode);

      // Verify notification was cancelled
      pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 0);
    });

    testWidgets('Test multiple notifications', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Create multiple events with different times
      final events = List.generate(3, (index) => EventModel(
        id: 'test_event_$index',
        title: 'Test Event $index',
        description: 'Test Description',
        dateTime: DateTime.now().add(Duration(minutes: (index + 1) * 5)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test_user',
      ));

      // Schedule notifications for all events
      for (var event in events) {
        await notificationService.scheduleEventReminder(event);
      }

      // Verify all notifications were scheduled
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 3);

      // Cancel all notifications
      await notificationService.cancelAllNotifications();

      // Verify all notifications were cancelled
      final remainingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(remainingNotifications.length, 0);
    });

    testWidgets('Test notification preferences', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Get initial preferences
      final initialPreferences = notificationService.preferences;

      // Verify default preferences
      expect(initialPreferences.enableEventNotifications, true);
      expect(initialPreferences.enableClassNotifications, true);
      expect(initialPreferences.enableTaskNotifications, true);

      // Test notification delivery with preferences
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test_user',
      );

      // Schedule notification
      await notificationService.scheduleEventReminder(event);

      // Verify notification was scheduled
      final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
      expect(pendingNotifications.length, 1);
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