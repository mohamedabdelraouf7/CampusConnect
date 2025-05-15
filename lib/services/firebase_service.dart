import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';
import '../models/study_group_model.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';
import '../utils/database_helper.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService({FirebaseDatabase? database}) {
    if (database != null) {
      _instance._database = database;
    }
    return _instance;
  }
  
  late FirebaseDatabase _database;
  final DatabaseHelper _localDb = DatabaseHelper();
  
  FirebaseService._internal();
  
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _database = FirebaseDatabase.instance;
    _database.setPersistenceEnabled(true); // Enable offline capabilities
  }
  
  // Study Group Methods
  DatabaseReference studyGroupsRef() => _database.ref('study_groups');
  
  Stream<List<StudyGroupModel>> getStudyGroupsStream() {
    return studyGroupsRef().onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      final groups = data.entries.map((entry) {
        final studyGroup = Map<String, dynamic>.from(entry.value);
        studyGroup['id'] = entry.key;
        return StudyGroupModel.fromJson(studyGroup);
      }).toList();
      
      // Sync with local database
      _syncStudyGroupsWithLocal(groups);
      
      return groups;
    });
  }
  
  Future<void> _syncStudyGroupsWithLocal(List<StudyGroupModel> groups) async {
    for (var group in groups) {
      await _localDb.insertStudyGroup(group);
    }
  }
  
  Future<void> addOrUpdateStudyGroup(StudyGroupModel group) async {
    if (group.id.isEmpty) {
      // New group
      await studyGroupsRef().push().set(group.toJson());
    } else {
      // Update existing group
      await studyGroupsRef().child(group.id).update(group.toJson());
    }
    
    // Also update local database
    await _localDb.insertStudyGroup(group);
  }
  
  Future<void> deleteStudyGroup(String groupId) async {
    await studyGroupsRef().child(groupId).remove();
    
    // Also delete from local database
    await _localDb.deleteStudyGroup(groupId);
  }
  
  // Study Group Notes
  DatabaseReference groupNotesRef(String groupId) => 
      _database.ref('study_group_notes').child(groupId);
  
  Stream<List<Map<String, dynamic>>> getGroupNotesStream(String groupId) {
    return groupNotesRef(groupId).onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        final note = Map<String, dynamic>.from(entry.value);
        note['id'] = entry.key;
        return note;
      }).toList();
    });
  }
  
  Future<void> addStudyGroupNote(
    String groupId, 
    String title, 
    String content, 
    String authorName
  ) async {
    final noteData = {
      'title': title,
      'content': content,
      'authorName': authorName,
      'timestamp': ServerValue.timestamp,
    };
    
    await groupNotesRef(groupId).push().set(noteData);
  }
  
  // Event Methods
  DatabaseReference eventsRef() => _database.ref('events');
  
  Stream<List<EventModel>> getEventsStream() {
    return eventsRef().onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      final events = data.entries.map((entry) {
        final eventData = Map<String, dynamic>.from(entry.value);
        eventData['id'] = entry.key;
        return EventModel.fromJson(eventData);
      }).toList();
      
      // Sync with local database
      _syncEventsWithLocal(events);
      
      return events;
    });
  }
  
  Future<void> _syncEventsWithLocal(List<EventModel> events) async {
    for (var event in events) {
      await _localDb.insertEvent(event);
    }
  }
  
  Future<void> addOrUpdateEvent(EventModel event) async {
    if (event.id.isEmpty) {
      // New event
      await eventsRef().push().set(event.toJson());
    } else {
      // Update existing event
      await eventsRef().child(event.id).update(event.toJson());
    }
    
    // Also update local database
    await _localDb.insertEvent(event);
  }
  
  // Announcement Methods
  DatabaseReference announcementsRef() => _database.ref('announcements');
  
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return announcementsRef().onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      return data.entries.map((entry) {
        final announcement = Map<String, dynamic>.from(entry.value);
        announcement['id'] = entry.key;
        return AnnouncementModel.fromJson(announcement);
      }).toList();
    });
  }
}