import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:rxdart/rxdart.dart';
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationResponse> onNotificationClick = BehaviorSubject<NotificationResponse>();

  NotificationService._internal();

  Future<void> init() async {
    if (kIsWeb) {
      // Web doesn't support local notifications in the same way
      return;
    }
    
    // Initialize timezone
    tz_init.initializeTimeZones();
    
    // Initialize notification settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // Handle iOS foreground notification
      },
    );
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick.add(response);
      },
    );

    // Request permission
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'campus_connect_channel',
      'Campus Connect Notifications',
      channelDescription: 'Notifications for CampusConnect app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool repeating = false,
    RepeatInterval? repeatInterval,
  }) async {
    // Making this constructor const for better performance
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'campus_connect_scheduled_channel',
      'Campus Connect Scheduled Notifications',
      channelDescription: 'Scheduled notifications for CampusConnect app',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (repeating && repeatInterval != null) {
      // For repeating notifications (like weekly classes)
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      // For one-time notifications
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Schedule class reminders
  Future<void> scheduleClassReminders(ClassModel classModel, int minutesBefore) async {
    // Get the next occurrence of this class
    final now = DateTime.now();
    final daysUntilClass = (classModel.dayOfWeek - now.weekday) % 7;
    
    // Create a DateTime for the next class
    final nextClassDay = now.add(Duration(days: daysUntilClass));
    
    // Access hour and minute directly from TimeOfDay object
    final classHour = classModel.startTime.hour;
    final classMinute = classModel.startTime.minute;
    
    final nextClassDateTime = DateTime(
      nextClassDay.year,
      nextClassDay.month,
      nextClassDay.day,
      classHour,
      classMinute,
    );
    
    // Calculate reminder time
    final reminderTime = nextClassDateTime.subtract(Duration(minutes: minutesBefore));
    
    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(now)) {
      await scheduleNotification(
        id: classModel.id.hashCode,
        title: 'Class Reminder: ${classModel.name}', // Changed from courseName to name
        body: 'Your ${classModel.courseCode} class starts in $minutesBefore minutes at ${classModel.location}',
        scheduledTime: reminderTime,
        payload: 'class:${classModel.id}',
        repeating: true,
        repeatInterval: RepeatInterval.weekly,
      );
    }
  }

  // Schedule event reminders
  Future<void> scheduleEventReminder(EventModel event, int minutesBefore) async {
    final reminderTime = event.dateTime.subtract(Duration(minutes: minutesBefore));
    
    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: event.id.hashCode,
        title: 'Event Reminder: ${event.title}',
        body: 'Your event "${event.title}" starts in $minutesBefore minutes at ${event.location}',
        scheduledTime: reminderTime,
        payload: 'event:${event.id}',
      );
    }
  }

  // Schedule study group reminders
  Future<void> scheduleStudyGroupReminder(StudyGroupModel studyGroup, int minutesBefore) async {
    final reminderTime = studyGroup.dateTime.subtract(Duration(minutes: minutesBefore));
    
    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: studyGroup.id.hashCode,
        title: 'Study Group Reminder: ${studyGroup.topic}',
        body: 'Your study group for ${studyGroup.courseName} starts in $minutesBefore minutes at ${studyGroup.location}',
        scheduledTime: reminderTime,
        payload: 'studygroup:${studyGroup.id}',
      );
    }
  }

  // Schedule deadline reminder
  Future<void> scheduleDeadlineReminder(String id, String title, String description, DateTime deadline, List<int> reminderTimes) async {
    for (final minutes in reminderTimes) {
      final reminderTime = deadline.subtract(Duration(minutes: minutes));
      
      // Only schedule if the reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        String timeText = '';
        if (minutes >= 1440) {
          timeText = '${minutes ~/ 1440} days';
        } else if (minutes >= 60) {
          timeText = '${minutes ~/ 60} hours';
        } else {
          timeText = '$minutes minutes';
        }
        
        await scheduleNotification(
          id: '${id}_$minutes'.hashCode,
          title: 'Deadline Reminder: $title',
          body: 'Your deadline "$title" is in $timeText',
          scheduledTime: reminderTime,
          payload: 'deadline:$id',
        );
      }
    }
  }
}