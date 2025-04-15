import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/app_state.dart';
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import '../widgets/upcoming_item_card.dart';
import '../widgets/notification_list.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;
  
  const HomeScreen({Key? key, required this.appState}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final upcomingItems = widget.appState.getUpcomingItems();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications panel
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.3,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return NotificationList(
                      notifications: widget.appState.notifications,
                      onNotificationTap: (notification) {
                        // Handle notification tap
                        setState(() {
                          final index = widget.appState.notifications.indexWhere((n) => n.id == notification.id);
                          if (index != -1) {
                            widget.appState.notifications[index] = notification.copyWith(isRead: true);
                            widget.appState.saveNotifications();
                          }
                          
                          // Navigate based on notification type
                          if (notification.relatedItemId != null) {
                            // TODO: Navigate to the related item
                            Navigator.pop(context); // Close the bottom sheet
                          }
                        });
                      },
                      onNotificationDismiss: (notification) {
                        // Remove notification
                        setState(() {
                          widget.appState.notifications.removeWhere((n) => n.id == notification.id);
                          widget.appState.saveNotifications();
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming tab
          upcomingItems.isEmpty
              ? const Center(
                  child: Text(
                    'No upcoming events or classes',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: upcomingItems.length,
                  itemBuilder: (context, index) {
                    final item = upcomingItems[index];
                    return UpcomingItemCard(
                      item: item,
                      onTap: () {
                        // Navigate to detail screen based on item type
                        if (item is ClassModel) {
                          // Navigate to class detail
                        } else if (item is EventModel) {
                          // Navigate to event detail
                        } else if (item is StudyGroupModel) {
                          // Navigate to study group detail
                        }
                      },
                    );
                  },
                ),
          
          // Calendar tab
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  // Get all events for this day
                  final events = widget.appState.events.where((e) => 
                    isSameDay(e.dateTime, day)
                  ).toList();
                  
                  // Get study groups for this day
                  final studyGroups = widget.appState.studyGroups.where((sg) => 
                    isSameDay(sg.dateTime, day)
                  ).toList();
                  
                  // Get classes for this day of week
                  final classes = widget.appState.classes.where((c) => 
                    c.dayOfWeek == day.weekday
                  ).toList();
                  
                  return [...events, ...studyGroups, ...classes];
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildEventsForSelectedDay(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventsForSelectedDay() {
    if (_selectedDay == null) return Container();
    
    // Get events for selected day
    final events = widget.appState.events.where((e) => 
      isSameDay(e.dateTime, _selectedDay!)
    ).toList();
    
    // Get study groups for selected day
    final studyGroups = widget.appState.studyGroups.where((sg) => 
      isSameDay(sg.dateTime, _selectedDay!)
    ).toList();
    
    // Get classes for selected day of week
    final classes = widget.appState.classes.where((c) => 
      c.dayOfWeek == _selectedDay!.weekday
    ).toList();
    
    final allItems = [...classes, ...events, ...studyGroups];
    
    if (allItems.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return UpcomingItemCard(
          item: item,
          onTap: () {
            // Navigate to detail screen based on item type
            if (item is ClassModel) {
              // Navigate to class detail
            } else if (item is EventModel) {
              // Navigate to event detail
            } else if (item is StudyGroupModel) {
              // Navigate to study group detail
            }
          },
        );
      },
    );
  }
}