import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:rxdart/rxdart.dart';
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import '../models/notification_preferences.dart';
import '../models/academic_event_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  factory NotificationService() => instance;
  factory NotificationService.forTesting(FlutterLocalNotificationsPlugin plugin) {
    final service = NotificationService._internal();
    service._plugin = plugin;
    _instance = service;
    return service;
  }

  late FlutterLocalNotificationsPlugin _plugin;
  NotificationPreferences? _preferences;
  final BehaviorSubject<NotificationResponse> onNotificationClick = BehaviorSubject<NotificationResponse>();
  bool _isInitialized = false;

  NotificationService._internal() : _plugin = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin => _plugin;
  
  NotificationPreferences get preferences {
    if (!_isInitialized) {
      throw StateError('NotificationService has not been initialized. Call init() first.');
    }
    return _preferences!;
  }

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }
    
    try {
      // Initialize timezone
      tz_init.initializeTimeZones();
      
      // Initialize preferences
      final prefs = await SharedPreferences.getInstance();
      _preferences = NotificationPreferences(prefs);
      
      // Initialize notification settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
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
            AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  // Show immediate notification for real-time alerts
  Future<void> showRealTimeAlert({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_preferences!.enableRealTimeAlerts) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "campus_connect_realtime_channel",
      "Campus Connect Real-time Alerts",
      channelDescription: "Real-time alerts for schedule changes and cancellations",
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule class reminders based on preferences
  Future<void> scheduleClassReminders(ClassModel classModel) async {
    if (!_preferences!.enableClassNotifications) return;
    
    final now = DateTime.now();
    final daysUntilClass = (classModel.dayOfWeek - now.weekday) % 7;
    final nextClassDay = now.add(Duration(days: daysUntilClass));
    final classHour = classModel.startTime.hour;
    final classMinute = classModel.startTime.minute;
    
    final nextClassDateTime = DateTime(
      nextClassDay.year,
      nextClassDay.month,
      nextClassDay.day,
      classHour,
      classMinute,
    );
    
    final reminderTime = nextClassDateTime.subtract(
      Duration(minutes: _preferences!.classReminderMinutes)
    );
    
    if (reminderTime.isAfter(now)) {
      await scheduleNotification(
        id: classModel.id.hashCode,
        title: 'Class Reminder: ${classModel.name}',
        body: 'Your ${classModel.courseCode} class starts in ${_preferences!.classReminderMinutes} minutes at ${classModel.location}',
        scheduledTime: reminderTime,
        payload: 'class:${classModel.id}',
        repeating: true,
        repeatInterval: RepeatInterval.weekly,
      );
    }
  }

  // Schedule event reminders based on preferences
  Future<void> scheduleEventReminder(EventModel event) async {
    if (!_preferences!.enableEventNotifications) return;
    
    final reminderTime = event.dateTime.subtract(
      Duration(minutes: _preferences!.eventReminderMinutes)
    );
    
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: event.id.hashCode,
        title: 'Event Reminder: ${event.title}',
        body: 'Your event "${event.title}" starts in ${_preferences!.eventReminderMinutes} minutes at ${event.location}',
        scheduledTime: reminderTime,
        payload: 'event:${event.id}',
      );
    }
  }

  // Schedule task reminders based on preferences
  Future<void> scheduleTaskReminders(AcademicEvent task) async {
    if (!_preferences!.enableTaskNotifications) return;
    
    for (final minutes in _preferences!.taskReminderMinutes) {
      final reminderTime = task.dueDate.subtract(Duration(minutes: minutes));
      
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
          id: '${task.id}_$minutes'.hashCode,
          title: 'Task Reminder: ${task.title}',
          body: 'Your ${task.type.toString().split('.').last} "${task.title}" is due in $timeText',
          scheduledTime: reminderTime,
          payload: 'task:${task.id}',
        );
      }
    }
  }

  // Handle schedule changes
  Future<void> handleScheduleChange({
    required String type,
    required String title,
    required String message,
    String? oldTime,
    String? newTime,
  }) async {
    final body = oldTime != null && newTime != null
        ? '$message\nOld time: $oldTime\nNew time: $newTime'
        : message;
        
    await showRealTimeAlert(
      title: '$type Schedule Change: $title',
      body: body,
      payload: 'schedule_change:$type',
    );
  }

  // Handle event cancellation
  Future<void> handleEventCancellation(EventModel event) async {
    await showRealTimeAlert(
      title: 'Event Cancelled: ${event.title}',
      body: 'The event "${event.title}" scheduled for ${event.dateTime} has been cancelled.',
      payload: 'event_cancelled:${event.id}',
    );
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
    if (kIsWeb) return;
    if (!_isInitialized) throw StateError("NotificationService not initialized. Call init() first.");
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "campus_connect_scheduled_channel",
      "Campus Connect Scheduled Reminders",
      channelDescription: "Scheduled reminders for classes, events, and tasks",
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    if (repeating) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: repeatInterval == RepeatInterval.daily ? DateTimeComponents.time : (repeatInterval == RepeatInterval.weekly ? DateTimeComponents.dayOfWeekAndTime : null),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
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