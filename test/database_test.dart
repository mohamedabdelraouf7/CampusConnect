import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/utils/database_helper.dart';
import '../lib/models/class_model.dart';
import '../lib/models/event_model.dart';
import '../lib/models/study_group_model.dart';
import 'package:flutter/material.dart';

void main() {
  // Initialize sqflite_ffi for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;

  setUp(() async {
    // Create a new in-memory database for each test
    dbHelper = DatabaseHelper(name: ':memory:');
    await dbHelper.database;
  });

  tearDown(() async {
    // Clean up after each test
    await dbHelper.clearDatabase();
  });

  group('Class CRUD Operations', () {
    test('Insert and retrieve a class', () async {
      final classModel = ClassModel(
        id: '1',
        name: 'Introduction to Programming',
        courseCode: 'CS101',
        professor: 'Dr. Smith',
        location: 'Room 101',
        dayOfWeek: 1, // Monday
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        notes: 'First class of the semester',
      );

      // Insert the class
      await dbHelper.insertClass(classModel);

      // Retrieve all classes
      final classes = await dbHelper.getClasses();

      // Verify the results
      expect(classes.length, 1);
      expect(classes[0].id, classModel.id);
      expect(classes[0].name, classModel.name);
      expect(classes[0].courseCode, classModel.courseCode);
      expect(classes[0].professor, classModel.professor);
      expect(classes[0].location, classModel.location);
      expect(classes[0].dayOfWeek, classModel.dayOfWeek);
      expect(classes[0].startTime.hour, classModel.startTime.hour);
      expect(classes[0].startTime.minute, classModel.startTime.minute);
      expect(classes[0].endTime.hour, classModel.endTime.hour);
      expect(classes[0].endTime.minute, classModel.endTime.minute);
      expect(classes[0].notes, classModel.notes);
    });

    test('Update a class', () async {
      // First insert a class
      final classModel = ClassModel(
        id: '1',
        name: 'Introduction to Programming',
        courseCode: 'CS101',
        professor: 'Dr. Smith',
        location: 'Room 101',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
      );

      await dbHelper.insertClass(classModel);

      // Update the class
      final updatedClass = classModel.copyWith(
        location: 'Room 202',
        professor: 'Dr. Johnson',
      );

      await dbHelper.updateClass(updatedClass);

      // Retrieve and verify
      final classes = await dbHelper.getClasses();
      expect(classes.length, 1);
      expect(classes[0].location, 'Room 202');
      expect(classes[0].professor, 'Dr. Johnson');
    });

    test('Delete a class', () async {
      // Insert a class
      final classModel = ClassModel(
        id: '1',
        name: 'Introduction to Programming',
        courseCode: 'CS101',
        professor: 'Dr. Smith',
        location: 'Room 101',
        dayOfWeek: 1,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
      );

      await dbHelper.insertClass(classModel);

      // Delete the class
      await dbHelper.deleteClass(classModel.id);

      // Verify deletion
      final classes = await dbHelper.getClasses();
      expect(classes.length, 0);
    });
  });

  group('Event CRUD Operations', () {
    // Helper function to create a future date
    DateTime getFutureDate() {
      return DateTime.now().add(const Duration(days: 1));
    }

    test('Insert and retrieve an event', () async {
      final eventModel = EventModel(
        id: 'test_event_1',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: getFutureDate(),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      // Insert the event
      await dbHelper.insertEvent(eventModel);

      // Retrieve all events
      final events = await dbHelper.getEvents();

      // Verify the results
      expect(events.length, 1);
      expect(events[0].id, eventModel.id);
      expect(events[0].title, eventModel.title);
      expect(events[0].description, eventModel.description);
      expect(events[0].location, eventModel.location);
      expect(events[0].dateTime, eventModel.dateTime);
      expect(events[0].organizer, eventModel.organizer);
      expect(events[0].attendees, eventModel.attendees);
      expect(events[0].maxAttendees, eventModel.maxAttendees);
    });

    test('Update an event', () async {
      final eventModel = EventModel(
        id: 'test_event_2',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: getFutureDate(),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      await dbHelper.insertEvent(eventModel);

      // Update the event
      final updatedEvent = eventModel.copyWith(
        location: 'Main Auditorium',
        description: 'Updated description',
      );

      await dbHelper.updateEvent(updatedEvent);

      // Retrieve and verify
      final events = await dbHelper.getEvents();
      expect(events.length, 1);
      expect(events[0].location, 'Main Auditorium');
      expect(events[0].description, 'Updated description');
    });

    test('Delete an event', () async {
      final eventModel = EventModel(
        id: 'test_event_3',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: getFutureDate(),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: [],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      await dbHelper.insertEvent(eventModel);

      // Delete the event
      await dbHelper.deleteEvent(eventModel.id);

      // Verify deletion
      final events = await dbHelper.getEvents();
      expect(events.length, 0);
    });
  });

  group('Study Group CRUD Operations', () {
    test('Insert and retrieve a study group', () async {
      final studyGroupModel = StudyGroupModel(
        id: '1',
        topic: 'Data Structures Review',
        courseCode: 'CS201',
        courseName: 'Data Structures and Algorithms',
        description: 'Review session for midterm',
        location: 'Library Room 3',
        dateTime: DateTime(2024, 3, 20, 14, 0),
        createdBy: 'student1',
        participants: ['student1', 'student2'],
        maxParticipants: 5,
      );

      // Insert the study group
      await dbHelper.insertStudyGroup(studyGroupModel);

      // Retrieve all study groups
      final studyGroups = await dbHelper.getStudyGroups();

      // Verify the results
      expect(studyGroups.length, 1);
      expect(studyGroups[0].id, studyGroupModel.id);
      expect(studyGroups[0].topic, studyGroupModel.topic);
      expect(studyGroups[0].courseCode, studyGroupModel.courseCode);
      expect(studyGroups[0].courseName, studyGroupModel.courseName);
      expect(studyGroups[0].description, studyGroupModel.description);
      expect(studyGroups[0].location, studyGroupModel.location);
      expect(studyGroups[0].dateTime, studyGroupModel.dateTime);
      expect(studyGroups[0].createdBy, studyGroupModel.createdBy);
      expect(studyGroups[0].participants, studyGroupModel.participants);
      expect(studyGroups[0].maxParticipants, studyGroupModel.maxParticipants);
    });

    test('Update a study group', () async {
      // First insert a study group
      final studyGroupModel = StudyGroupModel(
        id: '1',
        topic: 'Data Structures Review',
        courseCode: 'CS201',
        courseName: 'Data Structures and Algorithms',
        description: 'Review session for midterm',
        location: 'Library Room 3',
        dateTime: DateTime(2024, 3, 20, 14, 0),
        createdBy: 'student1',
        participants: ['student1'],
        maxParticipants: 5,
      );

      await dbHelper.insertStudyGroup(studyGroupModel);

      // Update the study group
      final updatedGroup = studyGroupModel.copyWith(
        location: 'Library Room 5',
        description: 'Updated review session',
        participants: ['student1', 'student2', 'student3'],
      );

      await dbHelper.updateStudyGroup(updatedGroup);

      // Retrieve and verify
      final studyGroups = await dbHelper.getStudyGroups();
      expect(studyGroups.length, 1);
      expect(studyGroups[0].location, 'Library Room 5');
      expect(studyGroups[0].description, 'Updated review session');
      expect(studyGroups[0].participants.length, 3);
    });

    test('Delete a study group', () async {
      // Insert a study group
      final studyGroupModel = StudyGroupModel(
        id: '1',
        topic: 'Data Structures Review',
        courseCode: 'CS201',
        courseName: 'Data Structures and Algorithms',
        description: 'Review session for midterm',
        location: 'Library Room 3',
        dateTime: DateTime(2024, 3, 20, 14, 0),
        createdBy: 'student1',
        participants: ['student1'],
        maxParticipants: 5,
      );

      await dbHelper.insertStudyGroup(studyGroupModel);

      // Delete the study group
      await dbHelper.deleteStudyGroup(studyGroupModel.id);

      // Verify deletion
      final studyGroups = await dbHelper.getStudyGroups();
      expect(studyGroups.length, 0);
    });
  });
} 