import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import '../models/note_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (kIsWeb) {
      // Return a mock database or throw a meaningful exception for web
      throw UnsupportedError('SQLite database is not supported on web platform');
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'campus_connect.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Classes table
    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY,
        courseCode TEXT NOT NULL,
        courseName TEXT NOT NULL,
        instructor TEXT NOT NULL,
        location TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
    
    // Events table
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT NOT NULL,
        dateTime INTEGER NOT NULL,
        endDateTime INTEGER,
        isAllDay INTEGER NOT NULL,
        color INTEGER NOT NULL,
        isImportant INTEGER NOT NULL
      )
    ''');
    
    // Study groups table
    await db.execute('''
      CREATE TABLE study_groups(
        id TEXT PRIMARY KEY,
        topic TEXT NOT NULL,
        courseCode TEXT NOT NULL,
        courseName TEXT NOT NULL,
        location TEXT NOT NULL,
        dateTime INTEGER NOT NULL,
        description TEXT,
        createdBy TEXT NOT NULL,
        maxParticipants INTEGER NOT NULL,
        isJoined INTEGER NOT NULL
      )
    ''');
    
    // Study group participants table
    await db.execute('''
      CREATE TABLE study_group_participants(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studyGroupId TEXT NOT NULL,
        participantName TEXT NOT NULL,
        FOREIGN KEY (studyGroupId) REFERENCES study_groups (id) ON DELETE CASCADE
      )
    ''');
    
    // Notes table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        dateCreated INTEGER NOT NULL,
        dateModified INTEGER NOT NULL,
        color INTEGER NOT NULL,
        isPinned INTEGER NOT NULL
      )
    ''');
  }
  
  // CRUD operations for Classes
  
  Future<int> insertClass(ClassModel classModel) async {
    Database db = await database;
    return await db.insert('classes', classModel.toJson());
  }
  
  Future<List<ClassModel>> getClasses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) {
      return ClassModel.fromJson(maps[i]);
    });
  }
  
  Future<int> updateClass(ClassModel classModel) async {
    Database db = await database;
    return await db.update(
      'classes',
      classModel.toJson(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }
  
  Future<int> deleteClass(String id) async {
    Database db = await database;
    return await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // CRUD operations for Events
  
  Future<int> insertEvent(EventModel event) async {
    Database db = await database;
    return await db.insert('events', event.toJson());
  }
  
  Future<List<EventModel>> getEvents() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return EventModel.fromJson(maps[i]);
    });
  }
  
  Future<int> updateEvent(EventModel event) async {
    Database db = await database;
    return await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }
  
  Future<int> deleteEvent(String id) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // CRUD operations for Study Groups
  
  Future<int> insertStudyGroup(StudyGroupModel studyGroup) async {
    Database db = await database;
    
    // Begin transaction
    await db.transaction((txn) async {
      // Insert study group
      await txn.insert('study_groups', {
        'id': studyGroup.id,
        'topic': studyGroup.topic,
        'courseCode': studyGroup.courseCode,
        'courseName': studyGroup.courseName,
        'location': studyGroup.location,
        'dateTime': studyGroup.dateTime.millisecondsSinceEpoch,
        'description': studyGroup.description,
        'createdBy': studyGroup.createdBy,
        'maxParticipants': studyGroup.maxParticipants,
        'isJoined': studyGroup.isJoined ? 1 : 0,
      });
      
      // Insert participants
      for (String participant in studyGroup.participants) {
        await txn.insert('study_group_participants', {
          'studyGroupId': studyGroup.id,
          'participantName': participant,
        });
      }
    });
    
    return 1; // Success
  }
  
  Future<List<StudyGroupModel>> getStudyGroups() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('study_groups');
    
    List<StudyGroupModel> studyGroups = [];
    
    for (var map in maps) {
      // Get participants for this study group
      List<Map<String, dynamic>> participantMaps = await db.query(
        'study_group_participants',
        where: 'studyGroupId = ?',
        whereArgs: [map['id']],
      );
      
      List<String> participants = participantMaps.map((p) => p['participantName'] as String).toList();
      
      studyGroups.add(StudyGroupModel(
        id: map['id'],
        topic: map['topic'],
        courseCode: map['courseCode'],
        courseName: map['courseName'],
        location: map['location'],
        dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
        description: map['description'] ?? '',
        createdBy: map['createdBy'],
        maxParticipants: map['maxParticipants'],
        participants: participants,
        isJoined: map['isJoined'] == 1,
      ));
    }
    
    return studyGroups;
  }
  
  Future<int> updateStudyGroup(StudyGroupModel studyGroup) async {
    Database db = await database;
    
    // Begin transaction
    await db.transaction((txn) async {
      // Update study group
      await txn.update(
        'study_groups',
        {
          'topic': studyGroup.topic,
          'courseCode': studyGroup.courseCode,
          'courseName': studyGroup.courseName,
          'location': studyGroup.location,
          'dateTime': studyGroup.dateTime.millisecondsSinceEpoch,
          'description': studyGroup.description,
          'createdBy': studyGroup.createdBy,
          'maxParticipants': studyGroup.maxParticipants,
          'isJoined': studyGroup.isJoined ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [studyGroup.id],
      );
      
      // Delete existing participants
      await txn.delete(
        'study_group_participants',
        where: 'studyGroupId = ?',
        whereArgs: [studyGroup.id],
      );
      
      // Insert updated participants
      for (String participant in studyGroup.participants) {
        await txn.insert('study_group_participants', {
          'studyGroupId': studyGroup.id,
          'participantName': participant,
        });
      }
    });
    
    return 1; // Success
  }
  
  Future<int> deleteStudyGroup(String id) async {
    Database db = await database;
    
    // Begin transaction
    await db.transaction((txn) async {
      // Delete participants
      await txn.delete(
        'study_group_participants',
        where: 'studyGroupId = ?',
        whereArgs: [id],
      );
      
      // Delete study group
      await txn.delete(
        'study_groups',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    
    return 1; // Success
  }
  
  // CRUD operations for Notes
  
  Future<int> insertNote(NoteModel note) async {
    Database db = await database;
    return await db.insert('notes', note.toJson());
  }
  
  Future<List<NoteModel>> getNotes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, dateModified DESC',
    );
    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }
  
  Future<int> updateNote(NoteModel note) async {
    Database db = await database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<int> deleteNote(String id) async {
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}