import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/study_group_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/animated_checkmark.dart';

class StudyGroupFormScreen extends StatefulWidget {
  final AppState appState;
  final StudyGroupModel? studyGroup; // Null for new group, non-null for editing
  
  const StudyGroupFormScreen({
    super.key, 
    required this.appState, 
    this.studyGroup,
  });

  @override
  _StudyGroupFormScreenState createState() => _StudyGroupFormScreenState();
}

class _StudyGroupFormScreenState extends State<StudyGroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime get _selectedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );
  int _maxParticipants = 10;
  
  bool get _isEditing => widget.studyGroup != null;
  
  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      // Populate form with existing study group data
      final studyGroup = widget.studyGroup!;
      _topicController.text = studyGroup.topic;
      _courseCodeController.text = studyGroup.courseCode;
      _courseNameController.text = studyGroup.courseName;
      _locationController.text = studyGroup.location;
      _descriptionController.text = studyGroup.description;
      _selectedDate = studyGroup.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(studyGroup.dateTime);
      _maxParticipants = studyGroup.maxParticipants;
    }
  }
  
  @override
  void dispose() {
    _topicController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _saveStudyGroup() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      final studyGroup = StudyGroupModel(
        id: widget.studyGroup?.id ?? const Uuid().v4(),
        courseCode: _courseCodeController.text,
        courseName: _courseNameController.text,
        topic: _topicController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        dateTime: _selectedDateTime,
        createdBy: widget.appState.userEmail,
        participants: widget.studyGroup?.participants ?? [widget.appState.userEmail],
        maxParticipants: _maxParticipants,
      );

      try {
        await widget.appState.firebaseService.addOrUpdateStudyGroup(studyGroup);
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: AnimatedCheckmark()),
          );
          await Future.delayed(const Duration(milliseconds: 900));
          if (mounted) Navigator.pop(context); // Dismiss dialog
          if (mounted) Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving study group: $e')),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Study Group' : 'Create Study Group'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Study Topic',
                  hintText: 'e.g. Midterm Exam Preparation',
                  prefixIcon: Icon(Icons.topic),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a study topic';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Course code
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g. CS101',
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Course name
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  hintText: 'e.g. Introduction to Computer Science',
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Library, Study Room 3',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Date and time
              const Text(
                'Date and Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text(dateFormat.format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Time'),
                      subtitle: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Max participants
              const Text(
                'Maximum Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Slider(
                value: _maxParticipants.toDouble(),
                min: 2,
                max: 30,
                divisions: 28,
                label: _maxParticipants.toString(),
                onChanged: (value) {
                  setState(() {
                    _maxParticipants = value.toInt();
                  });
                },
              ),
              
              Center(
                child: Text(
                  '$_maxParticipants participants',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide details about what will be covered in this study session',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveStudyGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    _isEditing ? 'Update Study Group' : 'Create Study Group',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}