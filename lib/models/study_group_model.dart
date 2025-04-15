import 'package:uuid/uuid.dart';

class StudyGroupModel {
  final String id;
  final String topic;
  final String courseCode;
  final String courseName;
  final String location;
  final DateTime dateTime;
  final String description;
  final String createdBy;
  final int maxParticipants;
  final List<String> participants;
  final bool isJoined;
  
  StudyGroupModel({
    String? id,
    required this.topic,
    required this.courseCode,
    required this.courseName,
    required this.location,
    required this.dateTime,
    this.description = '',
    required this.createdBy,
    this.maxParticipants = 10,
    required this.participants,
    this.isJoined = false,
  }) : id = id ?? const Uuid().v4();
  
  StudyGroupModel copyWith({
    String? topic,
    String? courseCode,
    String? courseName,
    String? location,
    DateTime? dateTime,
    String? description,
    String? createdBy,
    int? maxParticipants,
    List<String>? participants,
    bool? isJoined,
  }) {
    return StudyGroupModel(
      id: this.id,
      topic: topic ?? this.topic,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      isJoined: isJoined ?? this.isJoined,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'courseCode': courseCode,
      'courseName': courseName,
      'location': location,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'description': description,
      'createdBy': createdBy,
      'maxParticipants': maxParticipants,
      'participants': participants,
      'isJoined': isJoined,
    };
  }
  
  factory StudyGroupModel.fromJson(Map<String, dynamic> json) {
    return StudyGroupModel(
      id: json['id'],
      topic: json['topic'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      location: json['location'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
      description: json['description'] ?? '',
      createdBy: json['createdBy'],
      maxParticipants: json['maxParticipants'] ?? 10,
      participants: List<String>.from(json['participants']),
      isJoined: json['isJoined'] ?? false,
    );
  }
}