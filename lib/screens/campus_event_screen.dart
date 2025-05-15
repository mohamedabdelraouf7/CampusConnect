import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class CampusEventScreen extends StatefulWidget {
  final AppState appState;
  
  const CampusEventScreen({Key? key, required this.appState}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CampusEventScreenState createState() => _CampusEventScreenState();
}

class _CampusEventScreenState extends State<CampusEventScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Academic', 'Sports', 'Club', 'Social', 'RSVP\'d'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              // ignore: deprecated_member_use
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildEventsList() {
    final now = DateTime.now();
    List<EventModel> filteredEvents = widget.appState.events
        .where((event) => event.dateTime.isAfter(now))
        .toList();
    
    // Apply filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'RSVP\'d') {
        filteredEvents = filteredEvents.where((event) => event.isRsvped).toList();
      } else {
        // In a real app, you would filter by category
        // For now, we'll just keep all events
      }
    }
    
    // Sort by date
    filteredEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No upcoming events found',
              style: TextStyle(fontSize: 16),
            ),
            if (_selectedFilter != 'All') ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
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
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return EventCard(
          event: event,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(
                  appState: widget.appState,
                  event: event,
                ),
              ),
            );
            
            if (result == true) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}