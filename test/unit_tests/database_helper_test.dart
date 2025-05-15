import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/utils/database_helper.dart';
import 'package:campusconnect/models/class_model.dart';
import 'package:campusconnect/models/event_model.dart';
import 'package:campusconnect/models/study_group_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  late DatabaseHelper dbHelper;
  
  setUpAll(() async {
    // Initialize FFI for testing
    sqfliteFfiInit();
    // Set the database factory to use the FFI implementation
    databaseFactory = databaseFactoryFfi;
    
    // Create a temporary directory for the test database
    final tempDir = await Directory.systemTemp.createTemp('db_test');
    final dbPath = join(tempDir.path, 'test.db');
    
    // Create a test instance of DatabaseHelper
    dbHelper = DatabaseHelper(name: 'test.db');
  });
  
  group('DatabaseHelper CRUD Operations', () {
    // Class model tests
    test('Class CRUD operations', () async {
      // Create a test class
      final testClass = ClassModel(
        id: 'test_class_1',
        courseCode: 'CS101',
        name: 'Introduction to Programming',
        professor: 'Dr. Smith',
        location: 'Room 101',
        dayOfWeek: 1,
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 30),
        notes: 'Test notes',
      );
      
      // Insert
      await dbHelper.insertClass(testClass);
      
      // Read
      final classes = await dbHelper.getClasses();
      expect(classes.length, 1);
      expect(classes[0].id, 'test_class_1');
      expect(classes[0].courseCode, 'CS101');
      
      // Update
      final updatedClass = ClassModel(
        id: testClass.id,
        courseCode: testClass.courseCode,
        courseName: testClass.courseName,
        professor: 'Dr. Johnson',
        location: 'Room 102',
        dayOfWeek: testClass.dayOfWeek,
        startTime: testClass.startTime,
        endTime: testClass.endTime,
        notes: testClass.notes,
      );
      await dbHelper.updateClass(updatedClass);
      
      final updatedClasses = await dbHelper.getClasses();
      expect(updatedClasses[0].professor, 'Dr. Johnson');
      expect(updatedClasses[0].location, 'Room 102');
      
      // Delete
      await dbHelper.deleteClass(testClass.id);
      final finalClasses = await dbHelper.getClasses();
      expect(finalClasses.length, 0);
    });
    
    // Event model tests
    test('Event CRUD operations', () async {
      // Create a test event
      final testEvent = EventModel(
        id: 'test_event_1',
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        category: 'Academic',
        isRsvped: false,
      );
      
      // Insert
      await dbHelper.insertEvent(testEvent);
      
      // Read
      final events = await dbHelper.getEvents();
      expect(events.length, 1);
      expect(events[0].id, 'test_event_1');
      expect(events[0].title, 'Test Event');
      
      // Update
      final updatedEvent = EventModel(
        id: testEvent.id,
        title: 'Updated Event',
        description: testEvent.description,
        location: testEvent.location,
        startTime: testEvent.startTime,
        endTime: testEvent.endTime,
        category: testEvent.category,
        isRsvped: true,
      );
      await dbHelper.updateEvent(updatedEvent);
      
      final updatedEvents = await dbHelper.getEvents();
      expect(updatedEvents[0].title, 'Updated Event');
      expect(updatedEvents[0].isRsvped, true);
      
      // Delete
      await dbHelper.deleteEvent(testEvent.id);
      final finalEvents = await dbHelper.getEvents();
      expect(finalEvents.length, 0);
    });
    
    // Study Group model tests
    test('Study Group CRUD operations', () async {
      final dateTime = DateTime.now().add(const Duration(days: 1));
      // Create a test study group
      final testGroup = StudyGroupModel(
        id: 'test_group_1',
        topic: 'Test Topic',
        courseCode: 'CS101',
        courseName: 'Introduction to Programming',
        location: 'Library',
        dateTime: dateTime,
        startTime: '14:00',
        endTime: '16:00',
        maxParticipants: 10,
        participants: ['Test User'],
        currentParticipants: 1,
        description: 'Test Description',
        organizer: 'Test User',
      );
      
      // Insert
      await dbHelper.insertStudyGroup(testGroup);
      
      // Read
      final groups = await dbHelper.getStudyGroups();
      expect(groups.length, 1);
      expect(groups[0].id, 'test_group_1');
      expect(groups[0].topic, 'Test Topic');
      
      // Update
      final updatedGroup = StudyGroupModel(
        id: testGroup.id,
        topic: 'Updated Topic',
        courseCode: testGroup.courseCode,
        courseName: testGroup.courseName,
        location: testGroup.location,
        dateTime: testGroup.dateTime,
        startTime: testGroup.startTime,
        endTime: testGroup.endTime,
        maxParticipants: testGroup.maxParticipants,
        participants: ['Test User', 'Another User'],
        currentParticipants: 2,
        description: testGroup.description,
        organizer: testGroup.organizer,
      );
      await dbHelper.updateStudyGroup(updatedGroup);
      
      final updatedGroups = await dbHelper.getStudyGroups();
      expect(updatedGroups[0].topic, 'Updated Topic');
      expect(updatedGroups[0].currentParticipants, 2);
      
      // Delete
      await dbHelper.deleteStudyGroup(testGroup.id);
      final finalGroups = await dbHelper.getStudyGroups();
      expect(finalGroups.length, 0);
    });
  });
}