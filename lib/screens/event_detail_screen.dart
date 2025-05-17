import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatefulWidget {
  final AppState appState;
  final EventModel event;
  
  const EventDetailScreen({
    super.key, 
    required this.appState, 
    required this.event,
  });

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
  
  Future<void> _toggleAttendance() async {
    try {
      final updatedEvent = widget.event.copyWith(
        attendees: widget.event.isAttending
            ? widget.event.attendees.where((email) => email != widget.appState.userEmail).toList()
            : [...widget.event.attendees, widget.appState.userEmail],
      );
      await widget.appState.firebaseService.addOrUpdateEvent(updatedEvent);
      if (mounted) {
        setState(() {
          _event = updatedEvent;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attendance: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.appState.deleteEvent(widget.event.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
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
                      if (_event.isAttending)
                        Chip(
                          label: const Text('Attending'),
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
                      onPressed: _toggleAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _event.isAttending ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _event.isAttending ? 'Cancel RSVP' : 'RSVP to Event',
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