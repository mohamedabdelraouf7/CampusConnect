import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/models/event_model.dart';

void main() {
  group('EventModel Tests', () {
    test('Create event with valid data', () {
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

      expect(event.id, 'test_event_1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.location, 'Test Location');
      expect(event.category, 'Academic');
      expect(event.maxAttendees, 10);
      expect(event.attendees, isEmpty);
      expect(event.imageUrl, null);
      expect(event.organizer, 'test@example.com');
    });

    test('Create event with invalid data throws error', () {
      expect(
        () => EventModel(
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
        ),
        throwsAssertionError,
      );
    });

    test('Event serialization and deserialization', () {
      final originalEvent = EventModel(
        id: 'test_event_2',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 10,
        attendees: ['user1@example.com', 'user2@example.com'],
        imageUrl: 'https://example.com/image.jpg',
        organizer: 'test@example.com',
      );

      final json = originalEvent.toJson();
      final deserializedEvent = EventModel.fromJson(json);

      expect(deserializedEvent.id, originalEvent.id);
      expect(deserializedEvent.title, originalEvent.title);
      expect(deserializedEvent.description, originalEvent.description);
      expect(deserializedEvent.location, originalEvent.location);
      expect(deserializedEvent.category, originalEvent.category);
      expect(deserializedEvent.maxAttendees, originalEvent.maxAttendees);
      expect(deserializedEvent.attendees, originalEvent.attendees);
      expect(deserializedEvent.imageUrl, originalEvent.imageUrl);
      expect(deserializedEvent.organizer, originalEvent.organizer);
    });

    test('Event update with copyWith', () {
      final originalEvent = EventModel(
        id: 'test_event_3',
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

      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        location: 'Updated Location',
      );

      expect(updatedEvent.id, originalEvent.id);
      expect(updatedEvent.title, 'Updated Title');
      expect(updatedEvent.description, 'Updated Description');
      expect(updatedEvent.location, 'Updated Location');
      expect(updatedEvent.category, originalEvent.category);
      expect(updatedEvent.maxAttendees, originalEvent.maxAttendees);
      expect(updatedEvent.attendees, originalEvent.attendees);
      expect(updatedEvent.imageUrl, originalEvent.imageUrl);
      expect(updatedEvent.organizer, originalEvent.organizer);
    });

    test('Event validation rules', () {
      // Test past date validation
      expect(
        () => EventModel(
          id: 'test_event_4',
          title: 'Test Event',
          description: 'Test Description',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          location: 'Test Location',
          category: 'Academic',
          maxAttendees: 10,
          attendees: [],
          imageUrl: null,
          organizer: 'test@example.com',
        ),
        throwsAssertionError,
      );

      // Test empty title validation
      expect(
        () => EventModel(
          id: 'test_event_5',
          title: '',
          description: 'Test Description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          location: 'Test Location',
          category: 'Academic',
          maxAttendees: 10,
          attendees: [],
          imageUrl: null,
          organizer: 'test@example.com',
        ),
        throwsAssertionError,
      );

      // Test invalid max attendees validation
      expect(
        () => EventModel(
          id: 'test_event_6',
          title: 'Test Event',
          description: 'Test Description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          location: 'Test Location',
          category: 'Academic',
          maxAttendees: 0,
          attendees: [],
          imageUrl: null,
          organizer: 'test@example.com',
        ),
        throwsAssertionError,
      );
    });

    test('Event attendance management', () {
      final event = EventModel(
        id: 'test_event_7',
        title: 'Test Event',
        description: 'Test Description',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'Test Location',
        category: 'Academic',
        maxAttendees: 2,
        attendees: ['user1@example.com'],
        imageUrl: null,
        organizer: 'test@example.com',
      );

      // Test adding attendee
      final eventWithNewAttendee = event.copyWith(
        attendees: [...event.attendees, 'user2@example.com'],
      );
      expect(eventWithNewAttendee.attendees.length, 2);
      expect(eventWithNewAttendee.attendees, contains('user2@example.com'));

      // Test removing attendee
      final eventWithoutAttendee = eventWithNewAttendee.copyWith(
        attendees: eventWithNewAttendee.attendees
            .where((email) => email != 'user1@example.com')
            .toList(),
      );
      expect(eventWithoutAttendee.attendees.length, 1);
      expect(eventWithoutAttendee.attendees, contains('user2@example.com'));
      expect(eventWithoutAttendee.attendees, isNot(contains('user1@example.com')));

      // Test max attendees limit
      expect(
        () => eventWithNewAttendee.copyWith(
          attendees: [
            ...eventWithNewAttendee.attendees,
            'user3@example.com',
            'user4@example.com',
          ],
        ),
        throwsAssertionError,
      );
    });
  });
} 