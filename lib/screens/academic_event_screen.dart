import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/academic_event_model.dart';
import '../models/app_state.dart';
import '../services/academic_event_service.dart';
import 'academic_event_form_screen.dart';

class AcademicEventScreen extends StatefulWidget {
  final AppState appState;
  
  const AcademicEventScreen({super.key, required this.appState});

  @override
  _AcademicEventScreenState createState() => _AcademicEventScreenState();
}

class _AcademicEventScreenState extends State<AcademicEventScreen> with SingleTickerProviderStateMixin {
  final AcademicEventService _eventService = AcademicEventService();
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  AcademicEventType? _selectedType;
  
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AcademicEventFormScreen(
                    appState: widget.appState,
                    initialDate: _selectedDay,
                  ),
                ),
              );
              
              if (result == true) {
                setState(() {});
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calendar tab
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                calendarStyle: CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            events.length.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                eventLoader: (day) {
                  // Get events for this day
                  return _getEventsForDay(day);
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildEventsForSelectedDay(),
              ),
            ],
          ),
          
          // List tab
          StreamBuilder<List<AcademicEvent>>(
            stream: _selectedType != null
                ? _eventService.getEventsByType(_selectedType!)
                : _eventService.getEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final events = snapshot.data!;
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No academic events found',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (_selectedType != null) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedType = null;
                            });
                          },
                          child: const Text('Clear filter'),
                        ),
                      ],
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(event);
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  List<AcademicEvent> _getEventsForDay(DateTime day) {
    // This is a placeholder - in a real app, you would use the event service
    // to get events for the specific day
    return [];
  }
  
  Widget _buildEventsForSelectedDay() {
    if (_selectedDay == null) return Container();
    
    return StreamBuilder<List<AcademicEvent>>(
      stream: _eventService.getEventsInRange(
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day),
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 23, 59, 59),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No events for this day',
              style: TextStyle(fontSize: 16),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      },
    );
  }
  
  Widget _buildEventCard(AcademicEvent event) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AcademicEventFormScreen(
                appState: widget.appState,
                event: event,
              ),
            ),
          );
          
          if (result == true) {
            setState(() {});
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildEventTypeChip(event.type),
                  const Spacer(),
                  if (event.isOverdue)
                    const Chip(
                      label: Text('Overdue'),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  else if (event.isUpcoming)
                    Chip(
                      label: Text(event.timeUntilDueDisplay),
                      backgroundColor: Colors.green,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.displayTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(event.dueDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (event.location != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      event.location!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEventTypeChip(AcademicEventType type) {
    Color color;
    switch (type) {
      case AcademicEventType.exam:
        color = Colors.red;
        break;
      case AcademicEventType.assignment:
        color = Colors.blue;
        break;
      case AcademicEventType.quiz:
        color = Colors.orange;
        break;
      case AcademicEventType.project:
        color = Colors.purple;
        break;
      case AcademicEventType.presentation:
        color = Colors.green;
        break;
    }
    
    return Chip(
      label: Text(
        type.toString().split('.').last,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Events'),
              selected: _selectedType == null,
              onTap: () {
                setState(() {
                  _selectedType = null;
                });
                Navigator.pop(context);
              },
            ),
            ...AcademicEventType.values.map((type) => ListTile(
              title: Text(type.toString().split('.').last),
              selected: _selectedType == type,
              onTap: () {
                setState(() {
                  _selectedType = type;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
} 