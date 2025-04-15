import 'package:flutter/material.dart';

class ClassModel {
  final String id;
  final String name;
  final String courseCode;
  final String professor;
  final String location;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String notes;
  
  ClassModel({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.professor,
    required this.location,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.notes = '',
  });
  
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      courseCode: json['courseCode'],
      professor: json['professor'],
      location: json['location'],
      dayOfWeek: json['dayOfWeek'],
      startTime: TimeOfDay(
        hour: json['startTimeHour'],
        minute: json['startTimeMinute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTimeHour'],
        minute: json['endTimeMinute'],
      ),
      notes: json['notes'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courseCode': courseCode,
      'professor': professor,
      'location': location,
      'dayOfWeek': dayOfWeek,
      'startTimeHour': startTime.hour,
      'startTimeMinute': startTime.minute,
      'endTimeHour': endTime.hour,
      'endTimeMinute': endTime.minute,
      'notes': notes,
    };
  }
  
  String get dayName {
    switch (dayOfWeek) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  String get timeRange {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}