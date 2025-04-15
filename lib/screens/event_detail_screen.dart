import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatefulWidget {
  final AppState appState;
  final EventModel event;
  
  const EventDetailScreen({
    Key? key, 
    required this.appState, 
    required this.event,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late EventModel _event;
  
  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }
  
  void _toggleRSVP() {
    setState(() {
      _event = _event.copyWith(isRsvped: !_event.isRsvped);
      
      // Update the event in the app state
      final index = widget.appState.events.indexWhere((e) => e.id == _event.id);
      if (index != -1) {
        widget.appState.events[index] = _event;
        widget.appState.saveEvents();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share event functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing event...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header image
            Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            
            // Event details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and RSVP status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_event.isRsvped)
                        Chip(
                          label: const Text('RSVP\'d'),
                          backgroundColor: Colors.green.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Organizer
                  Text(
                    'Organized by: ${_event.organizer}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date and time
                  _buildInfoRow(
                    Icons.calendar_today,
                    dateFormat.format(_event.dateTime),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Time
                  _buildInfoRow(
                    Icons.access_time,
                    timeFormat.format(_event.dateTime),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  _buildInfoRow(
                    Icons.location_on,
                    _event.location,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description header
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description text
                  Text(
                    _event.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // RSVP button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _toggleRSVP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _event.isRsvped ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _event.isRsvped ? 'Cancel RSVP' : 'RSVP to Event',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Add to calendar button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Add to calendar functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to calendar')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Add to Calendar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}