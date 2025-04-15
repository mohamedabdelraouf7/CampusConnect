import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final AppState appState;
  
  const NotificationSettingsScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late bool _enableClassReminders;
  late bool _enableEventReminders;
  late bool _enableStudyGroupReminders;
  late bool _enableDeadlineReminders;
  late int _classReminderMinutes;
  late int _eventReminderMinutes;
  late int _studyGroupReminderMinutes;
  late List<int> _deadlineReminderTimes;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  void _loadPreferences() {
    _enableClassReminders = widget.appState.enableClassReminders;
    _enableEventReminders = widget.appState.enableEventReminders;
    _enableStudyGroupReminders = widget.appState.enableStudyGroupReminders;
    _enableDeadlineReminders = widget.appState.enableDeadlineReminders;
    _classReminderMinutes = widget.appState.classReminderMinutes;
    _eventReminderMinutes = widget.appState.eventReminderMinutes;
    _studyGroupReminderMinutes = widget.appState.studyGroupReminderMinutes;
    _deadlineReminderTimes = List.from(widget.appState.deadlineReminderTimes);
  }
  
  Future<void> _savePreferences() async {
    widget.appState.enableClassReminders = _enableClassReminders;
    widget.appState.enableEventReminders = _enableEventReminders;
    widget.appState.enableStudyGroupReminders = _enableStudyGroupReminders;
    widget.appState.enableDeadlineReminders = _enableDeadlineReminders;
    widget.appState.classReminderMinutes = _classReminderMinutes;
    widget.appState.eventReminderMinutes = _eventReminderMinutes;
    widget.appState.studyGroupReminderMinutes = _studyGroupReminderMinutes;
    widget.appState.deadlineReminderTimes = _deadlineReminderTimes;
    
    await widget.appState.savePreferences();
    
    // Reschedule all notifications based on new preferences
    await _rescheduleNotifications();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved')),
    );
  }
  
  Future<void> _rescheduleNotifications() async {
    final notificationService = NotificationService();
    
    // Cancel all existing notifications
    await notificationService.cancelAllNotifications();
    
    // Reschedule class reminders
    if (_enableClassReminders) {
      for (final classModel in widget.appState.classes) {
        await notificationService.scheduleClassReminders(classModel, _classReminderMinutes);
      }
    }
    
    // Reschedule event reminders
    if (_enableEventReminders) {
      for (final event in widget.appState.events) {
        if (event.dateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleEventReminder(event, _eventReminderMinutes);
        }
      }
    }
    
    // Reschedule study group reminders
    if (_enableStudyGroupReminders) {
      for (final studyGroup in widget.appState.studyGroups) {
        if (studyGroup.dateTime.isAfter(DateTime.now())) {
          await notificationService.scheduleStudyGroupReminder(studyGroup, _studyGroupReminderMinutes);
        }
      }
    }
    
    // Deadline reminders are scheduled when deadlines are created/updated
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Class reminders
          SwitchListTile(
            title: const Text('Class Reminders'),
            subtitle: const Text('Get notified before your classes start'),
            value: _enableClassReminders,
            onChanged: (value) {
              setState(() {
                _enableClassReminders = value;
              });
            },
          ),
          
          if (_enableClassReminders)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remind me ${_classReminderMinutes} minutes before class'),
                  Slider(
                    value: _classReminderMinutes.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    label: '${_classReminderMinutes} min',
                    onChanged: (value) {
                      setState(() {
                        _classReminderMinutes = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          
          const Divider(),
          
          // Event reminders
          SwitchListTile(
            title: const Text('Event Reminders'),
            subtitle: const Text('Get notified before events start'),
            value: _enableEventReminders,
            onChanged: (value) {
              setState(() {
                _enableEventReminders = value;
              });
            },
          ),
          
          if (_enableEventReminders)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remind me ${_eventReminderMinutes} minutes before events'),
                  Slider(
                    value: _eventReminderMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: '${_eventReminderMinutes} min',
                    onChanged: (value) {
                      setState(() {
                        _eventReminderMinutes = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          
          const Divider(),
          
          // Study group reminders
          SwitchListTile(
            title: const Text('Study Group Reminders'),
            subtitle: const Text('Get notified before study group sessions'),
            value: _enableStudyGroupReminders,
            onChanged: (value) {
              setState(() {
                _enableStudyGroupReminders = value;
              });
            },
          ),
          
          if (_enableStudyGroupReminders)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remind me ${_studyGroupReminderMinutes} minutes before study groups'),
                  Slider(
                    value: _studyGroupReminderMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: '${_studyGroupReminderMinutes} min',
                    onChanged: (value) {
                      setState(() {
                        _studyGroupReminderMinutes = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          
          const Divider(),
          
          // Deadline reminders
          SwitchListTile(
            title: const Text('Deadline Reminders'),
            subtitle: const Text('Get notified about upcoming deadlines'),
            value: _enableDeadlineReminders,
            onChanged: (value) {
              setState(() {
                _enableDeadlineReminders = value;
              });
            },
          ),
          
          if (_enableDeadlineReminders)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remind me at these times before deadlines:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDeadlineChip(60, '1 hour'),
                      _buildDeadlineChip(720, '12 hours'),
                      _buildDeadlineChip(1440, '1 day'),
                      _buildDeadlineChip(2880, '2 days'),
                      _buildDeadlineChip(4320, '3 days'),
                      _buildDeadlineChip(10080, '1 week'),
                    ],
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _savePreferences,
            child: const Text('Save Settings'),
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text('This will cancel all scheduled notifications. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await NotificationService().cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              }
            },
            child: const Text('Clear All Notifications'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeadlineChip(int minutes, String label) {
    final isSelected = _deadlineReminderTimes.contains(minutes);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _deadlineReminderTimes.add(minutes);
          } else {
            _deadlineReminderTimes.remove(minutes);
          }
        });
      },
    );
  }
}