import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  static const String _classReminderKey = 'class_reminder_minutes';
  static const String _eventReminderKey = 'event_reminder_minutes';
  static const String _taskReminderKey = 'task_reminder_minutes';
  static const String _enableClassNotificationsKey = 'enable_class_notifications';
  static const String _enableEventNotificationsKey = 'enable_event_notifications';
  static const String _enableTaskNotificationsKey = 'enable_task_notifications';
  static const String _enableRealTimeAlertsKey = 'enable_real_time_alerts';

  final SharedPreferences _prefs;

  NotificationPreferences(this._prefs);

  // Class notification preferences
  int get classReminderMinutes => _prefs.getInt(_classReminderKey) ?? 15;
  set classReminderMinutes(int minutes) => _prefs.setInt(_classReminderKey, minutes);
  bool get enableClassNotifications => _prefs.getBool(_enableClassNotificationsKey) ?? true;
  set enableClassNotifications(bool value) => _prefs.setBool(_enableClassNotificationsKey, value);

  // Event notification preferences
  int get eventReminderMinutes => _prefs.getInt(_eventReminderKey) ?? 30;
  set eventReminderMinutes(int minutes) => _prefs.setInt(_eventReminderKey, minutes);
  bool get enableEventNotifications => _prefs.getBool(_enableEventNotificationsKey) ?? true;
  set enableEventNotifications(bool value) => _prefs.setBool(_enableEventNotificationsKey, value);

  // Task notification preferences
  List<int> get taskReminderMinutes {
    final String? stored = _prefs.getString(_taskReminderKey);
    if (stored == null) return [60, 1440, 4320]; // Default: 1 hour, 1 day, 3 days
    return stored.split(',').map((e) => int.parse(e)).toList();
  }
  set taskReminderMinutes(List<int> minutes) => 
      _prefs.setString(_taskReminderKey, minutes.join(','));
  bool get enableTaskNotifications => _prefs.getBool(_enableTaskNotificationsKey) ?? true;
  set enableTaskNotifications(bool value) => _prefs.setBool(_enableTaskNotificationsKey, value);

  // Real-time alerts preference
  bool get enableRealTimeAlerts => _prefs.getBool(_enableRealTimeAlertsKey) ?? true;
  set enableRealTimeAlerts(bool value) => _prefs.setBool(_enableRealTimeAlertsKey, value);

  // Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    await _prefs.remove(_classReminderKey);
    await _prefs.remove(_eventReminderKey);
    await _prefs.remove(_taskReminderKey);
    await _prefs.remove(_enableClassNotificationsKey);
    await _prefs.remove(_enableEventNotificationsKey);
    await _prefs.remove(_enableTaskNotificationsKey);
    await _prefs.remove(_enableRealTimeAlertsKey);
  }
} 