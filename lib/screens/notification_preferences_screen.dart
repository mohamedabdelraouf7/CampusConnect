import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification_preferences.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  late NotificationPreferences _preferences;
  final _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    _preferences = _notificationService.preferences;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () async {
              await _preferences.resetToDefaults();
              setState(() {});
            },
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Class Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Class Reminders'),
                subtitle: const Text('Get notified before your classes start'),
                value: _preferences.enableClassNotifications,
                onChanged: (value) {
                  setState(() {
                    _preferences.enableClassNotifications = value;
                  });
                },
              ),
              if (_preferences.enableClassNotifications)
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text('${_preferences.classReminderMinutes} minutes before class'),
                  trailing: DropdownButton<int>(
                    value: _preferences.classReminderMinutes,
                    items: [5, 10, 15, 30, 60].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes min'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _preferences.classReminderMinutes = value;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          _buildSection(
            title: 'Event Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Event Reminders'),
                subtitle: const Text('Get notified before campus events'),
                value: _preferences.enableEventNotifications,
                onChanged: (value) {
                  setState(() {
                    _preferences.enableEventNotifications = value;
                  });
                },
              ),
              if (_preferences.enableEventNotifications)
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text('${_preferences.eventReminderMinutes} minutes before event'),
                  trailing: DropdownButton<int>(
                    value: _preferences.eventReminderMinutes,
                    items: [15, 30, 60, 120, 1440].map((minutes) {
                      String text = minutes >= 1440 
                          ? '${minutes ~/ 1440} day'
                          : '$minutes min';
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(text),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _preferences.eventReminderMinutes = value;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          _buildSection(
            title: 'Task Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Task Reminders'),
                subtitle: const Text('Get notified about upcoming assignments and exams'),
                value: _preferences.enableTaskNotifications,
                onChanged: (value) {
                  setState(() {
                    _preferences.enableTaskNotifications = value;
                  });
                },
              ),
              if (_preferences.enableTaskNotifications)
                ListTile(
                  title: const Text('Reminder Times'),
                  subtitle: Text(_preferences.taskReminderMinutes.map((minutes) {
                    if (minutes >= 1440) {
                      return '${minutes ~/ 1440} days';
                    } else if (minutes >= 60) {
                      return '${minutes ~/ 60} hours';
                    } else {
                      return '$minutes minutes';
                    }
                  }).join(', ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showTaskReminderDialog,
                  ),
                ),
            ],
          ),
          _buildSection(
            title: 'Real-time Alerts',
            children: [
              SwitchListTile(
                title: const Text('Enable Real-time Alerts'),
                subtitle: const Text('Get instant notifications for schedule changes and cancellations'),
                value: _preferences.enableRealTimeAlerts,
                onChanged: (value) {
                  setState(() {
                    _preferences.enableRealTimeAlerts = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Future<void> _showTaskReminderDialog() async {
    final List<int> currentTimes = List.from(_preferences.taskReminderMinutes);
    final List<TimeOfDay> selectedTimes = currentTimes.map((minutes) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return TimeOfDay(hour: hours, minute: mins);
    }).toList();

    final result = await showDialog<List<TimeOfDay>>(
      context: context,
      builder: (context) => _TaskReminderDialog(selectedTimes: selectedTimes),
    );

    if (result != null) {
      setState(() {
        _preferences.taskReminderMinutes = result.map((time) {
          return time.hour * 60 + time.minute;
        }).toList();
      });
    }
  }
}

class _TaskReminderDialog extends StatefulWidget {
  final List<TimeOfDay> selectedTimes;

  const _TaskReminderDialog({required this.selectedTimes});

  @override
  State<_TaskReminderDialog> createState() => _TaskReminderDialogState();
}

class _TaskReminderDialogState extends State<_TaskReminderDialog> {
  late List<TimeOfDay> _selectedTimes;

  @override
  void initState() {
    super.initState();
    _selectedTimes = List.from(widget.selectedTimes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Task Reminder Times'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select when you want to be reminded about tasks:'),
          const SizedBox(height: 16),
          ...List.generate(_selectedTimes.length, (index) {
            return ListTile(
              title: Text('Reminder ${index + 1}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: Text(_formatTimeOfDay(_selectedTimes[index])),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTimes[index],
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTimes[index] = time;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _selectedTimes.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
          if (_selectedTimes.length < 5)
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTimes.add(time);
                  });
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedTimes),
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour;
    final minutes = time.minute;
    if (hours >= 24) {
      return '${hours ~/ 24} days';
    } else if (hours > 0) {
      return '$hours hours ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes minutes';
    }
  }
} 