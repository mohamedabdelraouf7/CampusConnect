import 'package:uuid/uuid.dart';

enum NotificationType {
  classReminder,
  studyGroup,
  event,
  announcement,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedItemId; // ID of related class, event, study group, etc.
  
  NotificationModel({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.isRead = false,
    this.relatedItemId,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  NotificationModel copyWith({
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedItemId,
  }) {
    return NotificationModel(
      id: this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedItemId: relatedItemId ?? this.relatedItemId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'relatedItemId': relatedItemId,
    };
  }
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values[json['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isRead: json['isRead'],
      relatedItemId: json['relatedItemId'],
    );
  }
}