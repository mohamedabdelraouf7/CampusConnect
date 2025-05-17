import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:campus_connect/utils/database_helper.dart';
import 'package:campus_connect/models/event_model.dart';
import 'package:campus_connect/models/class_model.dart';
import 'package:campus_connect/models/study_group_model.dart';

void main() {
  late DatabaseHelper db;

  setUp(() async {
    db = DatabaseHelper();
    await db.database; // Initialize database
    await db.clearDatabase(); // Clear tables before each test
  });

  tearDown(() async {
    await db.clearDatabase(); // Clear tables after each test
  });

  group('Database Tests', () {
    test('Insert and retrieve event', () async {
      final event = EventModel(
        id: 'test_event_1',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      await db.insertEvent(event);
      final events = await db.getEvents();
      
      expect(events.length, 1);
      expect(events.first.id, event.id);
      expect(events.first.title, event.title);
      
      print('✓ Test completed: Insert and retrieve event');
    });

    test('Insert and retrieve class', () async {
      final classModel = ClassModel(
        id: 'test_class_1',
        name: 'Test Class',
        courseCode: 'TEST101',
        professor: 'Dr. Test',
        location: 'Room 101',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        notes: 'Test notes',
      );

      await db.insertClass(classModel);
      final classes = await db.getClasses();
      
      expect(classes.length, 1);
      expect(classes.first.id, classModel.id);
      expect(classes.first.name, classModel.name);
      
      print('✓ Test completed: Insert and retrieve class');
    });

    test('Insert and retrieve study group', () async {
      final studyGroup = StudyGroupModel(
        id: 'test_group_1',
        topic: 'Test Topic',
        courseCode: 'TEST101',
        courseName: 'Test Course',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Library Room 1',
        maxParticipants: 5,
        participants: [],
        description: 'Test Description',
        createdBy: 'test@example.com',
      );

      await db.insertStudyGroup(studyGroup);
      final groups = await db.getStudyGroups();
      
      expect(groups.length, 1);
      expect(groups.first.id, studyGroup.id);
      expect(groups.first.topic, studyGroup.topic);
      
      print('✓ Test completed: Insert and retrieve study group');
    });

    test('Update event', () async {
      final event = EventModel(
        id: 'test_event_2',
        title: 'Original Title',
        description: 'Original Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Original Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      await db.insertEvent(event);
      
      final updatedEvent = event.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );
      
      await db.updateEvent(updatedEvent);
      final events = await db.getEvents();
      
      expect(events.length, 1);
      expect(events.first.title, 'Updated Title');
      expect(events.first.description, 'Updated Description');
      
      print('✓ Test completed: Update event');
    });

    test('Delete event', () async {
      final event = EventModel(
        id: 'test_event_3',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      await db.insertEvent(event);
      await db.deleteEvent(event.id);
      final events = await db.getEvents();
      
      expect(events, isEmpty);
      
      print('✓ Test completed: Delete event');
    });

    test('Multiple operations on same table', () async {
      // Insert multiple events
      final events = [
        EventModel(
          id: 'test_event_4',
          title: 'Event 1',
          description: 'Description 1',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          location: 'Location 1',
          category: 'Academic',
          maxAttendees: 10,
          attendees: [],
          imageUrl: null,
          organizer: 'test@example.com',
        ),
        EventModel(
          id: 'test_event_5',
          title: 'Event 2',
          description: 'Description 2',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          location: 'Location 2',
          category: 'Social',
          maxAttendees: 20,
          attendees: [],
          imageUrl: null,
          organizer: 'test@example.com',
        ),
      ];

      for (var event in events) {
        await db.insertEvent(event);
      }

      // Verify all events were inserted
      var retrievedEvents = await db.getEvents();
      expect(retrievedEvents.length, 2);

      // Update one event
      final updatedEvent = events[0].copyWith(title: 'Updated Event 1');
      await db.updateEvent(updatedEvent);

      // Delete one event
      await db.deleteEvent(events[1].id);

      // Verify final state
      retrievedEvents = await db.getEvents();
      expect(retrievedEvents.length, 1);
      expect(retrievedEvents.first.title, 'Updated Event 1');
      
      print('✓ Test completed: Multiple operations on same table');
    });

    test('Database transaction rollback', () async {
      // Start with empty database
      var events = await db.getEvents();
      expect(events, isEmpty);

      // Try to insert invalid event (should fail)
      try {
        await db.insertEvent(EventModel(
          id: '',
          title: '',
          description: 'Test Description',
          dateTime: DateTime.now().subtract(const Duration(days: 1)), // Past date
          location: 'Test Location',
          category: 'Academic',
          maxAttendees: 0, // Invalid max attendees
          attendees: [],
          imageUrl: null,
          organizer: '',
        ));
        fail('Should have thrown an error');
      } catch (e) {
        // Expected error
      }

      // Verify database is still empty
      events = await db.getEvents();
      expect(events, isEmpty);
      
      print('✓ Test completed: Database transaction rollback');
    });
  });
} 