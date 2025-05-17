import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_connect/main.dart' as app;
import 'package:campus_connect/services/firebase_service.dart';
import 'package:campus_connect/models/event_model.dart';
import 'package:campus_connect/models/class_model.dart';
import 'package:campus_connect/models/study_group_model.dart';
import 'package:campus_connect/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Sync Tests', () {
    late FirebaseService firebaseService;
    late FirebaseAuth auth;
    late FirebaseDatabase database;
    late StreamSubscription<List<EventModel>> eventSubscription;
    late StreamSubscription<List<ClassModel>> classSubscription;
    late StreamSubscription<List<StudyGroupModel>> studyGroupSubscription;

    setUp(() async {
      // Initialize Firebase services
      firebaseService = FirebaseService();
      await firebaseService.initialize();
      auth = FirebaseAuth.instance;
      database = FirebaseDatabase.instance;

      // Clear test data before each test
      await _clearTestData();
    });

    tearDown(() async {
      // Cancel all subscriptions
      await eventSubscription.cancel();
      await classSubscription.cancel();
      await studyGroupSubscription.cancel();
      
      // Clear test data after each test
      await _clearTestData();
      
      // Sign out
      await auth.signOut();
    });

    testWidgets('Test real-time event synchronization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Set up event stream subscription
      List<EventModel> receivedEvents = [];
      eventSubscription = firebaseService.getEventsStream().listen((events) {
        receivedEvents = events;
      });

      // Create a test event
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: auth.currentUser?.email ?? 'test_user',
      );

      // Add event to Firebase
      await firebaseService.addOrUpdateEvent(event);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify event was synced
      expect(receivedEvents.any((e) => e.id == event.id), true);
      expect(receivedEvents.firstWhere((e) => e.id == event.id).title, 'Test Event');

      // Update event
      final updatedEvent = event.copyWith(
        title: 'Updated Test Event',
        description: 'Updated Description',
      );
      await firebaseService.addOrUpdateEvent(updatedEvent);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify update was synced
      expect(receivedEvents.firstWhere((e) => e.id == event.id).title, 'Updated Test Event');
      expect(receivedEvents.firstWhere((e) => e.id == event.id).description, 'Updated Description');

      // Delete event using the correct method
      await firebaseService.eventsRef().child(event.id).remove();

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify deletion was synced
      expect(receivedEvents.any((e) => e.id == event.id), false);
    });

    testWidgets('Test real-time class synchronization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Set up class stream subscription
      List<ClassModel> receivedClasses = [];
      classSubscription = firebaseService.getClassesStream().listen((classes) {
        receivedClasses = classes;
      });

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

      // Add class to Firebase
      await firebaseService.addOrUpdateClass(classModel);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify class was synced
      expect(receivedClasses.any((c) => c.id == classModel.id), true);
      expect(receivedClasses.firstWhere((c) => c.id == classModel.id).name, 'Test Class');

      // Update class
      final updatedClass = classModel.copyWith(
        name: 'Updated Test Class',
        location: 'Room 102',
      );
      await firebaseService.addOrUpdateClass(updatedClass);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify update was synced
      expect(receivedClasses.firstWhere((c) => c.id == classModel.id).name, 'Updated Test Class');
      expect(receivedClasses.firstWhere((c) => c.id == classModel.id).location, 'Room 102');

      // Delete class
      await firebaseService.deleteClass(classModel.id);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify deletion was synced
      expect(receivedClasses.any((c) => c.id == classModel.id), false);
    });

    testWidgets('Test real-time study group synchronization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Set up study group stream subscription
      List<StudyGroupModel> receivedGroups = [];
      studyGroupSubscription = firebaseService.getStudyGroupsStream().listen((groups) {
        receivedGroups = groups;
      });

      // Create a test study group
      final studyGroup = StudyGroupModel(
        id: 'test_group_${DateTime.now().millisecondsSinceEpoch}',
        topic: 'Test Study Group',
        courseCode: 'CS101',
        courseName: 'CS101',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Library Room 3',
        maxParticipants: 5,
        participants: [],
        createdBy: auth.currentUser?.email ?? 'test_user',
      );

      // Add study group to Firebase
      await firebaseService.addOrUpdateStudyGroup(studyGroup);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify study group was synced
      expect(receivedGroups.any((g) => g.id == studyGroup.id), true);
      expect(receivedGroups.firstWhere((g) => g.id == studyGroup.id).topic, 'Test Study Group');

      // Update study group
      final updatedGroup = studyGroup.copyWith(
        topic: 'Updated Study Group',
        location: 'Library Room 4',
        participants: [auth.currentUser?.email ?? 'test_user'],
      );
      await firebaseService.addOrUpdateStudyGroup(updatedGroup);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify update was synced
      expect(receivedGroups.firstWhere((g) => g.id == studyGroup.id).topic, 'Updated Study Group');
      expect(receivedGroups.firstWhere((g) => g.id == studyGroup.id).location, 'Library Room 4');
      expect(receivedGroups.firstWhere((g) => g.id == studyGroup.id).participants.length, 1);

      // Delete study group
      await firebaseService.deleteStudyGroup(studyGroup.id);

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify deletion was synced
      expect(receivedGroups.any((g) => g.id == studyGroup.id), false);
    });

    testWidgets('Test concurrent updates handling', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Set up event stream subscription
      List<EventModel> receivedEvents = [];
      eventSubscription = firebaseService.getEventsStream().listen((events) {
        receivedEvents = events;
      });

      // Create initial event
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: auth.currentUser?.email ?? 'test_user',
      );

      await firebaseService.addOrUpdateEvent(event);

      // Simulate concurrent updates
      final updates = [
        event.copyWith(title: 'Update 1'),
        event.copyWith(description: 'Update 2'),
        event.copyWith(location: 'Update 3'),
      ];

      // Apply updates concurrently
      await Future.wait(updates.map((e) => firebaseService.addOrUpdateEvent(e)));

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify the last update was applied
      final syncedEvent = receivedEvents.firstWhere((e) => e.id == event.id);
      expect(syncedEvent.title, 'Update 1');
      expect(syncedEvent.description, 'Update 2');
      expect(syncedEvent.location, 'Update 3');
    });

    testWidgets('Test offline synchronization', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await _signIn(tester);
      await tester.pumpAndSettle();

      // Set up event stream subscription
      List<EventModel> receivedEvents = [];
      eventSubscription = firebaseService.getEventsStream().listen((events) {
        receivedEvents = events;
      });

      // Create a test event
      final event = EventModel(
        id: 'test_event_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Offline Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: auth.currentUser?.email ?? 'test_user',
      );

      // Simulate offline mode by disabling network
      await database.goOffline();

      // Try to add event while offline
      await firebaseService.addOrUpdateEvent(event);

      // Verify event is not in Firebase yet
      expect(receivedEvents.any((e) => e.id == event.id), false);

      // Re-enable network
      await database.goOnline();

      // Wait for sync
      await Future.delayed(const Duration(seconds: 2));

      // Verify event was synced once online
      expect(receivedEvents.any((e) => e.id == event.id), true);
      expect(receivedEvents.firstWhere((e) => e.id == event.id).title, 'Offline Test Event');
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

Future<void> _clearTestData() async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref();
  
  // Clear test data from all relevant paths
  await Future.wait([
    ref.child('events').orderByChild('organizer').equalTo('test_user').get().then((snapshot) {
      final updates = <String, dynamic>{};
      snapshot.children.forEach((child) {
        updates['events/${child.key}'] = null;
      });
      return ref.update(updates);
    }),
    ref.child('classes').orderByChild('professor').equalTo('Test Professor').get().then((snapshot) {
      final updates = <String, dynamic>{};
      snapshot.children.forEach((child) {
        updates['classes/${child.key}'] = null;
      });
      return ref.update(updates);
    }),
    ref.child('study_groups').orderByChild('createdBy').equalTo('test_user').get().then((snapshot) {
      final updates = <String, dynamic>{};
      snapshot.children.forEach((child) {
        updates['study_groups/${child.key}'] = null;
      });
      return ref.update(updates);
    }),
  ]);
} 