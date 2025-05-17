import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';
import '../models/study_group_model.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';
import '../utils/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/class_model.dart';
import 'dart:io' show Platform;

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
  bool _isInitialized = false;
  
  FirebaseService._internal();
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _database = FirebaseDatabase.instance;
      if (!kIsWeb) {
        _database.setPersistenceEnabled(true); // Enable offline capabilities
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }
  
  // Study Group Methods
  DatabaseReference studyGroupsRef() {
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    return _database.ref('study_groups');
  }
  
  Stream<List<StudyGroupModel>> getStudyGroupsStream() {
    if (Platform.isWindows) return const Stream.empty();
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    
    return studyGroupsRef().onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      final groups = data.entries.map((entry) {
        try {
          final studyGroup = Map<String, dynamic>.from(entry.value);
          studyGroup['id'] = entry.key;
          return StudyGroupModel.fromJson(studyGroup);
        } catch (e) {
          print('Error parsing study group ${entry.key}: $e');
          return null;
        }
      }).whereType<StudyGroupModel>().toList();
      
      // Sync with local database
      _syncStudyGroupsWithLocal(groups).catchError((e) {
        print('Error syncing study groups with local database: $e');
      });
      
      return groups;
    });
  }
  
  Future<void> _syncStudyGroupsWithLocal(List<StudyGroupModel> groups) async {
    if (kIsWeb) return; // Skip local sync on web
    
    try {
      // Get existing local groups
      final localGroups = await _localDb.getStudyGroups();
      final localGroupIds = localGroups.map((g) => g.id).toSet();
      
      // Update or insert new groups
      for (var group in groups) {
        if (localGroupIds.contains(group.id)) {
          await _localDb.updateStudyGroup(group);
        } else {
          await _localDb.insertStudyGroup(group);
        }
      }
      
      // Delete groups that no longer exist in Firebase
      final remoteGroupIds = groups.map((g) => g.id).toSet();
      for (var localGroup in localGroups) {
        if (!remoteGroupIds.contains(localGroup.id)) {
          await _localDb.deleteStudyGroup(localGroup.id);
        }
      }
    } catch (e) {
      print('Error in _syncStudyGroupsWithLocal: $e');
      rethrow;
    }
  }
  
  Future<void> addOrUpdateStudyGroup(StudyGroupModel group) async {
    if (Platform.isWindows) {
      await _localDb.insertStudyGroup(group);
      return;
    }
    if (group.id.isEmpty) {
      // New group
      final ref = studyGroupsRef().push();
      final groupWithKey = group.copyWith(id : ref.key); // Use copyWith to set the id
      await ref.set(groupWithKey.toJson());
      if (!kIsWeb) {
        await _localDb.insertStudyGroup(groupWithKey);
      }
    } else {
      // Update existing group
      await studyGroupsRef().child(group.id).update(group.toJson());
      if (!kIsWeb) {
        await _localDb.insertStudyGroup(group);
      }
    }
  }
  
  Future<void> deleteStudyGroup(String groupId) async {
    if (Platform.isWindows) {
      await _localDb.deleteStudyGroup(groupId);
      return;
    }
    await studyGroupsRef().child(groupId).remove();
    
    // Also delete from local database
    await _localDb.deleteStudyGroup(groupId);
  }
  
  // Study Group Notes
  DatabaseReference groupNotesRef(String groupId) => 
      _database.ref('study_group_notes').child(groupId);
  
  Stream<List<Map<String, dynamic>>> getGroupNotesStream(String groupId) {
    if (Platform.isWindows) return const Stream.empty();
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
    if (Platform.isWindows) return;
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
    if (Platform.isWindows) return const Stream.empty();
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
    if (Platform.isWindows) {
      await _localDb.insertEvent(event);
      return;
    }
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
  
  Future<void> deleteEvent(String eventId) async {
    if (Platform.isWindows) {
      await _localDb.deleteEvent(eventId);
      return;
    }
    await eventsRef().child(eventId).remove();
    await _localDb.deleteEvent(eventId);
  }
  
  // Announcement Methods
  DatabaseReference announcementsRef() => _database.ref('announcements');
  
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    if (Platform.isWindows) return const Stream.empty();
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
  
  // Class Methods
  DatabaseReference classesRef() {
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    return _database.ref('classes');
  }
  
  Stream<List<ClassModel>> getClassesStream() {
    if (Platform.isWindows) return const Stream.empty();
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    
    return classesRef().onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      if (data == null) return [];
      
      final classes = data.entries.map((entry) {
        try {
          final classData = Map<String, dynamic>.from(entry.value);
          classData['id'] = entry.key;
          return ClassModel.fromJson(classData);
        } catch (e) {
          print('Error parsing class ${entry.key}: $e');
          return null;
        }
      }).whereType<ClassModel>().toList();
      
      // Sync with local database
      _syncClassesWithLocal(classes).catchError((e) {
        print('Error syncing classes with local database: $e');
      });
      
      return classes;
    });
  }
  
  Future<void> _syncClassesWithLocal(List<ClassModel> classes) async {
    if (kIsWeb) return; // Skip local sync on web
    
    try {
      // Get existing local classes
      final localClasses = await _localDb.getClasses();
      final localClassIds = localClasses.map((c) => c.id).toSet();
      
      // Update or insert new classes
      for (var classModel in classes) {
        if (localClassIds.contains(classModel.id)) {
          await _localDb.updateClass(classModel);
        } else {
          await _localDb.insertClass(classModel);
        }
      }
      
      // Delete classes that no longer exist in Firebase
      final remoteClassIds = classes.map((c) => c.id).toSet();
      for (var localClass in localClasses) {
        if (!remoteClassIds.contains(localClass.id)) {
          await _localDb.deleteClass(localClass.id);
        }
      }
    } catch (e) {
      print('Error in _syncClassesWithLocal: $e');
      rethrow;
    }
  }
  
  Future<void> addOrUpdateClass(ClassModel classModel) async {
    if (Platform.isWindows) {
      await _localDb.insertClass(classModel);
      return;
    }
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }

    if (classModel.id.isEmpty) {
      // New class
      final ref = classesRef().push();
      final classWithKey = classModel.copyWith(id: ref.key);
      await ref.set(classWithKey.toJson());
      if (!kIsWeb) {
        await _localDb.insertClass(classWithKey);
      }
    } else {
      // Update existing class
      await classesRef().child(classModel.id).update(classModel.toJson());
      if (!kIsWeb) {
        await _localDb.updateClass(classModel);
      }
    }
  }
  
  Future<void> deleteClass(String classId) async {
    if (Platform.isWindows) {
      await _localDb.deleteClass(classId);
      return;
    }
    if (!_isInitialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }

    await classesRef().child(classId).remove();
    if (!kIsWeb) {
      await _localDb.deleteClass(classId);
    }
  }
}