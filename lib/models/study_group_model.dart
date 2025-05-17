import 'package:uuid/uuid.dart';
import 'dart:convert';

class StudyGroupModel {
  final String id;
  final String courseCode;
  final String courseName;
  final String topic;
  final String description;
  final String location;
  final DateTime dateTime;
  final String createdBy;
  final List<String> participants;
  final int maxParticipants;
  
  StudyGroupModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.topic,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.createdBy,
    required this.participants,
    required this.maxParticipants,
  });

  bool get isJoined => participants.isNotEmpty;
  bool get isFull => participants.length >= maxParticipants;
  
  factory StudyGroupModel.fromJson(Map<String, dynamic> json) {
    List<String> participantsList = [];
    if (json['participants'] != null) {
      if (json['participants'] is String) {
        participantsList = List<String>.from(jsonDecode(json['participants']));
      } else if (json['participants'] is List) {
        participantsList = List<String>.from(json['participants']);
      }
    }
    
    // Handle date parsing
    DateTime parsedDateTime;
    if (json['dateTime'] != null) {
      if (json['dateTime'] is int) {
        parsedDateTime = DateTime.fromMillisecondsSinceEpoch(json['dateTime']);
      } else if (json['dateTime'] is String) {
        try {
          parsedDateTime = DateTime.parse(json['dateTime']);
        } catch (e) {
          parsedDateTime = DateTime.now();
        }
      } else {
        parsedDateTime = DateTime.now();
      }
    } else {
      parsedDateTime = DateTime.now();
    }
    
    return StudyGroupModel(
      id: json['id'] ?? '',
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      dateTime: parsedDateTime,
      createdBy: json['createdBy'] ?? '',
      participants: participantsList,
      maxParticipants: json['maxParticipants'] ?? 10,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'topic': topic,
      'description': description,
      'location': location,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'participants': jsonEncode(participants),
      'maxParticipants': maxParticipants,
    };
  }
  
  StudyGroupModel copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    String? topic,
    String? description,
    String? location,
    DateTime? dateTime,
    String? createdBy,
    List<String>? participants,
    int? maxParticipants,
  }) {
    return StudyGroupModel(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      createdBy: createdBy ?? this.createdBy,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
    );
  }
}