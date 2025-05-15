import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/services/notification_service.dart';
import 'package:campusconnect/models/class_model.dart';
import 'package:campusconnect/models/event_model.dart';
import 'package:campusconnect/models/study_group_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:timezone/timezone.dart' as tz;

@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotifications;
  
  setUp(() {
    mockNotifications = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService.forTesting(mockNotifications);
  });
  
  group('Notification Service Tests', () {
    test('Schedule class notification', () async {
      // Create a test class
      final testClass = ClassModel(
        id: 'test_class_1',
        courseCode: 'CS101',
        name: 'Introduction to Programming',
        professor: 'Dr. Smith',
        location: 'Room 101',
        dayOfWeek: 1, // Monday
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 10, minute: 30),
        notes: 'Test notes',
      );
      
      // Mock the zonedSchedule method
      when(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      )).thenAnswer((_) async => true);
      
      // Schedule the notification
      await notificationService.scheduleClassNotification(testClass, 30);
      
      // Verify the notification was scheduled
      verify(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      )).called(1);
    });
    
    test('Schedule event notification', () async {
      // Create a test event
      final testEvent = EventModel(
        id: 'test_event_1',
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        category: 'Academic',
        isRsvped: false,
      );
      
      // Mock the zonedSchedule method
      when(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
      )).thenAnswer((_) async => true);
      
      // Schedule the notification
      await notificationService.scheduleEventNotification(testEvent, 60);
      
      // Verify the notification was scheduled
      verify(mockNotifications.zonedSchedule(
        any, any, any, any, any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed('uiLocalNotificationDateInterpretation'),
      )).called(1);
    });
  });
}