import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/class_model.dart';
import 'class_form_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final AppState appState;
  final ClassModel classItem;
  
  const ClassDetailScreen({
    Key? key, 
    required this.appState, 
    required this.classItem,
  }) : super(key: key);

  @override
  _ClassDetailScreenState createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late ClassModel _classItem;
  
  @override
  void initState() {
    super.initState();
    _classItem = widget.classItem;
  }
  
  void _deleteClass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove class from app state
              widget.appState.classes.removeWhere((c) => c.id == _classItem.id);
              widget.appState.saveClasses();
              
              // Close dialog and return to previous screen
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to previous screen with result
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassFormScreen(
                    appState: widget.appState,
                    classItem: _classItem,
                  ),
                ),
              );
              
              if (result == true) {
                // Refresh class data
                setState(() {
                  final updatedClass = widget.appState.classes.firstWhere(
                    (c) => c.id == _classItem.id,
                  );
                  _classItem = updatedClass;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClass,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class header
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _classItem.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _classItem.courseCode,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Class details
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Professor
                    _buildDetailRow(
                      Icons.person,
                      'Professor',
                      _classItem.professor,
                    ),
                    
                    const Divider(),
                    
                    // Day and time
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Day',
                      _classItem.dayName,
                    ),
                    
                    const Divider(),
                    
                    // Time
                    _buildDetailRow(
                      Icons.access_time,
                      'Time',
                      _classItem.timeRange,
                    ),
                    
                    const Divider(),
                    
                    // Location
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      _classItem.location,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notes section
            if (_classItem.notes.isNotEmpty) ...[
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _classItem.notes,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add to calendar functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to calendar')),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add to Calendar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share class functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing class details...')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[700],
            size: 20,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}