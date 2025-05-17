import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/academic_event_model.dart';
import '../models/app_state.dart';
import '../services/academic_event_service.dart';

class AcademicEventFormScreen extends StatefulWidget {
  final AppState appState;
  final AcademicEvent? event; // Null for new event, non-null for editing
  final DateTime? initialDate;
  
  const AcademicEventFormScreen({
    super.key,
    required this.appState,
    this.event,
    this.initialDate,
  });

  @override
  _AcademicEventFormScreenState createState() => _AcademicEventFormScreenState();
}

class _AcademicEventFormScreenState extends State<AcademicEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();
  
  late AcademicEventType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isCompleted = false;
  
  final AcademicEventService _eventService = AcademicEventService();
  bool _isLoading = false;
  
  bool get _isEditing => widget.event != null;
  
  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      // Populate form with existing event data
      final event = widget.event!;
      _titleController.text = event.title;
      _courseCodeController.text = event.courseCode;
      _courseNameController.text = event.courseName;
      _descriptionController.text = event.description ?? '';
      _locationController.text = event.location ?? '';
      _notesController.text = event.notes ?? '';
      _weightController.text = event.weight?.toString() ?? '';
      _durationController.text = event.durationMinutes?.toString() ?? '';
      _selectedType = event.type;
      _selectedDate = event.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(event.dueDate);
      _isCompleted = event.isCompleted;
    } else {
      _selectedType = AcademicEventType.assignment;
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _durationController.dispose();
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
  
  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final dueDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        final event = AcademicEvent(
          id: _isEditing ? widget.event!.id : null,
          title: _titleController.text,
          courseCode: _courseCodeController.text,
          courseName: _courseNameController.text,
          type: _selectedType,
          dueDate: dueDate,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          durationMinutes: _durationController.text.isEmpty ? null : int.parse(_durationController.text),
          weight: _weightController.text.isEmpty ? null : double.parse(_weightController.text),
          isCompleted: _isCompleted,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        if (_isEditing) {
          await _eventService.updateEvent(event);
        } else {
          await _eventService.addEvent(event);
        }
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Add Event'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
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
                  try {
                    await _eventService.deleteEvent(widget.event!.id);
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Event type
            DropdownButtonFormField<AcademicEventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Event Type',
                prefixIcon: Icon(Icons.event),
              ),
              items: AcademicEventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an event type';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Midterm Exam, Final Project',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
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
                hintText: 'e.g. CSE 431',
                prefixIcon: Icon(Icons.class_),
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
                hintText: 'e.g. Mobile Programming',
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date and time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
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
            
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g. Room 101, Online',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Duration (for exams/quizzes)
            if (_selectedType == AcademicEventType.exam || _selectedType == AcademicEventType.quiz)
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'e.g. 120',
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final minutes = int.tryParse(value);
                    if (minutes == null || minutes <= 0) {
                      return 'Please enter a valid duration';
                    }
                  }
                  return null;
                },
              ),
            
            if (_selectedType == AcademicEventType.exam || _selectedType == AcademicEventType.quiz)
              const SizedBox(height: 16),
            
            // Weight (for grading)
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (%)',
                hintText: 'e.g. 25',
                prefixIcon: Icon(Icons.assessment),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0 || weight > 100) {
                    return 'Please enter a valid weight (0-100)';
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add any additional details about the event',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add personal notes about this event',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 24),
            
            // Completed checkbox
            if (_isEditing)
              CheckboxListTile(
                title: const Text('Mark as completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
              ),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Update Event' : 'Add Event',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 