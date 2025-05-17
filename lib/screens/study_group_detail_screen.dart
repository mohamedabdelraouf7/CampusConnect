import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/study_group_model.dart';
import 'study_group_form_screen.dart';
import 'study_group_chat_screen.dart';

class StudyGroupDetailScreen extends StatefulWidget {
  final AppState appState;
  final StudyGroupModel studyGroup;
  
  const StudyGroupDetailScreen({
    super.key, 
    required this.appState, 
    required this.studyGroup,
  });

  @override
  _StudyGroupDetailScreenState createState() => _StudyGroupDetailScreenState();
}

class _StudyGroupDetailScreenState extends State<StudyGroupDetailScreen> with SingleTickerProviderStateMixin {
  late StudyGroupModel _studyGroup;
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  List<Map<String, dynamic>> _groupNotes = [];
  
  @override
  void initState() {
    super.initState();
    _studyGroup = widget.studyGroup;
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for real-time notes updates
    widget.appState.firebaseService
        .getGroupNotesStream(_studyGroup.id)
        .listen((notes) {
      setState(() {
        _groupNotes = notes;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _noteTitleController.dispose();
    super.dispose();
  }
  
  Future<void> _joinStudyGroup() async {
    try {
      final updatedGroup = widget.studyGroup.copyWith(
        participants: [...widget.studyGroup.participants, widget.appState.userEmail],
      );
      await widget.appState.firebaseService.addOrUpdateStudyGroup(updatedGroup);
      if (mounted) {
        setState(() {
          _studyGroup = updatedGroup;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining study group: $e')),
        );
      }
    }
  }

  Future<void> _leaveStudyGroup() async {
    try {
      final updatedGroup = widget.studyGroup.copyWith(
        participants: widget.studyGroup.participants
            .where((email) => email != widget.appState.userEmail)
            .toList(),
      );
      await widget.appState.firebaseService.addOrUpdateStudyGroup(updatedGroup);
      if (mounted) {
        setState(() {
          _studyGroup = updatedGroup;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving study group: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteStudyGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Group'),
        content: const Text('Are you sure you want to delete this study group?'),
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
      await widget.appState.deleteStudyGroup(widget.studyGroup.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
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
          if (_studyGroup.isJoined)
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyGroupChatScreen(
                      appState: widget.appState,
                      studyGroup: _studyGroup,
                    ),
                  ),
                );
              },
            ),
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
                    : _studyGroup.isJoined ? _leaveStudyGroup : _joinStudyGroup,
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
  
  // Update color opacity usage
  Color _getStatusColor() {
    final now = DateTime.now();
    if (widget.studyGroup.dateTime.isBefore(now)) {
      return Colors.grey.withAlpha(128); // Using withAlpha instead of withOpacity
    }
    return Theme.of(context).primaryColor.withAlpha(128);
  }
}