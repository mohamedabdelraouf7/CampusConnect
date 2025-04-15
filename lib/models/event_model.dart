class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String organizer;
  final bool isRsvped;
  
  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.organizer,
    this.isRsvped = false,
  });
  
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      organizer: json['organizer'],
      isRsvped: json['isRsvped'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'isRsvped': isRsvped,
    };
  }
  
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? organizer,
    bool? isRsvped,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      isRsvped: isRsvped ?? this.isRsvped,
    );
  }
}