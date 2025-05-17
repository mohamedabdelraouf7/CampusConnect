
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String sender;
  final String senderRole; // e.g., "Department", "Club", "Administration"
  final DateTime timestamp;
  final String category; // e.g., "Academic", "Event", "Emergency"
  final bool isUrgent;
  
  AnnouncementModel({
    this.id = '',
    required this.title,
    required this.content,
    required this.sender,
    required this.senderRole,
    required this.timestamp,
    required this.category,
    this.isUrgent = false,
  });
  
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      senderRole: json['senderRole'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      category: json['category'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'sender': sender,
      'senderRole': senderRole,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'category': category,
      'isUrgent': isUrgent,
    };
  }
  
  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? sender,
    String? senderRole,
    DateTime? timestamp,
    String? category,
    bool? isUrgent,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      senderRole: senderRole ?? this.senderRole,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isUrgent: isUrgent ?? this.isUrgent,
    );
  }
}