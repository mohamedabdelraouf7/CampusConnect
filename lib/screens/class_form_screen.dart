import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/app_state.dart';
import '../models/class_model.dart';

class ClassFormScreen extends StatefulWidget {
  final AppState appState;
  final ClassModel? classItem; // Null for new class, non-null for editing
  final int? initialDayOfWeek;
  
  const ClassFormScreen({
    Key? key, 
    required this.appState, 
    this.classItem,
    this.initialDayOfWeek,
  }) : super(key: key);

  @override
  _ClassFormScreenState createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _professorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  int _selectedDay = 1; // Monday by default
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  
  bool get _isEditing => widget.classItem != null;
  
  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      // Populate form with existing class data
      final classItem = widget.classItem!;
      _nameController.text = classItem.name;
      _courseCodeController.text = classItem.courseCode;
      _professorController.text = classItem.professor;
      _locationController.text = classItem.location;
      _notesController.text = classItem.notes;
      _selectedDay = classItem.dayOfWeek;
      _startTime = classItem.startTime;
      _endTime = classItem.endTime;
    } else if (widget.initialDayOfWeek != null) {
      _selectedDay = widget.initialDayOfWeek!;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _courseCodeController.dispose();
    _professorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        
        // If end time is before start time, adjust it
        final startMinutes = _startTime.hour * 60 + _startTime.minute;
        final endMinutes = _endTime.hour * 60 + _endTime.minute;
        
        if (endMinutes <= startMinutes) {
          // Set end time to 1.5 hours after start time
          final newEndMinutes = startMinutes + 90;
          _endTime = TimeOfDay(
            hour: (newEndMinutes ~/ 60) % 24,
            minute: newEndMinutes % 60,
          );
        }
      });
    }
  }
  
  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    
    if (picked != null && picked != _endTime) {
      final startMinutes = _startTime.hour * 60 + _startTime.minute;
      final pickedMinutes = picked.hour * 60 + picked.minute;
      
      if (pickedMinutes > startMinutes) {
        setState(() {
          _endTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
    }
  }
  
  void _saveClass() {
    if (_formKey.currentState!.validate()) {
      final classItem = ClassModel(
        id: _isEditing ? widget.classItem!.id : const Uuid().v4(),
        name: _nameController.text,
        courseCode: _courseCodeController.text,
        professor: _professorController.text,
        location: _locationController.text,
        dayOfWeek: _selectedDay,
        startTime: _startTime,
        endTime: _endTime,
        notes: _notesController.text,
      );
      
      if (_isEditing) {
        // Update existing class
        final index = widget.appState.classes.indexWhere((c) => c.id == classItem.id);
        if (index != -1) {
          widget.appState.classes[index] = classItem;
        }
      } else {
        // Add new class
        widget.appState.classes.add(classItem);
      }
      
      widget.appState.saveClasses();
      Navigator.pop(context, true); // Return true to indicate changes were made
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Class' : 'Add Class'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'e.g. Introduction to Computer Science',
                  prefixIcon: Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class name';
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
              
              // Professor
              TextFormField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Professor',
                  hintText: 'e.g. Dr. Smith',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a professor name';
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
                  hintText: 'e.g. Science Building, Room 101',
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
              
              // Day of week
              const Text(
                'Day of Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDayButton(1, 'Monday'),
                    _buildDayButton(2, 'Tuesday'),
                    _buildDayButton(3, 'Wednesday'),
                    _buildDayButton(4, 'Thursday'),
                    _buildDayButton(5, 'Friday'),
                    _buildDayButton(6, 'Saturday'),
                    _buildDayButton(7, 'Sunday'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Time range
              const Text(
                'Class Time',
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
                      title: const Text('Start Time'),
                      subtitle: Text(_formatTimeOfDay(_startTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectStartTime,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(_formatTimeOfDay(_endTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectEndTime,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any additional information about the class',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isEditing ? 'Update Class' : 'Add Class',
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
  
  Widget _buildDayButton(int day, String label) {
    final isSelected = _selectedDay == day;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedDay = day;
            });
          }
        },
      ),
    );
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}