import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum AcademicEventType {
  exam,
  assignment,
  quiz,
  project,
  presentation,
}

class AcademicEvent {
  final String id;
  final String title;
  final String courseCode;
  final String courseName;
  final AcademicEventType type;
  final DateTime dueDate;
  final String? description;
  final String? location;
  final int? durationMinutes; // For exams/quizzes
  final double? weight; // For grading weight
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademicEvent({
    String? id,
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.type,
    required this.dueDate,
    this.description,
    this.location,
    this.durationMinutes,
    this.weight,
    this.isCompleted = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory AcademicEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AcademicEvent(
      id: doc.id,
      title: data['title'] as String,
      courseCode: data['courseCode'] as String,
      courseName: data['courseName'] as String,
      type: AcademicEventType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => AcademicEventType.assignment,
      ),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      description: data['description'] as String?,
      location: data['location'] as String?,
      durationMinutes: data['durationMinutes'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'courseCode': courseCode,
      'courseName': courseName,
      'type': type.toString(),
      'dueDate': Timestamp.fromDate(dueDate),
      'description': description,
      'location': location,
      'durationMinutes': durationMinutes,
      'weight': weight,
      'isCompleted': isCompleted,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AcademicEvent copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? courseName,
    AcademicEventType? type,
    DateTime? dueDate,
    String? description,
    String? location,
    int? durationMinutes,
    double? weight,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      location: location ?? this.location,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get typeDisplay {
    switch (type) {
      case AcademicEventType.exam:
        return 'Exam';
      case AcademicEventType.assignment:
        return 'Assignment';
      case AcademicEventType.quiz:
        return 'Quiz';
      case AcademicEventType.project:
        return 'Project';
      case AcademicEventType.presentation:
        return 'Presentation';
    }
  }

  String get displayTitle => '$typeDisplay: $title';
  
  String get subtitle => '$courseCode - $courseName';
  
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  
  bool get isUpcoming => !isCompleted && dueDate.isAfter(DateTime.now());
  
  Duration get timeUntilDue => dueDate.difference(DateTime.now());
  
  String get timeUntilDueDisplay {
    final duration = timeUntilDue;
    if (duration.isNegative) {
      return 'Overdue';
    }
    
    final days = duration.inDays;
    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'} left';
    }
    
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} left';
    }
    
    final minutes = duration.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} left';
  }
} 