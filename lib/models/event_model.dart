import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String organizer;
  final List<String> attendees;
  final String? imageUrl;
  final String? category;
  final int? maxAttendees;
  
  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.organizer,
    this.attendees = const [],
    this.imageUrl,
    this.category,
    this.maxAttendees,
  }) {
    // Validate required fields
    assert(id.isNotEmpty, 'Event ID cannot be empty');
    assert(title.isNotEmpty, 'Event title cannot be empty');
    assert(description.isNotEmpty, 'Event description cannot be empty');
    assert(location.isNotEmpty, 'Event location cannot be empty');
    assert(organizer.isNotEmpty, 'Event organizer cannot be empty');
    
    // Validate max attendees if provided
    if (maxAttendees != null) {
      assert(maxAttendees! > 0, 'Max attendees must be greater than 0');
      assert(attendees.length <= maxAttendees!, 'Number of attendees cannot exceed max attendees');
    }
  }
  
  bool get isAttending => attendees.isNotEmpty; // For backward compatibility
  bool get isFull => maxAttendees != null && attendees.length >= maxAttendees!;
  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isUpcoming => !isPast;
  
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      dateTime: DateTime.parse(json['dateTime']),
      organizer: json['organizer'],
      attendees: json['attendees'] is String
        ? List<String>.from(jsonDecode(json['attendees']))
        : List<String>.from(json['attendees'] ?? []),
      imageUrl: json['imageUrl'],
      category: json['category'],
      maxAttendees: json['maxAttendees'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'organizer': organizer,
      'attendees': jsonEncode(attendees),
      'imageUrl': imageUrl,
      'category': category,
      'maxAttendees': maxAttendees,
    };
  }
  
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? dateTime,
    String? organizer,
    List<String>? attendees,
    String? imageUrl,
    String? category,
    int? maxAttendees,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      organizer: organizer ?? this.organizer,
      attendees: attendees ?? this.attendees,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      maxAttendees: maxAttendees ?? this.maxAttendees,
    );
  }
}