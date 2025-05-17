import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/class_card.dart';
import 'class_detail_screen.dart';
import 'class_form_screen.dart';

class ClassScheduleScreen extends StatefulWidget {
  final AppState appState;
  
  const ClassScheduleScreen({super.key, required this.appState});

  @override
  _ClassScheduleScreenState createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends State<ClassScheduleScreen> {
  int _selectedDay = DateTime.now().weekday;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassFormScreen(appState: widget.appState),
                ),
              );
              
              if (result == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: _buildClassesForDay(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDayButton(1, 'Mon'),
          _buildDayButton(2, 'Tue'),
          _buildDayButton(3, 'Wed'),
          _buildDayButton(4, 'Thu'),
          _buildDayButton(5, 'Fri'),
          _buildDayButton(6, 'Sat'),
          _buildDayButton(7, 'Sun'),
        ],
      ),
    );
  }
  
  Widget _buildDayButton(int day, String label) {
    final isSelected = _selectedDay == day;
    final isToday = DateTime.now().weekday == day;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
              ? Theme.of(context).primaryColor
              : (isToday ? Colors.grey[300] : Colors.grey[100]),
          foregroundColor: isSelected
              ? Colors.white
              : (isToday ? Colors.black : Colors.grey[700]),
        ),
        onPressed: () {
          setState(() {
            _selectedDay = day;
          });
        },
        child: Text(label),
      ),
    );
  }
  
  Widget _buildClassesForDay() {
    final classes = widget.appState.classes
        .where((c) => c.dayOfWeek == _selectedDay)
        .toList();
    
    // Sort classes by start time
    classes.sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No classes scheduled for this day',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassFormScreen(
                      appState: widget.appState,
                      initialDayOfWeek: _selectedDay,
                    ),
                  ),
                );
                
                if (result == true) {
                  setState(() {});
                }
              },
              child: const Text('Add Class for This Day'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return ClassCard(
          classItem: classItem,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetailScreen(
                  appState: widget.appState,
                  classItem: classItem,
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