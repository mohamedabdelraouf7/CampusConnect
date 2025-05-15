import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/services/firebase_service.dart';
import 'package:campusconnect/models/study_group_model.dart';
import 'package:campusconnect/models/event_model.dart';
import 'package:campusconnect/models/announcement_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference, DataSnapshot, DatabaseEvent])
import 'firebase_service_test.mocks.dart';

void main() {
  late FirebaseService firebaseService;
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockReference;
  
  setUp(() {
    mockDatabase = MockFirebaseDatabase();
    mockReference = MockDatabaseReference();
    
    // Setup the mock behavior
    when(mockDatabase.ref(any)).thenReturn(mockReference);
    when(mockReference.child(any)).thenReturn(mockReference);
    
    // Create a test instance with the mock
    firebaseService = FirebaseService(database: mockDatabase);
  });
  
  group('Firebase Service Tests', () {
    test('Study Group sync operations', () async {
      // Setup mock data
      final mockSnapshot = MockDataSnapshot();
      final mockEvent = MockDatabaseEvent();
      final testDate = DateTime.now();
      
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn({
        'group1': {
          'id': 'group1',
          'topic': 'Test Topic',
          'courseCode': 'CS101',
          'courseName': 'Introduction to Programming',
          'location': 'Library',
          'dateTime': testDate.millisecondsSinceEpoch,
          'startTime': '14:00',
          'endTime': '16:00',
          'maxParticipants': 10,
          'participants': ['Test User'],
          'currentParticipants': 1,
          'description': 'Test Description',
          'organizer': 'Test User',
        }
      });
      
      // Mock the stream
      when(mockReference.onValue).thenAnswer((_) => 
        Stream.fromIterable([mockEvent]));
      
      // Test the stream conversion
      final stream = firebaseService.getStudyGroupsStream();
      final result = await stream.first;
      
      expect(result.length, 1);
      expect(result[0].id, 'group1');
      expect(result[0].topic, 'Test Topic');
    });
    
    test('Event sync operations', () async {
      // Similar test for events
      final mockSnapshot = MockDataSnapshot();
      final mockEvent = MockDatabaseEvent();
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(hours: 2));
      
      when(mockEvent.snapshot).thenReturn(mockSnapshot);
      when(mockSnapshot.value).thenReturn({
        'event1': {
          'id': 'event1',
          'title': 'Test Event',
          'description': 'Test Description',
          'location': 'Test Location',
          'startTime': startTime.millisecondsSinceEpoch,
          'endTime': endTime.millisecondsSinceEpoch,
          'category': 'Academic',
          'isRsvped': false,
        }
      });
      
      when(mockReference.onValue).thenAnswer((_) => 
        Stream.fromIterable([mockEvent]));
      
      final stream = firebaseService.getEventsStream();
      final result = await stream.first;
      
      expect(result.length, 1);
      expect(result[0].id, 'event1');
      expect(result[0].title, 'Test Event');
    });
  });
}