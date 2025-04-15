import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/study_group_model.dart';
import 'study_group_form_screen.dart';

class StudyGroupDetailScreen extends StatefulWidget {
  final AppState appState;
  final StudyGroupModel studyGroup;
  
  const StudyGroupDetailScreen({
    Key? key, 
    required this.appState, 
    required this.studyGroup,
  }) : super(key: key);

  @override
  _StudyGroupDetailScreenState createState() => _StudyGroupDetailScreenState();
}

class _StudyGroupDetailScreenState extends State<StudyGroupDetailScreen> {
  late StudyGroupModel _studyGroup;
  
  @override
  void initState() {
    super.initState();
    _studyGroup = widget.studyGroup;
  }
  
  void _toggleJoinStatus() {
    setState(() {
      final isCurrentlyJoined = _studyGroup.isJoined;
      
      if (isCurrentlyJoined) {
        // Leave the group
        final updatedParticipants = List<String>.from(_studyGroup.participants);
        updatedParticipants.remove('You'); // In a real app, remove current user
        
        _studyGroup = StudyGroupModel(
          id: _studyGroup.id,
          topic: _studyGroup.topic,
          courseCode: _studyGroup.courseCode,
          courseName: _studyGroup.courseName,
          location: _studyGroup.location,
          dateTime: _studyGroup.dateTime,
          description: _studyGroup.description,
          createdBy: _studyGroup.createdBy,
          maxParticipants: _studyGroup.maxParticipants,
          participants: updatedParticipants,
          isJoined: false,
        );
      } else {
        // Join the group
        final updatedParticipants = List<String>.from(_studyGroup.participants);
        updatedParticipants.add('You'); // In a real app, add current user
        
        _studyGroup = StudyGroupModel(
          id: _studyGroup.id,
          topic: _studyGroup.topic,
          courseCode: _studyGroup.courseCode,
          courseName: _studyGroup.courseName,
          location: _studyGroup.location,
          dateTime: _studyGroup.dateTime,
          description: _studyGroup.description,
          createdBy: _studyGroup.createdBy,
          maxParticipants: _studyGroup.maxParticipants,
          participants: updatedParticipants,
          isJoined: true,
        );
      }
      
      // Update the study group in app state
      final index = widget.appState.studyGroups.indexWhere((sg) => sg.id == _studyGroup.id);
      if (index != -1) {
        widget.appState.studyGroups[index] = _studyGroup;
        widget.appState.saveStudyGroups();
      }
    });
  }
  
  void _deleteStudyGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Group'),
        content: const Text('Are you sure you want to delete this study group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Remove study group from app state
              widget.appState.studyGroups.removeWhere((sg) => sg.id == _studyGroup.id);
              widget.appState.saveStudyGroups();
              
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
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final isCreator = _studyGroup.createdBy == 'You'; // In a real app, check if current user is creator
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Group Details'),
        actions: [
          if (isCreator) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyGroupFormScreen(
                      appState: widget.appState,
                      studyGroup: _studyGroup,
                    ),
                  ),
                );
                
                if (result == true) {
                  // Refresh study group data
                  setState(() {
                    final updatedGroup = widget.appState.studyGroups.firstWhere(
                      (sg) => sg.id == _studyGroup.id,
                    );
                    _studyGroup = updatedGroup;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteStudyGroup,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share study group functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing study group details...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course info card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.class_,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studyGroup.courseCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                _studyGroup.courseName,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Study group details card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic
                    Text(
                      _studyGroup.topic,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date and time
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      dateFormat.format(_studyGroup.dateTime),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Time
                    _buildInfoRow(
                      Icons.access_time,
                      'Time',
                      timeFormat.format(_studyGroup.dateTime),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Location
                    _buildInfoRow(
                      Icons.location_on,
                      'Location',
                      _studyGroup.location,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Created by
                    _buildInfoRow(
                      Icons.person,
                      'Created by',
                      _studyGroup.createdBy,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Participants
                    _buildInfoRow(
                      Icons.group,
                      'Participants',
                      '${_studyGroup.participants.length} / ${_studyGroup.maxParticipants}',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Participant list
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _studyGroup.participants.map((participant) {
                        return Chip(
                          label: Text(participant),
                          backgroundColor: participant == 'You'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: participant == 'You' ? Colors.green : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description card
            if (_studyGroup.description.isNotEmpty) ...[
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _studyGroup.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Join/Leave button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _studyGroup.participants.length >= _studyGroup.maxParticipants && !_studyGroup.isJoined
                    ? null // Disable if group is full and user is not already a member
                    : _toggleJoinStatus,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _studyGroup.isJoined ? Colors.red : Colors.green,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(
                  _studyGroup.isJoined ? 'Leave Group' : 'Join Group',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Add to calendar button
            SizedBox(
              width: double.infinity,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}